# Cookbook:: mem2incident
# Provider:: config

include Rbmem2incident::Helper

action :add do
  begin
    user = new_resource.user

    memcached_servers = new_resource.memcached_servers
    api_endpoint = new_resource.api_endpoint
    insecure_skip_verify = new_resource.insecure_skip_verify
    loop_interval = new_resource.loop_interval
    auth_token = new_resource.auth_token

    dnf_package 'redborder-mem2incident' do
      action :upgrade
    end

    execute 'create_user' do
      command "/usr/sbin/useradd -r #{user} -s /sbin/nologin"
      ignore_failure true
      not_if "getent passwd #{user}"
    end

    %w(/etc/redborder-mem2incident).each do |path|
      directory path do
        owner user
        group user
        mode '0755'
        action :create
      end
    end

    template '/etc/redborder-mem2incident/config.yml' do
      source 'config.yml.erb'
      owner user
      group user
      mode '0644'
      ignore_failure true
      cookbook 'mem2incident'
      variables(memcached_servers: memcached_servers,
                api_endpoint: api_endpoint,
                insecure_skip_verify: insecure_skip_verify,
                loop_interval: loop_interval,
                auth_token: auth_token)
      notifies :restart, 'service[redborder-mem2incident]', :delayed unless node['redborder']['leader_configuring']
    end

    service 'redborder-mem2incident' do
      service_name 'redborder-mem2incident'
      ignore_failure true
      supports status: true, restart: true, enable: true, start: true, stop: true
      if node['redborder']['leader_configuring']
        action [:enable, :stop]
      else
        action [:enable, :start]
      end
    end

    Chef::Log.info('Redborder mem2incident cookbook has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin
    service 'redborder-mem2incident' do
      service_name 'redborder-mem2incident'
      ignore_failure true
      supports status: true, enable: true
      action [:stop, :disable]
    end

    %w(/etc/redborder-mem2incident).each do |path|
      directory path do
        recursive true
        action :delete
      end
    end

    dnf_package 'redborder-mem2incident' do
      action :remove
    end

    Chef::Log.info('Redborder mem2incident cookbook has been removed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :register do
  begin
    unless node['redborder-mem2incident']['registered']
      query = {}
      query['ID'] = "redborder-mem2incident-#{node['hostname']}"
      query['Name'] = 'redborder-mem2incident'
      query['Address'] = "#{node['ipaddress']}"
      query['Port'] = 5000
      json_query = Chef::JSONCompat.to_json(query)

      execute 'Register service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/register -d '#{json_query}' &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['redborder-mem2incident']['registered'] = true
      Chef::Log.info('redborder-mem2incident service has been registered to consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :deregister do
  begin
    if node['redborder-mem2incident']['registered']
      execute 'Deregister service in consul' do
        command "curl -X PUT http://localhost:8500/v1/agent/service/deregister/redborder-mem2incident-#{node['hostname']} &>/dev/null"
        action :nothing
      end.run_action(:run)

      node.normal['redborder-mem2incident']['registered'] = false
      Chef::Log.info('redborder-mem2incident service has been deregistered from consul')
    end
  rescue => e
    Chef::Log.error(e.message)
  end
end
