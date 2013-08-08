module Provisioner
  module ComputeAction
    module Delete

      def delete_vapp
        super
        vapp_href = compute.servers.service.vapps.detect {|v| v.name == options[:vm_name] }.href
        vapp = compute.servers.service.get_vapp(vapp_href)
        if vapp.on? or (vapp.off? and vapp.deployed)
          logger.debug "The vApp is running, stopping it..."
          vapp.service.undeploy vapp_href
          logger.debug "Waiting for vApp to stop ..."
          vapp.wait_for { vapp.off? }
        end
        vapp.wait_for { vapp.off? } #double check

        # This is added as vapp after being off, might still
        # be in a state which isn't ready. This would check
        # status of each vm associated with vapp
        vapp.servers.entries.each { |server| server.wait_for { server.ready? } }

        logger.debug "The vApp is not running now ..."
        logger.debug "Deleting the vApp"
        vapp.service.delete_vapp vapp_href
      end

    end
  end
end
