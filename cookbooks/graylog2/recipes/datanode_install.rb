include_recipe 'graylog2::repo_configure'

package 'graylog-datanode' do
  action :upgrade
  only_if { ::File.exist?('/usr/share/graylog-datanode') }
end