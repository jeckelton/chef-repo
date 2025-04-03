package 'firewalld' do
    action :install
  end
  
 service 'firewalld' do
  action [:enable, :start]
end
  
allowed_ports = [9200, 9000, 443, 22, 80, 514]
  
allowed_ports.each do |port|
  execute "open port #{port}" do
    command "firewall-cmd --permanent --add-port=#{port}/tcp"
    not_if "firewall-cmd --list-ports | grep -w #{port}/tcp"
    notifies :run, 'execute[reload firewalld]', :immediately
  end
end
  
execute 'reload firewalld' do
  command 'firewall-cmd --reload'
  action :nothing
end