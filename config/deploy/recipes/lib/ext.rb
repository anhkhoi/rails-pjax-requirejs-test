module Capistrano; class Configuration; module Namespaces
  module PerServerTask
    # NOTE: your block must yield to a ServerDefinition instance
    # and an array of the roles that server has allocated
    def per_server_task(name, options = {}, &block)
      # define the overall task
      task(name, options) do
        servers = find_servers_for_task(current_task)
        # load a hash of server_name => roles_array
        server_roles = roles.inject({}) do |result,(key,value)|
          value.each do |s|
            result[s.to_s] ||= []
            result[s.to_s] << key
          end
          result
        end
        # loop through each server
        servers.each do |server|
          # define a task per server
          task_name = "#{name}_#{server.to_s}"
          task(task_name, options.merge(servers: server.to_s)) do
            # run the task body, yielding the server and it's roles
            block.yield(server, server_roles[server.to_s].uniq)
          end
          # invoke the task
          send(task_name)
        end
      end
    end
  end
end; end; end

Capistrano::Configuration::Namespaces::Namespace.send(:include, Capistrano::Configuration::Namespaces::PerServerTask)