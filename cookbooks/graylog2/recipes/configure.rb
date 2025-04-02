template '/etc/graylog/server/server.conf' do
  source 'server.conf.erb'
  owner 'graylog'
  group 'graylog'
  mode '0644'
  variables(
    password_secret: node['graylog2']['server']['password_secret'],
    root_password_sha2: node['graylog2']['server']['root_password_sha2'],
    mongodb_host: node['graylog2']['mongodb']['host'],
    elasticsearch_host: node['graylog2']['elasticsearch']['host'],
    elasticsearch_cluster_name: node['graylog2']['elasticsearch']['cluster_name']
  )
  notifies :restart, 'service[graylog-server]'
end
