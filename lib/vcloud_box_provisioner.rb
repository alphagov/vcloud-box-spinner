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
  def self.build options = {}
    options[:logger] ||= default_logger options
    options[:logger].debug "Building provisioner for #{options.inspect}"
    Provisioner::BlankProvisioner.new options
  end

  class << self
    attr_accessor :ssh_client
  end
  self.ssh_client = Net::SSH

  def self.default_logger options
    Logger.new(STDOUT).tap { |l| l.level = options[:log_level] || Logger::ERROR }
  end

end
