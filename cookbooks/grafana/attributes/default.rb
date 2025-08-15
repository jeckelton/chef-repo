default['grafana']['config_path'] = '/etc/grafana'
default['grafana']['ssl_dir'] = "#{node['grafana']['config_path']}/ssl"
default['grafana']['cert_file'] = "#{node['grafana']['ssl_dir']}/wildcard.fritz.box.crt"
default['grafana']['cert_key']  = "#{node['grafana']['ssl_dir']}/wildcard.fritz.box.key"
default['grafana']['admin_user']  = 'admin'