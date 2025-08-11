package 'firewalld' do
  action :install
end
  
service 'firewalld' do
  action [:enable, :start]
end
  
ports = [
  '3000/tcp',
  '9090/tcp',
  '9100/tcp'
]
  
ports.each do |port|
  execute "open-firewalld-port-#{port}" do
    command "firewall-cmd --permanent --add-port=#{port}"
    not_if "firewall-cmd --list-ports | grep -w #{port}"
    notifies :run, 'execute[reload-firewalld]', :delayed
  end
end
  
execute 'reload-firewalld' do
  command 'firewall-cmd --reload'
  action :nothing
end