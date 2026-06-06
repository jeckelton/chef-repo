#
# Cookbook:: nec_k3s
# Recipe:: prereqs
#
# Copyright:: 2026, NewCold Digital B.V., All Rights Reserved.

package %w(
  curl
  ca-certificates
  qemu-guest-agent
  iptables
  iproute2
  sudo
) do
  action :install
end

service 'qemu-guest-agent' do
  action [:enable, :start]
end

%w(
  br_netfilter
  overlay
).each do |mod|
  execute "load kernel module #{mod}" do
    command "modprobe #{mod}"
    not_if "lsmod | grep -q '^#{mod}'"
  end
end

file '/etc/modules-load.d/k3s.conf' do
  content "br_netfilter\noverlay\n"
  owner 'root'
  group 'root'
  mode '0644'
end

file '/etc/sysctl.d/99-k3s.conf' do
  content <<~EOF
    net.ipv4.ip_forward = 1
    net.bridge.bridge-nf-call-iptables = 1
    net.bridge.bridge-nf-call-ip6tables = 1
  EOF
  owner 'root'
  group 'root'
  mode '0644'
end

execute 'apply k3s sysctl settings' do
  command 'sysctl --system'
end

directory '/etc/rancher/k3s' do
  recursive true
  owner 'root'
  group 'root'
  mode '0755'
end