#
# Cookbook:: icinga2
# Recipe:: windows_agent
#
# Copyright:: 2025, Jeremy Eckelton, All Rights Reserved.

if platform_family?('windows')
  icinga_version   = node['icinga2_ha']['icinga_version_windows']
  icinga_msi       = "Icinga2-v#{icinga_version}-x86_64.msi"
  icinga_url       = "https://packages.icinga.com/windows/#{icinga_msi}"
  icinga_installer = "C:\\Temp\\#{icinga_msi}"

  directory 'C:\\Temp' do
    action :create
  end

  remote_file icinga_installer do
    source icinga_url
    action :create
    not_if { ::File.exist?('C:\\Program Files\\ICINGA2\\sbin\\icinga2.exe') }
  end

  windows_package 'Icinga2' do
    source icinga_installer
    installer_type :msi
    action :install
  end

  service 'icinga2' do
    action [:enable, :start]
    supports status: true, restart: true
  end

  template 'C:\\ProgramData\\icinga2\\etc\\icinga2\\zones.conf' do
    source 'zones.conf.erb'
    variables(masters: node['icinga2_ha']['masters'])
    notifies :restart, 'service[icinga2]', :delayed
  end

  template 'C:\\ProgramData\\icinga2\\etc\\icinga2\\features-enabled\\api.conf' do
    source 'api.conf.erb'
    variables(fqdn: node['fqdn'])
    notifies :restart, 'service[icinga2]', :immediately
  end

  execute 'icinga2_request_cert' do
    command "\"C:\\Program Files\\ICINGA2\\sbin\\icinga2.exe\" pki new-cert --cn #{node['fqdn']} --key C:\\ProgramData\\icinga2\\var\\lib\\icinga2\\certs\\#{node['fqdn']}.key --cert C:\\ProgramData\\icinga2\\var\\lib\\icinga2\\certs\\#{node['fqdn']}.crt"
    not_if { ::File.exist?("C:\\ProgramData\\icinga2\\var\\lib\\icinga2\\certs\\#{node['fqdn']}.crt") }
    notifies :restart, 'service[icinga2]', :delayed
  end
end
