require 'spec_helper'
require 'fog/vcloud/compute/shared'
require 'nokogiri'
require 'equivalent-xml'

describe Fog::Vcloud::Compute::Shared do
  let (:fog_vcloud_test_class) do
    Class.new do
      include Fog::Vcloud::Compute::Shared

      def xmlns
        {}
      end
    end
  end

  it 'should generate InstantiateVAppTemplateParams' do
    subject = fog_vcloud_test_class.new
    fog_xml = subject.send(:generate_instantiate_vapp_template_request, {:name => 'foo',
                                                         :description => 'bar',
                                                         :template_uri => 'baz'
                           })
    parsed = Nokogiri::XML(fog_xml)

    xml = ::Builder::XmlMarkup.new
    expected = xml.InstantiateVAppTemplateParams({:name => 'foo', :'xml:lang' => 'en'}) {
      xml.Description('bar')
      xml.InstantiationParams { }
      xml.Source(:href => 'baz')
      xml.AllEULAsAccepted("true")
    }
    parsed.should be_equivalent_to Nokogiri::XML(expected)
  end

  it 'should handle network_uri correctly' do
    subject = fog_vcloud_test_class.new
    fog_xml = subject.send(:generate_instantiate_vapp_template_request,
                           {:name => 'foo',
                             :description => 'bar',
                             :template_uri => 'baz',
                             :network_name => 'jimmy',
                             :network_uri => 'http://jimmy.invalid'
                           })

    xml = ::Builder::XmlMarkup.new
    expected = xml.InstantiateVAppTemplateParams({:name => 'foo', :'xml:lang' => 'en'}) {
      xml.Description('bar')
      xml.InstantiationParams {
        xml.NetworkConfigSection {
          xml.ovf :Info
          xml.NetworkConfig(:networkName => 'jimmy') {
            xml.Configuration {
              xml.ParentNetwork(:href => 'http://jimmy.invalid')
              xml.FenceMode 'bridged'
            }
          }
        }
      }
      xml.Source(:href => 'baz')
      xml.AllEULAsAccepted("true")
    }
    Nokogiri::XML(fog_xml).should be_equivalent_to Nokogiri::XML(expected)
  end
end
