require 'spec_helper'
require 'provisioner/compute_node'

module Provisioner
  class DummyClass
    include ComputeNode
  end
end

describe 'Provisoner::ComputeNode' do

  pending "should undeploy the vApp is running while delete action" do
  end

  pending "should not undeploy the vApp is stopped while delete action" do
  end
end
