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
    http_bind_address: node['graylog2']['server']['http_bind_address'],
    http_publish_uri: node['graylog2']['server']['http_publish_uri']
    output_batch_size: node['graylog2']['server']['output_batch_size'],
    output_flush_interval: node['graylog2']['server']['output_flush_interval'],
    output_fault_count_threshold: node['graylog2']['server']['output_fault_count_threshold'],
    output_fault_penalty_second: node['graylog2']['server']['output_fault_penalty_second'],
    processor_wait_strategy: node['graylog2']['server']['processor_wait_strategy'],
    ring_size: node['graylog2']['server']['ring_size'],
    inputbuffer_ring_size: node['graylog2']['server']['inputbuffer_ring_size'],
    inputbuffer_processors: node['graylog2']['server']['inputbuffer_processors'],
    inputbuffer_wait_strategy: node['graylog2']['server']['inputbuffer_wait_strategy'],
    message_journal_enabled: node['graylog2']['server']['message_journal_enabled'],
    message_journal_dir: node['graylog2']['server']['message_journal_dir']
  )
  notifies :restart, 'service[graylog-server]'
end
