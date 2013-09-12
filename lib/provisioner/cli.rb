require 'multi_json'
require 'optparse'
require 'provisioner/errors'
require 'highline/import'
require 'vcloud_box_provisioner'

module Provisioner
  class CLI
    def self.defaults
      {
        :debug       => false,
        :log_level   => 5,
        :memory      => 4096,
        :num_cores   => 2,
        :num_servers => 1,
        :platform    => "production",
        :ssh_config  => true,         # if not specified, use system defaults
      }.freeze
    end

    def self.process(options = {})
      # The template must specify a zone so we know where to look in the
      # organisation config
      begin
        zone = options[:machine_metadata].fetch(:zone)
      rescue KeyError
        raise ConfigurationError, "The machine configuration doesn't specify " +
          "a zone (Maybe you've put machine metadata and org config in the wrong order?)"
      end

      # Internal defaults
      res = self.defaults.dup
      # vCloud config defaults
      org_config = options.delete(:org_config)
      res.merge!(org_config.fetch(:default, {}))
      # vCloud zone defaults
      res.merge!(org_config.fetch(zone.to_sym, {}))
      # Machine metadata options
      res.merge!(options.delete(:machine_metadata))
      # Command line options
      res.merge!(options)

      unless res.include? :catalog_id
        begin
          template_name = res.fetch(:template_name)
          catalog_id = res.fetch(:catalog_items).fetch(template_name.to_sym)
        rescue KeyError
          raise ConfigurationError, 'You must specify catalog_id OR (catalog_items AND template_name)'
        end
        res[:catalog_id] = catalog_id
      end

      res
    end


    def initialize( args )
      @args = args
    end

    def execute
      options = {}

      optparser = OptionParser.new do |o|

        o.banner = "Usage: #{File.basename($0)} [options] <action>"

        o.separator ""
        o.separator "Provision a machine described by the JSON template `machine_metadata` in the vCloud organisation"
        o.separator "described in the JSON config file `org_config`"
        o.separator ""
        o.separator "e.g. vcloud-box-spinner -u johndoe -o orgs/staging.json -m machines/frontend-1.json create"
        o.separator ""
        o.separator "[Available actions]:"
        o.separator "   #{Provisioner::AVAILABLE_ACTIONS.join(', ')}"
        o.separator ""
        o.separator "[Available options]:"

        o.on("-c", "--credential", "=GROUP", "fog credential group") do |v|
          options[:credential] = v
        end

        o.on("-u", "--user", "=USERNAME", "vCloud username") do |v|
          options[:user] = v
        end

        o.on("-p", "--password", "=PASSWORD", "vCloud password") do |v|
          options[:password] = v
        end

        o.on("-F", "--ssh-config", "=FILENAME", "SSH config file(s) to use (can be specified multiple times)") do |v|
          options[:ssh_config] ||= []
          options[:ssh_config].push(v)
        end

        options[:org_config] = {}
        o.on("-o", "--org-config", "=ORG-CONFIG-JSON",
             "The organisation configuration JSON file path") do |v|
          options[:org_config] = MultiJson.load(File.read(v), :symbolize_names => true)
        end

        options[:machine_metadata] = {}
        o.on("-m", "--machine-config", "=METADATA",
             "The machine configuration JSON file path") do |v|
          options[:machine_metadata] = MultiJson.load(File.read(v), :symbolize_names => true)
        end

        o.on('-s', '--setup-script', "=SETUP-SCRIPT", "path to setup script that should run after machine is brought up") do |v|
          options[:setup_script] = v
        end

        o.on("-d", "--debug", "Enable debugging output") do
          options[:debug] = true
        end

        o.on("-v", "--verbose", "Enable verbose output") do
          options[:log_level] = 0
        end

        o.on_tail("-h", "--help", "Show usage instructions") do
          puts o
          exit
        end
      end

      begin
        optparser.parse!(@args)

        if @args.length != 1
          raise ConfigurationError, "#{File.basename($0)} takes one argument"
        end

        action = @args[0]

        if options[:user] && options[:password].nil? then
          options[:password] = ask("vCloud password: ") { |q| q.echo = false }
        end

        provisioner_opts = self.class.process(options)

        provisioner = VcloudBoxProvisioner.build provisioner_opts
        provisioner.execute(action)
      rescue OptionParser::InvalidArgument, ConfigurationError => e
        $stderr.puts "Error: #{e}"
        $stderr.puts
        $stderr.puts optparser
        exit 1
      end
    end
  end
end
