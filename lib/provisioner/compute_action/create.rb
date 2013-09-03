module Provisioner
  module ComputeAction
    module Create

      def launch_server name
        super

        vapp = provision(name, options)

        # FIXME: enable this...
        #wait_for_vmware_tools(server)

        vapp.vms.each do |vm|
          update_guest_customization_options(vm, options)
          update_network_connection_options(vm, options)
          update_machine_resources(vm, options)
          vm.power_on
        end

        vapp
      end

      def launch_servers
        super
      end

      def prepare_run
        super
      end

      # Should this be private?
      # TODO: make this work with vcloud_director
      #def wait_for_vmware_tools(server)
      #  logger.debug("cycling power to identify VMware Tools...")
      #
      #  server.power_on
      #  server.wait_for { server.ready? }
      #  server.wait_for(90) { attributes[:children][:RuntimeInfoSection][:VMWareTools] }
      #
      #  server.undeploy
      #  server.wait_for { server.ready? }
      #end

      private

      def provision(name, options)
        logger.debug "User data for #{name}: #{user_data}"

        org = compute.organizations.get_by_name(compute.org_name)
        vdc = org.vdcs.get_by_name(options[:vdc_name])

        catalog = org.catalogs.get_by_name('Default')
        template = catalog.catalog_items.get_by_name(options[:template_name])
        network = org.networks.get_by_name(options[:network_name])

        template.instantiate(options[:vm_name], {:vdc_id => vdc.id, :network_id => network.id}) || abort
        vdc.vapps.get_by_name(options[:vm_name])
      end

      def update_guest_customization_options(vm, options)
        logger.debug "VM attributes: #{vm.attributes}"
        customization = vm.customization
        customization.computer_name = options[:vm_name]
        customization.enabled = true
        customization.script = user_data
        customization.save
      end

      def update_machine_resources(vm, options)
        vm.cpu = options[:num_cores] unless vm.cpu == options[:num_cores]
        vm.memory = options[:memory] unless vm.memory == options[:memory]
      end

      def update_network_connection_options(vm, options)
        logger.debug "VM attributes: #{vm.attributes}"

        network = vm.network

        network.network_connections[0][:network] = options[:network_name]
        network.network_connections[0][:ip_address] = options[:ip]
        network.network_connections[0][:ip_address_allocation_mode] = 'MANUAL'
        network.network_connections[0][:is_connected] = true

        network.save
        network.reload
      end

      def user_data
        user_data_files.map {|f| File.read(f)}.join("\n")
      end

      def user_data_files
        options[:setup_script].nil? ? [] : [File.expand_path(options[:setup_script])]
      end

    end
  end
end
