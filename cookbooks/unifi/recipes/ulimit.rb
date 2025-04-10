execute 'Setting Ulimit' do
  command 'ulimit -n 65535'
end

file '/etc/security/limits.conf' do
  content <<-EOF
* soft nofile 65535
* hard nofile 65535
root soft nofile 65535
root hard nofile 65535
  EOF
  mode '0644'
  owner 'root'
  group 'root'
  action :create
end

execute 'reload_systemd' do
  command 'systemctl daemon-reload'
  action :run
end