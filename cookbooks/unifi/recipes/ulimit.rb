file '/etc/security/limits.d/unifi.conf' do
  content <<-EOH
    unifi soft nofile 65535
    unifi hard nofile 65535
  EOH
  owner 'root'
  group 'root'
  mode '0644'
end
  

execute 'reload_systemd' do
  command 'systemctl daemon-reload'
  action :nothing
end