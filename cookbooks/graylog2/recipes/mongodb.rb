execute 'add_mongodb_key' do
  command 'wget -qO - https://pgp.mongodb.com/server-7.0.asc | apt-key add -'
  action :run
  not_if 'apt-key list | grep "MongoDB"'
end

file '/etc/apt/sources.list.d/mongodb-org-7.0.list' do
  content 'deb [ arch=amd64 ] https://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main'
  mode '0644'
  not_if 'test -f /etc/apt/sources.list.d/mongodb-org-7.0.list'
end

execute 'apt_update' do
  command 'apt-get update'
  only_if { ::File.mtime('/var/lib/apt/lists') < Time.now - 86_400 }
end

package 'mongodb-org' do
  action :install
end

service 'mongod' do
  action [:enable, :start]
end
