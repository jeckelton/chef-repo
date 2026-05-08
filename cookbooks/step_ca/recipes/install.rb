package %w(curl openssh-clients)

group node['step_ca']['group'] do
  system true
end

user node['step_ca']['user'] do
  system true
  shell '/sbin/nologin'
  home node['step_ca']['config_dir']
  gid node['step_ca']['group']
end

[
  node['step_ca']['config_dir'],
  node['step_ca']['certs_dir'],
  node['step_ca']['secrets_dir'],
  node['step_ca']['templates_dir'],
  node['step_ca']['db_dir'],
  node['step_ca']['log_dir']
].each do |dir|
  directory dir do
    owner node['step_ca']['user']
    group node['step_ca']['group']
    mode dir == node['step_ca']['secrets_dir'] ? '0700' : '0755'
    recursive true
  end
end

step_cli_rpm = "#{Chef::Config['file_cache_path']}/step-cli-#{node['step_ca']['version']}-1.#{node['step_ca']['arch']}.rpm"
step_ca_rpm  = "#{Chef::Config['file_cache_path']}/step-ca-#{node['step_ca']['version']}-1.#{node['step_ca']['arch']}.rpm"

remote_file step_cli_rpm do
  source "https://dl.smallstep.com/gh-release/cli/gh-release-header/v#{node['step_ca']['version']}/step-cli-#{node['step_ca']['version']}-1.#{node['step_ca']['arch']}.rpm"
  mode '0644'
end

remote_file step_ca_rpm do
  source "https://dl.smallstep.com/gh-release/certificates/gh-release-header/v#{node['step_ca']['version']}/step-ca-#{node['step_ca']['version']}-1.#{node['step_ca']['arch']}.rpm"
  mode '0644'
end

rpm_package 'step-cli' do
  source step_cli_rpm
  action :install
end

rpm_package 'step-ca' do
  source step_ca_rpm
  action :install
end