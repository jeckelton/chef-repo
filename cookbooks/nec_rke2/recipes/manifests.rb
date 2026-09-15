#
# Cookbook:: nec_rke2
# Recipe:: manifests
#
# RKE2 server manifests are cluster-wide AddOns. We manage them only on the
# bootstrap node to keep one authoritative copy.
#

node_ip = node['rke2']['node_ip'] || node['ipaddress']
bootstrap = node_ip == node['rke2']['bootstrap_node_ip']

Chef::Log.info(
  "RKE2 manifest management: node_ip=#{node_ip}, " \
  "bootstrap_node_ip=#{node['rke2']['bootstrap_node_ip']}, " \
  "bootstrap=#{bootstrap}"
)

return unless bootstrap

manifest_dir = node['rke2']['manifest_dir']

#
# RKE2 manifest directory
#
directory manifest_dir do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

#
# Cilium configuration
#
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

#
# kube-vip RBAC
#
template "#{manifest_dir}/kube-vip-rbac.yaml" do
  source 'kube-vip-rbac.yaml.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

#
# kube-vip control-plane VIP
#
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

#
# RKE2 Traefik configuration
#
# Configure the RKE2-managed Traefik service as a LoadBalancer.
# Cilium LB IPAM/L2 announcements will provide the external IP.
#
template "#{manifest_dir}/rke2-traefik-config.yaml" do
  source 'rke2-traefik-config.yaml.erb'
  owner 'root'
  group 'root'
  mode '0644'
end