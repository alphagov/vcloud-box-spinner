require 'cgi'
require 'builder'
require 'fog/vcloud/compute/shared' # our hack
require 'fog/vcloud/compute/server_ready' # another hack
require 'nokogiri'
require 'provisioner/compute_action/create'
require 'provisioner/compute_action/delete'

module Provisioner
  module ComputeNode
    include ComputeAction::Create
    include ComputeAction::Delete
  end
end
