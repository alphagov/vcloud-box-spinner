require 'gds/provisioner/errors'
require 'gds/provisioner/provisioner'
require 'gds/provisioner/compute_node'
require 'gds/provisioner/client_provisioner'
require 'gds/provisioner/blank_provisioner'
require 'gds/provisioner/master_provisioner'
require 'gds/provisioner/cli'
require 'gds/provisioner/version'
require 'socket'
require 'logger'
require 'net/ssh'
require 'net/scp'
require 'erb'
require 'parallel'
require 'fog'

module Gds
  module Provisioner
    PROVISIONERS = {
      "client" => ClientProvisioner,
      "master" => MasterProvisioner,
      "blank"  => BlankProvisioner
    }.freeze

    def self.build options = {}
      options[:logger] ||= default_logger options
      options[:logger].debug "Building provisioner for #{options.inspect}"
      provisioner = provisioner_for_role options[:role]
      provisioner.new options
    end

    def self.provisioner_for_role role
      return Provisioner if role.to_s == ""
      return PROVISIONERS[role] if PROVISIONERS.key? role
      raise Gds::Provisioner::NoSuchRole,
        "I don't know how to provision the role `#{role}`"
    end

    class << self
      attr_accessor :ssh_client
    end
    self.ssh_client = Net::SSH

    def self.default_logger options
      Logger.new(STDOUT).tap { |l| l.level = options[:log_level] || Logger::ERROR }
    end

  end
end
