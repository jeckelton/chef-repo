#
# Cookbook:: rundeck
# Recipe:: default
#
# Copyright:: 2025, Jeremy Eckelton, All Rights Reserved.

package %w(java-17-openjdk java-17-openjdk-devel mariadb mariadb-server) do
  action :install
end

service 'mariadb' do
  action [:enable, :start]
end

execute 'set-mariadb-root-password' do
  command "mysqladmin -u root password '#{node['rundeck']['db']['root_pw']}'"
  only_if "mysql -u root -e 'status' 2>&1 | grep -q 'Access denied'"
  not_if "mysql -uroot -p'#{node['rundeck']['db']['root_pw']}' -e 'status' >/dev/null 2>&1"
  ignore_failure true
end

bash 'create_rundeck_database' do
  code <<-EOH
    mysql -uroot -p'#{node['rundeck']['db']['password']}' -e "CREATE DATABASE IF NOT EXISTS #{node['rundeck']['db']['name']};"
    mysql -uroot -p'#{node['rundeck']['db']['password']}' -e "CREATE USER IF NOT EXISTS '#{node['rundeck']['db']['user']}'@'%' IDENTIFIED BY '#{node['rundeck']['db']['password']}';"
    mysql -uroot -p'#{node['rundeck']['db']['password']}' -e "GRANT ALL PRIVILEGES ON #{node['rundeck']['db']['name']}.* TO '#{node['rundeck']['db']['user']}'@'%'; FLUSH PRIVILEGES;"
  EOH
  not_if "mysql -uroot -p'#{node['rundeck']['db']['root_pw']}' -e 'use #{node['rundeck']['db']['name']}'"
end

yum_repository 'rundeck' do
  description      node['rundeck']['repo']['description']
  baseurl          node['rundeck']['repo']['baseurl']
  repo_gpgcheck    node['rundeck']['repo']['repo_gpgcheck']
  gpgcheck         node['rundeck']['repo']['gpgcheck']
  enabled          node['rundeck']['repo']['enabled']
  gpgkey           node['rundeck']['repo']['gpgkey']
  sslverify        node['rundeck']['repo']['sslverify']
  sslcacert        node['rundeck']['repo']['sslcacert']
  metadata_expire  node['rundeck']['repo']['metadata_expire']
  action           :create
end

package 'rundeck' do
  version node['rundeck']['version']
  action :install
end

service 'rundeckd' do
  action :nothing
end

ruby_block 'update_admin_password_in_realm_properties' do
  block do
    file_path = '/etc/rundeck/realm.properties'
    password  = node['rundeck']['admin']['password']
    newline   = "admin:#{password},user,admin,architect,deploy,build"

    fe = Chef::Util::FileEdit.new(file_path)
    fe.search_file_replace_line(/^admin:.*/, newline)
    fe.insert_line_if_no_match(/^admin:/, newline)
    fe.write_file
  end
  not_if { ::File.readlines('/etc/rundeck/realm.properties').grep(/^admin:#{Regexp.escape(password)}/).any? }
end

template '/etc/rundeck/framework.properties' do
  source 'framework.properties.erb'
  owner 'rundeck'
  group 'rundeck'
  mode '0640'
  variables(
    name: node['rundeck']['framework']['name'],
    server_url: node['rundeck']['framework']['server_url'],
    hostname: node['rundeck']['framework']['hostname'],
    port: node['rundeck']['framework']['port']
  )
  notifies :restart, 'service[rundeckd]', :delayed
end


template '/etc/rundeck/rundeck-config.properties' do
  source 'rundeck-config.properties.erb'
  owner 'rundeck'
  group 'rundeck'
  mode '0640'
  variables(
    server_url: node['rundeck']['framework']['server_url'],
    db_name: node['rundeck']['db']['name'],
    db_user: node['rundeck']['db']['user'],
    db_pass: node['rundeck']['db']['password'],
    db_driver: node['rundeck']['db']['driver']
  )
  notifies :restart, 'service[rundeckd]', :delayed
end
