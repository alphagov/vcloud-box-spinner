require 'cgi'
require 'builder'
require 'fog/vcloud/compute/shared' # our hack
require 'fog/vcloud/compute/server_ready' # another hack
require 'nokogiri'

module Provisioner
  module ComputeNode
    def user_data_files
      [File.expand_path(options[:setup_script])]
    end
    private :user_data_files

    def user_data
      user_data_files.map { |f|
        File.read(f)
      }.join("\n")
    end
    private :user_data

    def provision(name, options)
      logger.debug "User data for #{name}: #{user_data}"
      server = compute.servers.create(
        :vdc_uri            => options[:vdc_id],
        :catalog_item_uri   => options[:catalog_id],
        :name               => options[:vm_name],
        :network_uri        => options[:network_uri],
        :network_name       => options[:network_name],
        :user_data          => user_data,
        :connection_options => {
          :ssl_verify_peer   => false,
          :omit_default_port => true
        }
      )
      notify "Waiting for server to come up", name
      server.wait_for { server.ready? }
      server
    end

    def modify_xml(url, mime_type)
      connection = compute.servers.service
      xml = Nokogiri::XML(connection.request(:uri => url).body)
      yield xml
      connection.request(:uri => url,
                                         :expects => 202,
                                         :method => 'PUT',
                                         :body => xml.to_s,
                                         :headers => {'Content-Type' => mime_type})
    end

    def update_guest_customization_options(server, options)
      logger.debug "server attributes: #{server.attributes}"
      customization_options = compute.servers.service.get_customization_options(server.attributes[:children][:href]).body
      guest_customization_section = customization_options[:GuestCustomizationSection]

      response = modify_xml(guest_customization_section[:href], guest_customization_section[:type]) do |xml|
        xml.at_css('ComputerName').content = options[:vm_name]
        if xml.at_css('CustomizationScript').nil?
         xml.at_css('ComputerName').before("<CustomizationScript>#{CGI.escapeHTML(user_data)}</CustomizationScript>\n")
        else
         xml.at_css('CustomizationScript').content = user_data
        end
        logger.debug(xml.to_xml)
      end

      wait_for_task(server, extract_task_uri(response))
      server.wait_for { server.ready? }
    end

    def update_machine_resources(server, options)
      update(server, "cpu", options[:num_cores])
      update(server, "memory", options[:memory])

      server.wait_for { server.ready? }
    end

    def update(server, resource_type, value)
      virtual_hardware_section_links = server.attributes[:children]['ovf:VirtualHardwareSection'.to_sym][:Link]
      edit_link = virtual_hardware_section_links.select { |item|  item[:href].include?(resource_type) && item[:rel] == "edit" }.first

      response = modify_xml(edit_link[:href], edit_link[:type]) do |xml|
        xml.at_xpath('//rasd:VirtualQuantity').content = value
      end

      wait_for_task(server, extract_task_uri(response))
    end

    def extract_task_uri(response)
      response_xml = Nokogiri::XML(response.body)
      response_xml.at_css("Task").attributes['href'].value
    end

    def wait_for_task(server, task_uri)
      connection = compute.servers.service

      server.wait_for do
        puts "... "
        task = Nokogiri::XML(connection.request(:uri => task_uri, :expects => 200).body)
        task.at_css("Task").attributes['status'].value == 'success'
      end
    end

    def update_network_connection_options(server, options)
      connection = compute.servers.service
      network_connection_section = server.attributes[:children][:NetworkConnectionSection][:Link]
      logger.debug "server attributes: #{server.attributes}"
      logger.debug "NetworkConnectionSection #{network_connection_section}"

      response = modify_xml(network_connection_section[:href], network_connection_section[:type]) do |xml|
        if options[:ip]
          if xml.at_css('IpAddress').nil?
            xml.at_css('IsConnected').before("<IpAddress>#{options[:ip]}</IpAddress>\n")
          else
            xml.at_css('IpAddress').content = options[:ip]
          end
          xml.at_css('IpAddressAllocationMode').content = 'MANUAL'
        else
          xml.at_css('IpAddressAllocationMode').content = 'POOL'
        end
        xml.at_css('NetworkConnection')[:network] = options[:network_name]
        xml.at_css('IsConnected').content = 'true'
      end

      wait_for_task(server, extract_task_uri(response))
      server.wait_for { server.ready? }
    end

    def power_on(server)
      connection = compute.servers.service
      power_on_uri = server.links.find {|link| link[:rel] == 'power:powerOn' }[:href]
      connection.request(:uri => power_on_uri, :method => "POST", :expects => 202)
    end

    def wait_for_vms_to_appear(server, options)
      100.times.each do |x|
        logger.debug("waiting for vm to spin up...")
        if server.attributes[:children] && server.attributes[:children][:href]
          return
        end
        sleep 1
      end

      if !server.attributes[:children] || !server.attributes[:children][:href]
        abort "vm didn't properly spin up"
      end
    end

    private :provision, :update_guest_customization_options, :update_network_connection_options, :power_on

    def launch_server name
      super
      server = provision(name, options)

      wait_for_vms_to_appear(server, options)

      update_guest_customization_options(server, options)
      update_network_connection_options(server, options)
      update_machine_resources(server, options)

      power_on(server)

      server
    end

    def launch_servers
      super
    end

    def prepare_run
      super
    end
  end
end
