file '/etc/security/limits.conf' do
  content <<-EOH
* soft nofile 65535
* hard nofile 65535
root soft nofile 65535
root hard nofile 65535
  EOH
  notifies :run, 'execute[reload_systemd]', :immediately
end
  
  execute 'reload_systemd' do
    command 'systemctl daemon-reload'
    action :nothing
  end