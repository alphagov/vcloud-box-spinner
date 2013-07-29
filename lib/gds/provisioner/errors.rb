module Gds
  module Provisioner
    # TODO: this should be some GDS error class
    class ProvisionerError < RuntimeError; end
    class ConfigurationError < ProvisionerError; end
    class NoSuchRole < ProvisionerError; end
  end
end
