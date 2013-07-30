require 'json'
require 'optparse'
require 'provisioner/errors'
require 'highline/import'

module Gds
  module Provisioner
    class CLI
      def self.defaults
        {
          :debug       => false,
          :log_level   => 5,
          :memory      => 4096,
          :num_cores   => 4,
          :num_servers => 1,
          :platform    => "production",
          :role        => "client",
          :ssh_config  => true,         # if not specified, use system defaults
        }.freeze
      end

      def self.process(config, template, options = {})
        # The template must specify a zone so we know where to look in the
        # organisation config
        begin
          zone = template.fetch(:zone)
        rescue KeyError
          raise ConfigurationError, "The template doesn't specify a zone (Maybe you've put template and config in the wrong order?)"
        end

        # Internal defaults
        res = self.defaults.dup
        # vCloud config defaults
        res.merge!(config.fetch(:default, {}))
        # vCloud zone defaults
        res.merge!(config.fetch(zone.to_sym, {}))
        # Machine template options
        res.merge!(template)
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

        unless res.include? :puppetmaster
          raise ConfigurationError, "You must specify a puppetmaster"
        end

        res
      end


      def initialize( args )
        @args = args
      end

      def execute
        options = {}

        optparser = OptionParser.new do |o|

          o.banner = "Usage: #{File.basename($0)} [options] <org_config> <machine_config>"

          o.separator ""
          o.separator "Provision a machine described by the JSON template `machine_config` in the vCloud organisation"
          o.separator "described in the JSON config file `org_config`"
          o.separator ""
          o.separator "e.g. provision -u johndoe orgs/staging.json machines/frontend-1.json"
          o.separator ""

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

          o.on("-s", "--ssh-user", "=NAME", "SSH username for puppetmaster") do |v|
            options[:ssh_user] = v
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

          if @args.length != 2
            raise ConfigurationError, "#{File.basename($0)} takes two arguments"
          end

          config_file, template_file = @args

          config = JSON.parse(File.read(config_file), :symbolize_names => true)
          template = JSON.parse(File.read(template_file), :symbolize_names => true)

          if options[:user].nil? then
            options[:user] = ask("vCloud username: ")
          end

          if options[:password].nil? then
            options[:password] = ask("vCloud password: ") { |q| q.echo = false }
          end

          if options[:ssh_user].nil? then
            options[:ssh_user] = ask("SSH user: ") { |d| d.default = options[:user] }
          end

          provisioner_opts = self.class.process(config, template, options)

          provisioner = Gds::Provisioner.build provisioner_opts
          provisioner.execute
        rescue OptionParser::InvalidArgument, ConfigurationError => e
          $stderr.puts "Error: #{e}"
          $stderr.puts
          $stderr.puts optparser
          exit 1
        end
      end
    end
  end
end
