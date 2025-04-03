secrets = data_bag_item('graylog2', 'secrets')

node.override['graylog2']['server']['password_secret'] = secrets['password_secret']
node.override['graylog2']['server']['root_password_sha2'] = secrets['root_password_sha2']


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
    elasticsearch_cluster_name: node['graylog2']['elasticsearch']['cluster_name'],
    http_bind_address: node['graylog2']['server']['http_bind_address']
  )
  notifies :restart, 'service[graylog-server]'
end
