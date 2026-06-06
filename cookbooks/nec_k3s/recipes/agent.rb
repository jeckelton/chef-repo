#
# Cookbook:: nec_k3s
# Recipe:: agent
#
# Copyright:: 2026, NewCold Digital B.V., All Rights Reserved.

template '/etc/rancher/k3s/config.yaml' do
  source 'k3s-config.yaml.erb'
  owner 'root'
  group 'root'
  mode '0600'
  variables(
    role: 'agent',
    is_primary: false
  )
  notifies :restart, 'service[k3s-agent]', :delayed
end

execute 'install k3s agent' do
  command lazy {
    "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='#{node['k3s']['version']}' sh -s - agent"
  }
  creates '/usr/local/bin/k3s'
end

service 'k3s-agent' do
  action [:enable, :start]
end
