repo_url = node['graylog2']['repo_url']
repo_deb_path = node['graylog2']['repo_deb_path']

remote_file repo_deb_path do
  source repo_url
  action :create
  not_if { ::File.exist?(repo_deb_path) }
end

dpkg_package 'graylog-repository' do
  source repo_deb_path
  action :install
end

execute 'apt_update' do
  command 'apt update'
  action :run
end

package 'graylog-server' do
  action :install
end
