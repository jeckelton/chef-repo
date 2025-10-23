default['graylog2']['version'] = '6.3'
default['graylog2']['repo_deb_url'] = "https://packages.graylog2.org/repo/packages/graylog-#{node['graylog2']['version']}-repository_latest.deb"
default['graylog2']['repo_deb_path'] = "/tmp/graylog-#{node['graylog2']['version']}-repository_latest.deb"

default['graylog2']['repo_rpm_url'] = "https://packages.graylog2.org/repo/el/stable/#{node['graylog2']['version']}/x86_64/graylog-#{node['graylog2']['version']}-repository-1-1.noarch.rpm"
default['graylog2']['repo_rpm_path'] = "/tmp/graylog-#{node['graylog2']['version']}-repository-1-2.noarch.rpm"

default['graylog2']['server']['is_leader'] = 'true'
default['graylog2']['server']['bin_dir'] = '/usr/share/graylog-server/bin'
default['graylog2']['server']['root_timezone'] = 'Europe/Amsterdam'
default['graylog2']['server']['data_dir'] = '/var/lib/graylog-server'
default['graylog2']['server']['plugin_dir'] = '/usr/share/graylog-server/plugin'
default['graylog2']['server']['node_id_file'] = '/etc/graylog/server/node-id'
default['graylog2']['server']['http_bind_address'] = '0.0.0.0'
default['graylog2']['server']['output_batch_size'] = '500'
default['graylog2']['server']['output_flush_interval'] = '1'
default['graylog2']['server']['output_fault_count_threshold'] = '5'
default['graylog2']['server']['output_fault_penalty_second'] = '30'
default['graylog2']['server']['processor_wait_strategy'] = 'blocking'
default['graylog2']['server']['ring_size'] = '65536'
default['graylog2']['server']['inputbuffer_ring_size'] = '65536'
default['graylog2']['server']['inputbuffer_processors'] = '2'
default['graylog2']['server']['inputbuffer_wait_strategy'] = 'blocking'
default['graylog2']['server']['message_journal_enabled'] = 'true'
default['graylog2']['server']['message_journal_dir'] = '/var/lib/graylog-server/journal'

default['graylog2']['datanode']['node_id_file'] = '/etc/graylog/datanode/node-id'
default['graylog2']['datanode']['config_location'] = '/etc/graylog/datanode'
default['graylog2']['datanode']['opensearch_http_port'] = '9200'
default['graylog2']['datanode']['opensearch_transport_port'] = '9300'
default['graylog2']['datanode']['datanode_http_port'] = '8999'
default['graylog2']['datanode']['opensearch_location'] = '/usr/share/graylog-datanode/dist'
default['graylog2']['datanode']['opensearch_config_location'] = '/var/lib/graylog-datanode/opensearch/config'
default['graylog2']['datanode']['opensearch_data_location'] = '/var/lib/graylog-datanode/opensearch/data'
default['graylog2']['datanode']['opensearch_logs_location'] = '/var/log/graylog-datanode/opensearch'

default['graylog2']['mongodb']['host'] = '127.0.0.1'
default['graylog2']['mongodb']['mongodb_max_connections'] = '1000'

