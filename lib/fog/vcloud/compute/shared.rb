require 'builder'
require 'fog/vcloud/compute'
require 'fog/vcloud/requests/compute/instantiate_vapp_template'

module Fog::Vcloud::Compute::Shared
  private
  def generate_instantiate_vapp_template_request(options)
    xml = ::Builder::XmlMarkup.new
    xml.InstantiateVAppTemplateParams(xmlns.merge!(:name => options[:name], :"xml:lang" => "en")) {
      xml.Description(options[:description])
      xml.InstantiationParams {
        if options[:network_uri]
          # TODO - implement properly
          xml.NetworkConfigSection {
            xml.ovf :Info
            xml.NetworkConfig(:networkName => options[:network_name]) {
              xml.Configuration {
                xml.ParentNetwork(:href => options[:network_uri])
                xml.FenceMode 'bridged'
              }
            }
          }
        end
      }
      # The template
      xml.Source(:href => options[:template_uri])
      xml.AllEULAsAccepted("true")
    }
  end
end
