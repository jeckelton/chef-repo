package 'elasticsearch' do
  action :install
end
  
service 'elasticsearch' do
  action [:enable, :start]
end
