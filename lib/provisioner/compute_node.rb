require 'cgi'
require 'builder'
require 'nokogiri'
require 'provisioner/compute_action/create'
require 'provisioner/compute_action/delete'

module Provisioner
  module ComputeNode
    include ComputeAction::Create
    include ComputeAction::Delete
  end
end
