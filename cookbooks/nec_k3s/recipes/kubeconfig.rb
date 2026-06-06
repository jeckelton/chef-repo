#
# Cookbook:: nec_k3s
# Recipe:: kubeconfig
#
# Copyright:: 2026, NewCold Digital B.V., All Rights Reserved.

remote_file '/usr/local/bin/kubectl' do
  source 'https://dl.k8s.io/release/stable.txt'
  action :nothing
end

directory '/root/.kube' do
  owner 'root'
  group 'root'
  mode '0700'
end

ruby_block 'write root kubeconfig' do
  block do
    src = '/etc/rancher/k3s/k3s.yaml'
    dst = '/root/.kube/config'

    raise "#{src} does not exist yet" unless ::File.exist?(src)

    content = ::File.read(src)
    content.gsub!('https://127.0.0.1:6443', "https://#{node['k3s']['primary_server_ip']}:#{node['k3s']['api_port']}")
    ::File.write(dst, content)
    ::File.chmod(0600, dst)
  end
  only_if { ::File.exist?('/etc/rancher/k3s/k3s.yaml') }
end
