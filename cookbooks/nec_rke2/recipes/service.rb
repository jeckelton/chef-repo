#
# Cookbook:: nec_rke2
# Recipe:: service
#

node_ip = node['rke2']['node_ip'] || node['ipaddress']
bootstrap = node_ip == node['rke2']['bootstrap_node_ip']
vip = node['rke2']['vip']
attempts = node['rke2']['join_wait_attempts']
delay = node['rke2']['join_wait_delay']

service 'rke2-server' do
  action :enable
end

unless bootstrap
  execute 'wait-for-rke2-registration-vip' do
    command <<~BASH
      set -e
      for i in $(seq 1 #{attempts}); do
        if nc -z -w 2 #{vip} 9345; then
          exit 0
        fi
        sleep #{delay}
      done
      echo "RKE2 registration VIP #{vip}:9345 did not become reachable" >&2
      exit 1
    BASH
  end
end

service 'rke2-server' do
  action :start
end

# Convenience symlinks; RKE2 ships these tools under its data directory.
link '/usr/local/bin/kubectl' do
  to '/var/lib/rancher/rke2/bin/kubectl'
  only_if { ::File.exist?('/var/lib/rancher/rke2/bin/kubectl') }
end

link '/usr/local/bin/crictl' do
  to '/var/lib/rancher/rke2/bin/crictl'
  only_if { ::File.exist?('/var/lib/rancher/rke2/bin/crictl') }
end
