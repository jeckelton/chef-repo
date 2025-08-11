include_recipe 'graylog2::repo_configure'

package 'graylog-server' do
  action :upgrade
end
