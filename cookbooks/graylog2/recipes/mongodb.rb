package 'mongodb-org' do
  action :install
end
  
service 'mongod' do
  action [:enable, :start]
end
