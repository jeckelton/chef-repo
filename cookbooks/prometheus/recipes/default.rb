#
# Cookbook:: prometheus
# Recipe:: default
#
# Copyright:: 2025, Jeremy, All Rights Reserved.

package %w(wget tar)

group node['prometheus']['group']
user node['prometheus']['user'] do
  system true
  shell '/sbin/nologin'
  group node['prometheus']['group']
end

[
  node['prometheus']['install_dir'],
  node['prometheus']['config_dir'],
  node['prometheus']['data_dir'],
  "#{node['prometheus']['config_dir']}/ssl"
].each do |dir|
  directory dir do
    owner node['prometheus']['user']
    group node['prometheus']['group']
    mode '0755'
    recursive true
  end
end

tls_data = data_bag_item('tls', 'wildcard')
file node['prometheus']['ssl_server_cert'] do
  content tls_data['cert']
  owner node['prometheus']['user']
  group node['prometheus']['group']
  mode '0644'
end
file node['prometheus']['ssl_server_key'] do
  content tls_data['key']
  owner node['prometheus']['user']
  group node['prometheus']['group']
  mode '0600'
end

file node['prometheus']['ssl_ca_cert'] do
  content tls_data['ca']
  owner node['prometheus']['user']
  group node['prometheus']['group']
  mode '0644'
end

remote_file "/tmp/prometheus.tar.gz" do
  source "https://github.com/prometheus/prometheus/releases/download/v#{node['prometheus']['version']}/prometheus-#{node['prometheus']['version']}.linux-amd64.tar.gz"
end

execute 'extract_prometheus' do
  command "tar xvf /tmp/prometheus.tar.gz -C #{node['prometheus']['install_dir']} --strip-components=1"
  not_if { ::File.exist?("#{node['prometheus']['install_dir']}/prometheus") }
end

template "#{node['prometheus']['config_dir']}/prometheus.yml" do
  source 'prometheus.yml.erb'
  owner node['prometheus']['user']
  group node['prometheus']['group']
  mode '0644'
  notifies :restart, 'service[prometheus]', :immediately
end

file '/etc/systemd/system/prometheus.service' do
  content <<~SERVICE
    [Unit]
    Description=Prometheus Server
    After=network.target

    [Service]
    User=#{node['prometheus']['user']}
    Group=#{node['prometheus']['group']}
    ExecStart=#{node['prometheus']['install_dir']}/prometheus \
      --config.file=#{node['prometheus']['config_dir']}/prometheus.yml \
      --storage.tsdb.path=#{node['prometheus']['data_dir']} \
      --web.listen-address=:#{node['prometheus']['port']} \
      --web.config.file=#{node['prometheus']['config_dir']}/web.yml
    Restart=always

    [Install]
    WantedBy=multi-user.target
  SERVICE
  mode '0644'
end

# TLS config attempt
file "#{node['prometheus']['config_dir']}/web.yml" do
  content <<~YML
    tls_server_config:
      cert_file: "#{node['prometheus']['ssl_server_cert']}"
      key_file: "#{node['prometheus']['ssl_server_key']}"
  YML
  owner node['prometheus']['user']
  group node['prometheus']['group']
  mode '0644'
end

service 'prometheus' do
  action [:enable, :start]
end