#
# Cookbook:: nec_rke2
# Recipe:: manifests
#
# RKE2 server manifests are cluster-wide AddOns. We manage them only on the
# bootstrap node to keep one authoritative copy.

node_ip = node['rke2']['node_ip'] || node['ipaddress']
bootstrap = node_ip == node['rke2']['bootstrap_node_ip']

return unless bootstrap

manifest_dir = node['rke2']['manifest_dir']

directory manifest_dir do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

template "#{manifest_dir}/rke2-cilium-config.yaml" do
  source 'rke2-cilium-config.yaml.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    hubble_enabled: node['rke2']['hubble']['enabled'],
    relay_enabled: node['rke2']['hubble']['relay_enabled'],
    ui_enabled: node['rke2']['hubble']['ui_enabled']
  )
end

template "#{manifest_dir}/kube-vip-rbac.yaml" do
  source 'kube-vip-rbac.yaml.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template "#{manifest_dir}/kube-vip.yaml" do
  source 'kube-vip.yaml.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    version: node['rke2']['kube_vip']['version'],
    vip: node['rke2']['vip'],
    interface: node['rke2']['interface'],
    services_enabled: node['rke2']['kube_vip']['services_enabled']
  )
end

template "#{node['rke2']['manifest_dir']}/rke2-traefik-config.yaml" do
  source 'rke2-traefik-config.yaml.erb'
  owner 'root'
  group 'root'
  mode '0644'
  only_if { node['rke2']['node_ip'] == node['rke2']['bootstrap_node_ip'] }
end