execute 'add_elasticsearch_key' do
  command 'wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -'
  action :run
  not_if 'apt-key list | grep -i "Elasticsearch"'
end

file '/etc/apt/sources.list.d/elastic-7.x.list' do
  content 'deb [ arch=amd64 ] https://artifacts.elastic.co/packages/oss-7.x/apt stable main'
  mode '0644'
  not_if 'test -f /etc/apt/sources.list.d/elastic-7.x.list'
end

execute 'apt_update' do
  command 'apt-get update'
  action :run
end

package 'elasticsearch-oss' do
  action :install
end
  
service 'elasticsearch' do
  action [:enable, :start]
end
