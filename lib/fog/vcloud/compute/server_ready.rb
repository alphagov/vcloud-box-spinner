require 'fog/vcloud/models/compute/server'
module Fog
  module Vcloud
    class Compute
      class Server < Fog::Vcloud::Model
        def ready?
          reload_status
          running_tasks = tasks && tasks.flatten.any? do |task|
            task.kind_of?(Hash) && (task[:status] == 'running' && task[:Progress] != '100')
          end
          status != '0' && !running_tasks
        end
      end
    end
  end
end
