include_recipe 'graylog2::repo_configure'

yum_package 'graylog-datanode' do
  action :install
end