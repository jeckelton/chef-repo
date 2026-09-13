#
# Cookbook:: nec_rke2
# Recipe:: install
#

install_script = "#{Chef::Config[:file_cache_path]}/install-rke2.sh"
desired_version = node['rke2']['version']

remote_file install_script do
  source 'https://get.rke2.io'
  owner 'root'
  group 'root'
  mode '0755'
  sensitive true
end

execute "install-rke2-#{desired_version}" do
  command "INSTALL_RKE2_TYPE=server INSTALL_RKE2_VERSION='#{desired_version}' INSTALL_RKE2_METHOD=rpm #{install_script}"
  environment(
    'INSTALL_RKE2_TYPE' => 'server',
    'INSTALL_RKE2_VERSION' => desired_version,
    'INSTALL_RKE2_METHOD' => 'rpm'
  )
  not_if do
    ::File.exist?('/usr/bin/rke2') &&
      shell_out('/usr/bin/rke2 --version').stdout.include?(desired_version)
  end
  notifies :restart, 'service[rke2-server]', :delayed
end

service 'rke2-server' do
  action :nothing
end
