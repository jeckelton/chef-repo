package 'firewalld' do
  action :install
end
  
service 'firewalld' do
  action [:enable, :start]
end
  
ports = [
  '3478/udp',
  '10001/udp',
  '8080/tcp',
  '8443/tcp',
  '1900/udp',
  '8843/tcp',
  '8880/tcp',
  '4440/tcp',
  '6789/tcp'
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