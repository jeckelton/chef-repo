#
# Cookbook:: nec_k3s
# Recipe:: server
#
# Copyright:: 2026, NewCold Digital B.V., All Rights Reserved.

hostname = node['hostname']
primary = node['k3s']['primary_server']

is_primary = hostname == primary

template '/etc/rancher/k3s/config.yaml' do
  source 'k3s-config.yaml.erb'
  owner 'root'
  group 'root'
  mode '0600'
  variables(
    role: 'server',
    is_primary: is_primary
  )
  notifies :restart, 'service[k3s]', :delayed
end

execute 'install k3s server' do
  command lazy {
    install_cmd = "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='#{node['k3s']['version']}' sh -s - server"
    install_cmd
  }
  creates '/usr/local/bin/k3s'
end

service 'k3s' do
  action [:enable, :start]
end

include_recipe 'nec_k3s::kubeconfig'