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
    stub_vcloud_requests 'api-ep', 'bazinga'
    logger = mock(:debug => true)
    provisioner = Provisioner::DummyClass.new :logger => logger,
      :password => 'booga',
      :host => 'api-ep',
      :vdc_uri => 'https://api-ep/api/vdc/234',
      :catalog_id => 'https://api-ep/api/catalog/345'
    provisioner.launch_server 'dummy'
  end
end

def stub_vcloud_requests api_host, org_name
  stub_request(:post, "https://#{api_host}/api/sessions").
         to_return(:status => 200, :body => "", :headers => {})
  stub_request(:get, "https://#{api_host}/api/org/").
         to_return(:status => 200,
                   :body => "<?xml version='1.0' encoding='UTF-8'?><OrgList><Org type='application/vnd.vmware.vcloud.org+xml' name='#{org_name}' href='https://#{api_host}/api/org/123'/></OrgList>",
                   :headers => {})
  stub_request(:get, "https://#{api_host}/api/org/123").
         to_return(:status => 200, :body => "<?xml version='1.0' encoding='UTF-8'?><Org xmlns='http://www.vmware.com/vcloud/v1.5' name='#{org_name}'><Link type='application/vnd.vmware.vcloud.vdc+xml' name='vdc_name' href='https://#{api_host}/api/vdc/234'/><Link type='application/vnd.vmware.vcloud.catalog+xml' name='Default' href='https://#{api_host}/api/catalog/345'/></Org>", :headers => {})
  stub_request(:get, "https://api-ep/api/catalog/345").
         to_return(:status => 200, :body => "<?xml version='1.0' encoding='UTF-8'?><Catalog xmlns='http://www.vmware.com/vcloud/v1.5' name='Default'><CatalogItems><CatalogItem type='application/vnd.vmware.vcloud.catalogItem+xml' name='image' href='https://#{api_host}/345'/></CatalogItems><Entity type='application/vnd.vmware.vcloud.vAppTemplate+xml' name='image' href='https://#{api_host}/api/vAppTemplate/vappTemplate-345'/></Catalog>", :headers => {})
end
