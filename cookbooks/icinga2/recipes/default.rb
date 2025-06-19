#
# Cookbook:: icinga2
# Recipe:: default
#
# Copyright:: 2025, Jeremy Eckelton, All Rights Reserved.

if platform_family?('debian')
  execute 'add icinga repo' do
    command <<-EOH
      curl https://packages.icinga.com/icinga.key | gpg --dearmor > /usr/share/keyrings/icinga-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/icinga-archive-keyring.gpg] https://packages.icinga.com/debian icinga-bullseye main" > /etc/apt/sources.list.d/icinga.list
      apt-get update
    EOH
    not_if { ::File.exist?('/etc/apt/sources.list.d/icinga.list') }
  end
end

case node['platform_family']
when 'rhel'
  package %w(icinga2 vim mariadb-server php php-cli php-fpm php-mysqlnd httpd icingaweb2 icingacli)
when 'debian'
  package %w(icinga2 vim mariadb-server php php-cli php-fpm php-mysql apache2 icingaweb2 icingacli)
end

service 'mariadb' do
  action [:enable, :start]
end

service 'icinga2' do
  action [:enable, :start]
end

service (platform_family?('rhel') ? 'httpd' : 'apache2') do
  action [:enable, :start]
end

execute 'enable_icinga2_features' do
  command 'icinga2 feature enable api ido-mysql checker mainlog'
  not_if 'icinga2 feature list | grep -q "ido-mysql\s*\*\*"'
  notifies :reload, 'service[icinga2]', :delayed
end

template '/etc/icinga2/zones.conf' do
  source 'zones.conf.erb'
  variables(
    masters: node['icinga2_ha']['masters']
  )
  notifies :reload, 'service[icinga2]', :delayed
end

cookbook_file '/usr/local/bin/pki_setup.sh' do
  source 'pki_setup.sh'
  mode '0755'
end

execute 'setup_pki' do
  command "/usr/local/bin/pki_setup.sh #{node['hostname']}"
  not_if { ::File.exist?("/etc/icinga2/pki/#{node['hostname']}.crt") }
  notifies :reload, 'service[icinga2]', :delayed
end

include_recipe '::mariadb'
include_recipe '::webui'