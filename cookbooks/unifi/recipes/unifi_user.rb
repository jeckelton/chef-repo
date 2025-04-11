# Create the 'unifi' group with the specified PGID
group 'unifi' do
  gid "#{node['unifi']['pgid']}"
  action :create
end

user 'unifi' do
  comment 'UniFi Controller User'
  system true
  shell '/bin/bash'
  uid "#{node['unifi']['puid']}"
  gid "#{node['unifi']['pgid']}"
  action :create
end