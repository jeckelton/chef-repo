#
# Cookbook:: node_exporter
# Recipe:: default
#
# Copyright:: 2025, Jeremy, All Rights Reserved.

package %w(wget tar)

group node['node_exporter']['group']
user node['node_exporter']['user'] do
  system true
  shell '/sbin/nologin'
  group node['node_exporter']['group']
end

[
  '/etc/node_exporter',
  '/etc/node_exporter/ssl',
  node['node_exporter']['install_dir'],
  node['node_exporter']['textfile_collector_dir']
].each do |dir|
  directory dir do
    owner node['node_exporter']['user']
    group node['node_exporter']['group']
    mode '0755'
    recursive true
  end
end


tls_data = data_bag_item('tls', 'wildcard')

file node['node_exporter']['ssl_node_cert'] do
  content tls_data['cert']
  owner node['node_exporter']['user']
  group node['node_exporter']['group']
  mode '0644'
end

file node['node_exporter']['ssl_node_key'] do
  content tls_data['key']
  owner node['node_exporter']['user']
  group node['node_exporter']['group']
  mode '0600'
end

file node['node_exporter']['ssl_ca_cert'] do
  content tls_data['ca']
  owner node['node_exporter']['user']
  group node['node_exporter']['group']
  mode '0644'
end

remote_file "/tmp/node_exporter.tar.gz" do
  source "https://github.com/prometheus/node_exporter/releases/download/v#{node['node_exporter']['version']}/node_exporter-#{node['node_exporter']['version']}.linux-amd64.tar.gz"
end

execute 'extract_node_exporter' do
  command "tar xvf /tmp/node_exporter.tar.gz -C #{node['node_exporter']['install_dir']} --strip-components=1"
  not_if { ::File.exist?("#{node['node_exporter']['install_dir']}/node_exporter") }
end

file '/etc/systemd/system/node_exporter.service' do
  content <<~SERVICE
    [Unit]
    Description=Node Exporter
    After=network.target

    [Service]
    User=#{node['node_exporter']['user']}
    Group=#{node['node_exporter']['group']}
    ExecStart=#{node['node_exporter']['install_dir']}/node_exporter \
      --web.listen-address=0.0.0.0:#{node['node_exporter']['port']} \
      --web.config.file=/etc/node_exporter/web.yml \
      --collector.textfile.directory=#{node['node_exporter']['textfile_collector_dir']}
    Restart=always

    [Install]
    WantedBy=multi-user.target
  SERVICE
  mode '0644'
  notifies :run, 'execute[reload systemd]', :immediately
end

execute 'reload systemd' do
  command 'systemctl daemon-reload && systemctl restart node_exporter'
  action :nothing
end

file '/etc/node_exporter/web.yml' do
  content <<~YML
    tls_server_config:
      cert_file: "#{node['node_exporter']['ssl_node_cert']}"
      key_file: "#{node['node_exporter']['ssl_node_key']}"
      #client_auth_type: "RequireAndVerifyClientCert" - Uncomment to enable mTLS with Prometheus
      #client_ca_file: "#{node['node_exporter']['ssl_ca_cert']}" - Uncomment to enable mTLS with Prometheus
  YML
  owner node['node_exporter']['user']
  group node['node_exporter']['group']
  mode '0644'
end

service 'node_exporter' do
  action [:enable, :start]
end

cookbook_file '/usr/local/bin/node_exporter_patch_metrics.sh' do
  source 'node_exporter_patch_metrics.sh'
  owner 'root'
  group 'root'
  mode '0755'
end

cron 'node_exporter_patch_metrics' do
  minute '0'
  hour '3'
  user 'root'
  command '/usr/local/bin/node_exporter_patch_metrics.sh'
end