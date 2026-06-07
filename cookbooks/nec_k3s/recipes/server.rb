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
    "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='#{node['k3s']['version']}' sh -s - server"
  }
  creates '/usr/local/bin/k3s'
end

service 'k3s' do
  action [:enable, :start]
end

directory node['k3s']['manifests_dir'] do
  recursive true
  owner 'root'
  group 'root'
  mode '0755'
  only_if { node['k3s']['kube_vip']['enabled'] }
end

template "#{node['k3s']['manifests_dir']}/kube-vip.yaml" do
  source 'kube-vip.yaml.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    api_vip: node['k3s']['api_vip'],
    api_port: node['k3s']['api_port'],
    api_interface: node['k3s']['api_interface'],
    kube_vip_version: node['k3s']['kube_vip']['version']
  )
  only_if { node['k3s']['kube_vip']['enabled'] }
end

include_recipe 'nec_k3s::kubeconfig'