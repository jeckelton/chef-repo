#
# Cookbook:: nec_rke2
# Recipe:: config
#

require 'chef/encrypted_data_bag_item'

config_dir = node['rke2']['config_dir']
node_ip = node['rke2']['node_ip'] || node['ipaddress']
bootstrap = node_ip == node['rke2']['bootstrap_node_ip']

unless node['rke2']['server_ips'].include?(node_ip)
  raise "Node IP #{node_ip} is not in node['rke2']['server_ips']: #{node['rke2']['server_ips'].join(', ')}"
end

token_cfg = node['rke2']['token']

token_item =
  if token_cfg['encrypted']
    Chef::EncryptedDataBagItem.load(token_cfg['data_bag'], token_cfg['item'])
  else
    data_bag_item(token_cfg['data_bag'], token_cfg['item'])
  end

cluster_token = token_item[token_cfg['key']]

if cluster_token.nil? || cluster_token.empty? || cluster_token.include?('REPLACE')
  raise "RKE2 cluster token is missing from #{token_cfg['data_bag']}/#{token_cfg['item']}"
end

directory config_dir do
  owner 'root'
  group 'root'
  mode '0700'
  recursive true
end

template "#{config_dir}/config.yaml" do
  source 'config.yaml.erb'
  owner 'root'
  group 'root'
  mode '0600'
  sensitive true
  variables(
    token: cluster_token,
    node_ip: node_ip,
    bootstrap: bootstrap,
    vip: node['rke2']['vip'],
    server_ips: node['rke2']['server_ips'],
    cluster_name: node['rke2']['cluster_name'],
    cluster_domain: node['rke2']['cluster_domain'],
    cni: node['rke2']['cni'],
    cluster_cidr: node['rke2']['cluster_cidr'],
    service_cidr: node['rke2']['service_cidr'],
    cluster_dns: node['rke2']['cluster_dns'],
    ingress_controller: node['rke2']['ingress_controller'],
    disable_kube_proxy: node['rke2']['disable_kube_proxy'],
    selinux: node['rke2']['selinux'],
    data_dir: node['rke2']['data_dir'],
    snapshot_schedule: node['rke2']['etcd']['snapshot_schedule_cron'],
    snapshot_retention: node['rke2']['etcd']['snapshot_retention'],
    snapshot_compress: node['rke2']['etcd']['snapshot_compress']
  )
  notifies :restart, 'service[rke2-server]', :delayed
end

service 'rke2-server' do
  action :nothing
end
