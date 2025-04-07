include_recipe 'graylog2::repo_configure'

package 'graylog-datanode' do
  action :install
end