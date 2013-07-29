module Gds
  module Provisioner
    class MasterProvisioner < Provisioner
      include ComputeNode

      def validate_options
        super
        unless options[:num_servers] == 1
          raise ConfigurationError, "You can only have one puppet master"
          # FIXME: And yet we don't query to check if one exists already
        end
      end

      def bootstrap_server server, name
        super
        notify "Run manual steps as specified in readme", name
      end
    end
  end
end
