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

file '/etc/icingaweb2/config.ini' do
  content <<~EOF
    [global]
    authentication = "db"

    [logging]
    log_file = /var/log/icingaweb2/icingaweb2.log
    log_level = "debug"
  EOF
  owner 'www-data'
  group 'www-data'
  mode '0640'
  action :create
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

execute 'enable apache mods' do
  command 'a2enmod proxy_fcgi setenvif'
  not_if 'apache2ctl -M | grep proxy_fcgi_module'
  notifies :reload, 'service[apache2]', :delayed
end

service 'php-fpm-dynamic' do
  service_name lazy { node.run_state['php_fpm_service'] || 'php-fpm' }
  action [:enable, :start]
end

execute 'allow_httpd_php_fpm' do
  command 'setsebool -P httpd_execmem 1 && setsebool -P httpd_can_network_connect_db 1'
  only_if 'getenforce | grep Enforcing'
end

template '/etc/apache2/sites-available/icingaweb2.conf' do
  source 'icingaweb2.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables()
  action :create
  notifies :reload, 'service[apache2]', :delayed
end

execute 'enable icingaweb2 site' do
  command 'a2ensite icingaweb2'
  not_if 'a2query -s | grep icingaweb2'
  notifies :reload, 'service[apache2]', :delayed
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

service 'apache2' do
  action [:enable, :start]
end