#
# Cookbook:: icinga2
# Recipe:: windows_agent
#
# Install and configure Icinga2 agent on Windows
#

if platform_family?('windows')

  icinga_version   = '2.11.4'
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

  # zones.conf (shared template)
  template 'C:\\ProgramData\\icinga2\\etc\\icinga2\\zones.conf' do
    source 'zones.conf.erb'
    variables(
      masters: node['icinga2_ha']['masters']
    )
    # Windows services don't support :reload, use :restart instead
    notifies :restart, 'service[icinga2]', :delayed
  end

  # api.conf (shared template)
  template 'C:\\ProgramData\\icinga2\\etc\\icinga2\\features-enabled\\api.conf' do
    source 'api.conf.erb'
    variables(
      fqdn: node['fqdn']
    )
    notifies :restart, 'service[icinga2]', :immediately
  end

  # Optional: certificate bootstrap
  execute 'icinga2_request_cert' do
    command "\"C:\\Program Files\\ICINGA2\\sbin\\icinga2.exe\" pki new-cert --cn #{node['fqdn']} --key C:\\ProgramData\\icinga2\\var\\lib\\icinga2\\certs\\#{node['fqdn']}.key --cert C:\\ProgramData\\icinga2\\var\\lib\\icinga2\\certs\\#{node['fqdn']}.crt"
    not_if { ::File.exist?("C:\\ProgramData\\icinga2\\var\\lib\\icinga2\\certs\\#{node['fqdn']}.crt") }
    notifies :restart, 'service[icinga2]', :delayed
  end

end
