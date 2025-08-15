#
# Cookbook:: grafana
# Recipe:: default
#
# Copyright:: 2025, Jeremy, All Rights Reserved.

yum_repository 'grafana' do
  description 'Grafana OSS'
  baseurl 'https://rpm.grafana.com'
  repo_gpgcheck true
  enabled true
  gpgcheck true
  gpgkey 'https://rpm.grafana.com/gpg.key'
  sslverify true
  sslcacert '/etc/pki/tls/certs/ca-bundle.crt'
end

package 'grafana' do
  action :install
end

directory node['grafana']['ssl_dir'] do
  owner 'root'
  group 'grafana'
  mode '0750'
  recursive true
end

tls_data = data_bag_item('tls', 'wildcard')

file node['grafana']['cert_file'] do
  content tls_data['cert']
  owner 'root'
  group 'grafana'
  mode '0640'
end

file node['grafana']['cert_key'] do
  content tls_data['key']
  owner 'root'
  group 'grafana'
  mode '0640'
end

grafana_secrets = data_bag_item('grafana', 'grafana_secrets')
admin_password = grafana_secrets['admin_password']
prometheus_url = grafana_secrets['prometheus_url']

template "#{node['grafana']['config_path']}/grafana.ini" do
  source 'grafana.ini.erb'
  mode '0644'
  variables(
    admin_user: node['grafana']['admin_user'],
    admin_password: admin_password
  )
  notifies :restart, 'service[grafana-server]', :immediately
end

service 'grafana-server' do
  action [:enable, :start]
end

ruby_block 'wait_for_grafana' do
  block do
    require 'net/http'
    require 'uri'
    require 'openssl'

    uri = URI('https://grafana.fritz.box:3000/login')

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE  # <-- skip SSL verification

    until http.get(uri).is_a?(Net::HTTPOK)
      Chef::Log.info('Waiting for Grafana to start...')
      sleep 5
    end
  end
end

#cookbook_file '/tmp/prometheus-datasource.json' do
#  source 'prometheus-datasource.json'
#  mode '0644'
#end

#http_request 'add_prometheus_datasource' do
#  url 'http://localhost:3000/api/datasources'
#  message lazy {
#    file = Chef::JSONCompat.parse(::File.read('/tmp/prometheus-datasource.json'))
#    file['url'] = prometheus_url
#    file.to_json
#  }
#  headers({
#    'Content-Type' => 'application/json',
#    'Accept' => 'application/json',
#    'Authorization' => lazy {
#      "Basic #{Base64.strict_encode64("#{node['grafana']['admin_user']}:#{admin_password}")}"
#    }
#  })
#  action :post
#  retries 5
#  retry_delay 5
#end

include_recipe '::firewalld'