include_recipe 'graylog2::repo_configure'

rpm_package 'graylog-repository' do
  source repo_rpm_path
  action :install
  notifies :run, 'execute[dnf_makecache]', :immediately
end

execute 'dnf_makecache' do
  command 'dnf makecache'
  action :nothing
end

package 'graylog-server' do
  action :install
end
