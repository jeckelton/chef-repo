#
# Cookbook:: step_ca
# Recipe:: service
#
# Copyright:: 2026, Jeremy Eckelton, All Rights Reserved.

template '/etc/systemd/system/step-ca.service' do
  source 'step-ca.service.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
  notifies :restart, 'service[step-ca]', :delayed
end

execute 'systemctl daemon-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end

service 'step-ca' do
  action [:enable, :start]
end