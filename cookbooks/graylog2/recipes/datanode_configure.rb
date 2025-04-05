secrets = data_bag_item('graylog2', 'secrets')

node.override['graylog2']['server']['password_secret'] = secrets['password_secret']
node.override['graylog2']['server']['root_password_sha2'] = secrets['root_password_sha2']

template '/etc/graylog/datanode/datanode.conf' do
  source 'datanode.conf.erb'
  owner 'graylog'
  group 'graylog'
  mode '0644'
  variables(
    password_secret: node['graylog2']['server']['password_secret'],
    root_password_sha2: node['graylog2']['server']['root_password_sha2'],
    mongodb_host: node['graylog2']['mongodb']['host'],
    node_id_file: node['graylog2']['datanode']['node_id_file'],
    config_location: node['graylog2']['datanode']['config_location'],
    opensearch_http_port: node['graylog2']['datanode']['opensearch_http_port'],
    opensearch_transport_port: node['graylog2']['datanode']['opensearch_transport_port'],
    opensearch_location: node['graylog2']['datanode']['opensearch_location'],
    opensearch_config_location: node['graylog2']['datanode']['opensearch_config_location'],
    opensearch_data_location: node['graylog2']['datanode']['opensearch_data_location'],
    opensearch_logs_location: node['graylog2']['datanode']['opensearch_logs_location']
  )
  notifies :restart, 'service[graylog-datanode]'
end

log 'Check opensearch_location' do
  message "Opensearch location: #{node['graylog2']['datanode']['opensearch_location']}"
  level :info
end