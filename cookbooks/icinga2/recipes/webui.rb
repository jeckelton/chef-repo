bash 'setup_web_permissions' do
  code <<-EOH
    chown -R nagios:nagios /etc/icingaweb2
    chown -R nagios:nagios /var/log/icingaweb2
  EOH
  only_if { ::Dir.exist?('/etc/icingaweb2') }
end

service 'php-fpm' do
  action [:enable, :start]
end

execute 'allow_httpd_php_fpm' do
  command 'setsebool -P httpd_execmem 1 && setsebool -P httpd_can_network_connect_db 1'
  only_if 'getenforce | grep Enforcing'
end

template '/etc/icingaweb2/resources.ini' do
  source 'resources.ini.erb'
  owner 'nagios'
  group 'nagios'
  mode '0640'
  variables(
    db_user: 'icinga',
    db_pass: node['icinga2_ha']['db']['icinga_password']
  )
end


