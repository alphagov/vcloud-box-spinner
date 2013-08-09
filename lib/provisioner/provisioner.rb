module Provisioner
  class Provisioner
    AVAILABLE_ACTIONS = ['create', 'delete']

    attr_accessor :options
    private :options=, :options

    def initialize options
      options[:provider] = 'vcloud'
      options[:created_by] = ENV['USER']
      self.options = options
    end

    def execute(action)
      unless AVAILABLE_ACTIONS.include?(action)
        raise(ConfigurationError, "The action '#{action}' is not a valid action")
      end
      send(action)
    end

    def create
      logger.debug "Validating options"
      validate_options
      logger.debug "Preparing the run"
      prepare_run
      logger.debug "Launching servers"
      launch_servers
      logger.debug "Done"
    end
    private :create

    def delete
      logger.debug "Validating options"
      validate_options
      if ask("Do you really want to delete '#{options[:vm_name]}'? (yes/no) ") == "yes"
        logger.debug "Proceeding delete operation"
        delete_vapp
      else
        logger.debug "Abandoning delete operation"
      end
    end
    private :delete

    def compute
      @compute ||= Fog::Compute.new(
        :provider           => options[:provider],
        :vcloud_username    => "#{options[:user]}@#{options[:organisation]}",
        :vcloud_password    => options[:password],
        :vcloud_host        => options[:host],
        :vcloud_default_vdc => options[:default_vdc],
        :connection_options => {
          :ssl_verify_peer   => false,
          :omit_default_port => true
        }
      )
    end
    private :compute

    def logger
      options[:logger]
    end
    private :logger

    def ssh
      @ssh ||= begin
        Provisioner.ssh_client.tap { |client|
          logger.debug "Using #{client} as my SSH client"
        }
      end
    end

    def ssh_to hostname, &blk
      puts "Sshing to #{hostname}"
      ssh.start hostname,
                options[:ssh_user],
                :config => options[:ssh_config],
                &blk
    end

    def validate_options
      unless options[:password] && options[:user] && options[:host]
        logger.error "VCloud credentials missing"
        raise ConfigurationError, "VCloud credentials must be specified"
      end
    end
    private :validate_options

    def timestamp
      @timestamp ||= Time.now.utc.to_i.to_s(36).tap { |ts|
        logger.debug "The base 36 timestamp for this run in #{ts}"
      }
    end
    private :timestamp

    def launch_server name
    end
    private :launch_server

    def notify message, name
      logger.info "<%s> %s" % [ name, message ]
    end
    private :notify

    def launch_servers
      Parallel.each(options[:num_servers].times, :in_threads => options[:num_servers]) do |number|
        name = server_name number
        server = launch_server name
        bootstrap_server server, name
      end
    end
    private :launch_servers

    def server_name number
      [
        options[:platform],
        options[:class],
        timestamp,
        ("%02d" % (number + 1))
      ].compact.join('-')
    end
    private :server_name

    def prepare_run
    end
    private :prepare_run

    def bootstrap_server server, name
    end
    private :bootstrap_server

    def delete_vapp
    end
    private
  end
end
