directory '/var/log/icingaweb2' do
  owner 'www-data'
  group 'www-data'
  mode '0755'
  recursive true
  action :create
end

bash 'setup_web_permissions' do
  code <<-EOH
    chown -R www-data:www-data /etc/icingaweb2
    chown -R www-data:www-data /var/log/icingaweb2
  EOH
  only_if { ::Dir.exist?('/etc/icingaweb2') }
end

ruby_block 'detect_php_fpm_service' do
  block do
    require 'mixlib/shellout'
    cmd = Mixlib::ShellOut.new("systemctl list-units --type=service --all | grep php.*fpm.service | awk '{print $1}' | head -n1")
    cmd.run_command
    cmd.error!
    node.run_state['php_fpm_service'] = cmd.stdout.strip
  end
  action :run
end

service 'php-fpm-dynamic' do
  service_name lazy { node.run_state['php_fpm_service'] || 'php-fpm' }
  action [:enable, :start]
end

execute 'allow_httpd_php_fpm' do
  command 'setsebool -P httpd_execmem 1 && setsebool -P httpd_can_network_connect_db 1'
  only_if 'getenforce | grep Enforcing'
end

template '/etc/icingaweb2/resources.ini' do
  source 'resources.ini.erb'
  owner 'www-data'
  group 'www-data'
  mode '0640'
  variables(
    db_user: 'icinga',
    db_pass: node['icinga2_ha']['db']['icinga_password']
  )
end