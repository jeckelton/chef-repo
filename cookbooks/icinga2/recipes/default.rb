#
# Cookbook:: icinga2
# Recipe:: default
#
# Copyright:: 2025, Jeremy Eckelton, All Rights Reserved.

package %w(icinga2 mariadb-server php php-cli php-fpm php-mysql httpd icingaweb2 icingacli policycoreutils-python-utils) do
  action :install
end

service 'mariadb' do
  action [:enable, :start]
end

service 'icinga2' do
  action [:enable, :start]
end

service 'httpd' do
  action [:enable, :start]
end