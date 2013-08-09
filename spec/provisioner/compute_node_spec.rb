require 'spec_helper'
require 'provisioner/compute_node'

module Provisioner
  class DummyClass
    include ComputeNode
  end
end

describe 'Provisoner::ComputeNode' do

  it "should undeploy the vApp is running while delete action" do
    pending "mock not supported in fog"
  end

  it "should not undeploy the vApp is stopped while delete action" do
    pending "mock not supported in fog"
  end
end
