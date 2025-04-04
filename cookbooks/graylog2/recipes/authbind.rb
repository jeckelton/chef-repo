package 'authbind' do
    action :install
  end


file '/etc/authbind/byport/514' do
  owner 'graylog'
  group 'graylog'
  mode '0500'
  action :create
end

directory '/etc/systemd/system/graylog-server.service.d' do
  recursive true
  action :create
end

file '/etc/systemd/system/graylog-server.service.d/authbind.conf' do
  content <<~EOF
    [Service]
    ExecStart=
    ExecStart=/usr/bin/authbind --deep /usr/share/graylog-server/bin/graylog-server
  EOF
  owner 'root'
  group 'root'
  mode '0644'
  action :create
  notifies :run, 'execute[systemctl-daemon-reload]', :immediately
  notifies :restart, 'service[graylog-server]', :delayed
end

execute 'systemctl-daemon-reload' do
  command 'systemctl daemon-reexec && systemctl daemon-reload'
  action :nothing
end

service 'graylog-server' do
  action :nothing
end