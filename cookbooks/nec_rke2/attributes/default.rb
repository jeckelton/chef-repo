#
# Cookbook:: nec_rke2
# Attributes:: default
#

# Deliberately pinned. Upgrade this explicitly and roll the control-plane nodes
# one at a time after testing.
default['rke2']['version'] = 'v1.36.3+rke2r1'

default['rke2']['cluster_name'] = 'homelab'
default['rke2']['cluster_domain'] = 'cluster.local'

# Homelab network
default['rke2']['vip'] = '192.168.178.150'
default['rke2']['bootstrap_node_ip'] = '192.168.178.151'
default['rke2']['server_ips'] = %w(
  192.168.178.151
  192.168.178.152
  192.168.178.153
)

# Set this per node only if Ohai's node['ipaddress'] is not the desired RKE2 IP.
default['rke2']['node_ip'] = nil

# Proxmox commonly uses ens18. Change if your Rocky VMs use another interface.
default['rke2']['interface'] = 'enp6s18'

# Kubernetes networking
default['rke2']['cni'] = 'cilium'
default['rke2']['cluster_cidr'] = '10.42.0.0/16'
default['rke2']['service_cidr'] = '10.43.0.0/16'
default['rke2']['cluster_dns'] = '10.43.0.10'
default['rke2']['ingress_controller'] = 'traefik'

# Keep kube-proxy for the first build. Cilium kube-proxy replacement can be
# enabled later after the base cluster is stable.
default['rke2']['disable_kube_proxy'] = true

# Hubble
default['rke2']['hubble']['enabled'] = true
default['rke2']['hubble']['relay_enabled'] = true
default['rke2']['hubble']['ui_enabled'] = true

# kube-vip: control-plane VIP only.
# Application LoadBalancer addresses will later be handled by Cilium.
default['rke2']['kube_vip']['version'] = 'v1.2.3'
default['rke2']['kube_vip']['services_enabled'] = false

# RKE2 embedded etcd snapshots
default['rke2']['etcd']['snapshot_schedule_cron'] = '0 */6 * * *'
default['rke2']['etcd']['snapshot_retention'] = 20
default['rke2']['etcd']['snapshot_compress'] = true

# RKE2 config and data
default['rke2']['config_dir'] = '/etc/rancher/rke2'
default['rke2']['data_dir'] = '/var/lib/rancher/rke2'
default['rke2']['manifest_dir'] = '/var/lib/rancher/rke2/server/manifests'

# Cluster token.
# Recommended: encrypted Chef data bag rke2/homelab with key "token".
#default['rke2']['token']['data_bag'] = 'rke2'
#default['rke2']['token']['item'] = 'homelab'
#default['rke2']['token']['key'] = 'token'
default['rke2']['token'] = 'e1200ddfd5baca951110ad09f080136d7dc1697081090c0d2f02c728e6f1f4e8'
#default['rke2']['token']['encrypted'] = true

# Rocky/RHEL hardening choices for this homelab.
# SELinux remains enforcing; the official RPM install provides RKE2 SELinux policy.
default['rke2']['selinux'] = true

# For this isolated homelab, let Kubernetes/Cilium own host packet filtering.
# If you want firewalld retained, set false and explicitly permit all RKE2/Cilium
# traffic between the three nodes instead.
default['rke2']['disable_firewalld'] = true

# How long joining nodes will wait for the fixed registration address to exist.
default['rke2']['join_wait_attempts'] = 120
default['rke2']['join_wait_delay'] = 5

# ArgoCD bootstrap
default['rke2']['argocd']['enabled'] = true
default['rke2']['argocd']['bootstrap_node_ip'] = '192.168.178.151'
default['rke2']['argocd']['namespace'] = 'argocd'
default['rke2']['argocd']['version'] = 'v3.5.0'
