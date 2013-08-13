require 'spec_helper'
require 'provisioner/provisioner'
require 'provisioner/compute_node'

module Provisioner
  class DummyClass < Provisioner
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

  it "should not error out if option setup_script not provided" do
    pending "mocks not supported in fog"
  end
end
