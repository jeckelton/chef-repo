#
# Cookbook:: nec_rke2
# Recipe:: prerequisites
#

unless platform_family?('rhel')
  raise "nec_rke2 currently supports only RHEL-family systems. Detected: #{node['platform']}"
end

package %w(
  curl
  iproute
  iptables
  nmap-ncat
  tar
) do
  action :install
end

# RKE2/Cilium need IPv4 forwarding and sufficient inotify capacity.
sysctl_values = {
  'net.ipv4.ip_forward' => '1',
  'net.bridge.bridge-nf-call-iptables' => '1',
  'net.bridge.bridge-nf-call-ip6tables' => '1',
  'fs.inotify.max_user_instances' => '8192',
  'fs.inotify.max_user_watches' => '524288',
}

file '/etc/modules-load.d/rke2.conf' do
  content "overlay\nbr_netfilter\n"
  owner 'root'
  group 'root'
  mode '0644'
end

execute 'load-rke2-kernel-modules' do
  command 'modprobe overlay && modprobe br_netfilter'
  not_if 'lsmod | grep -q "^br_netfilter" && lsmod | grep -q "^overlay"'
end

file '/etc/sysctl.d/90-rke2.conf' do
  content sysctl_values.map { |k, v| "#{k} = #{v}" }.join("\n") + "\n"
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[reload-rke2-sysctl]', :immediately
end

execute 'reload-rke2-sysctl' do
  command 'sysctl --system'
  action :nothing
end

execute 'disable-swap-now' do
  command 'swapoff -a'
  only_if 'swapon --show --noheadings | grep -q .'
end

ruby_block 'disable-swap-in-fstab' do
  block do
    path = '/etc/fstab'
    content = ::File.read(path)
    updated = content.lines.map do |line|
      stripped = line.strip
      if !stripped.empty? && !stripped.start_with?('#') && stripped.split(/\s+/)[2] == 'swap'
        "# disabled by Chef nec_rke2: #{line}"
      else
        line
      end
    end.join
    ::File.write(path, updated) if updated != content
  end
end

# Prevent NetworkManager from trying to manage Cilium-created interfaces.
directory '/etc/NetworkManager/conf.d' do
  owner 'root'
  group 'root'
  mode '0755'
end

file '/etc/NetworkManager/conf.d/rke2-cilium.conf' do
  content <<~EOF
    [keyfile]
    unmanaged-devices=interface-name:cilium_*;interface-name:cilium_host;interface-name:cilium_net;interface-name:lxc*
  EOF
  owner 'root'
  group 'root'
  mode '0644'
  notifies :reload, 'service[NetworkManager]', :delayed
end

service 'NetworkManager' do
  action :nothing
end

%w(nm-cloud-setup.service nm-cloud-setup.timer).each do |unit|
  execute "disable-#{unit}" do
    command "systemctl disable --now #{unit}"
    only_if "systemctl list-unit-files #{unit} --no-legend 2>/dev/null | grep -q '^#{unit}'"
  end
end

if node['rke2']['disable_firewalld']
  service 'firewalld' do
    action [:stop, :disable]
    only_if 'systemctl list-unit-files firewalld.service --no-legend 2>/dev/null | grep -q "^firewalld.service"'
  end
end

# Do not disable SELinux. RKE2 RPM installation installs the required policy.
execute 'ensure-selinux-enforcing' do
  command 'setenforce 1'
  only_if { node['rke2']['selinux'] }
  only_if 'command -v getenforce >/dev/null 2>&1 && [ "$(getenforce)" = "Permissive" ]'
end
