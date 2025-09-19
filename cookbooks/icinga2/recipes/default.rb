#
# Cookbook:: icinga2
# Recipe:: default
#
# Copyright:: 2025, Jeremy Eckelton, All Rights Reserved.

include_recipe '::firewalld'

# Debian repo setup
if platform_family?('debian')
  execute 'add icinga repo' do
    command <<-EOH
      curl https://packages.icinga.com/icinga.key | gpg --dearmor > /usr/share/keyrings/icinga-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/icinga-archive-keyring.gpg] https://packages.icinga.com/debian icinga-bookworm main" > /etc/apt/sources.list.d/icinga.list
      apt-get update
    EOH
    not_if { ::File.exist?('/etc/apt/sources.list.d/icinga.list') }
  end
end

# Packages
case node['platform_family']
when 'rhel'
  package %w(
    icinga2 vim mariadb-server php php-cli php-fpm php-mysqlnd httpd
    icingaweb2 icingacli icinga2-ido-mysql icingaweb2-module-businessprocess
    icingaweb2-module-director
  )
when 'debian'
  package %w(
    icinga2 vim mariadb-server php php-cli php-fpm php-mysql apache2
    icingaweb2 icingacli icinga2-ido-mysql icingaweb2-module-businessprocess
    icingaweb2-module-director
  )
end

# Services
service 'mariadb' do
  action [:enable, :start]
end

service 'icinga2' do
  action [:enable, :start]
  supports status: true, restart: true, reload: true
end

service (platform_family?('rhel') ? 'httpd' : 'apache2') do
  action [:enable, :start]
end

# HA zones
template '/etc/icinga2/zones.conf' do
  source 'zones.conf.erb'
  variables(masters: node['icinga2_ha']['masters'])
  notifies :reload, 'service[icinga2]', :delayed
end

# PKI
cookbook_file '/usr/local/bin/pki_setup.sh' do
  source 'pki_setup.sh'
  mode '0755'
end

execute 'setup_pki' do
  command "/usr/local/bin/pki_setup.sh #{node['fqdn']}"
  not_if { ::File.exist?("/var/lib/icinga2/certs/#{node['fqdn']}.crt") }
  notifies :reload, 'service[icinga2]', :delayed
end

# API
template '/etc/icinga2/features-enabled/api.conf' do
  source 'api.conf.erb'
  variables(fqdn: node['fqdn'])
  notifies :restart, 'service[icinga2]', :immediately
end

template '/etc/icinga2/conf.d/api-user.conf' do
  source 'api-user.conf.erb'
  variables(api_pass: node['icinga2_ha']['web']['api_password'])
  notifies :restart, 'service[icinga2]', :immediately
end

# Database setup
include_recipe '::mariadb'

# WebUI setup
include_recipe '::webui'

# Enable Director module
execute 'enable_director_module' do
  command 'icingacli module enable director'
  user 'www-data'
  environment({ 'HOME' => '/var/www' })
  not_if 'icingacli module list | grep director'
  notifies :reload, 'service[apache2]', :immediately if platform_family?('debian')
  notifies :reload, 'service[httpd]', :immediately if platform_family?('rhel')
end
