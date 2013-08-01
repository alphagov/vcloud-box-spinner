require 'provisioner/errors'
require 'provisioner/provisioner'
require 'provisioner/compute_node'
require 'provisioner/blank_provisioner'
require 'provisioner/cli'
require 'provisioner/version'
require 'socket'
require 'logger'
require 'net/ssh'
require 'net/scp'
require 'erb'
require 'parallel'
require 'fog'

module VcloudBoxProvisioner
  PROVISIONERS = {
    "blank"  => Provisioner::BlankProvisioner
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
    raise Provisioner::NoSuchRole,
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
