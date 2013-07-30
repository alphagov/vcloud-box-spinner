require 'resolv'

module Provisioner
  class ClientProvisioner < Provisioner
    include ComputeNode

    def validate_options
      super
      unless options[:master]
        raise ConfigurationError, "Puppet master must be specified in order to provision a client"
      end
    end

    def prepare_run
      super
      test_ssh_master

      # TODO
      # Remove once the Ruby 1.8/1.9 interop certificate bug is fixed
      # http://dxul.puppetlabs.com/issues/8858
      # See if we need any dns transalations
      options[:master_ip] = options[:master]
      logger.info "Puppet Master internal IP is #{options[:master_ip]}"
    end

    def test_ssh_master
      logger.info "Testing SSH to PuppetMaster"
      ssh_to options[:puppetmaster] { |ssh| ssh.exec!("true") }
    end

    def bootstrap_server server, name
      super
      notify "Waiting for client certificate request on #{options[:puppetmaster]}", name
      ssh_to options[:puppetmaster] do |ssh|
        notify ssh.exec!("while :; do sudo puppet cert list | grep '#{server.name}.#{options[:domain]}' && break; sleep 1; done"), name
        notify "Signing client certificate on Puppet master", name
        notify ssh.exec!("sudo puppet cert sign #{server.name}.#{options[:domain]}"), name
      end
    end
  end
end
