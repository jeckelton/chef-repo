name 'homelab_rke2'
description 'Three-node RKE2 HA homelab cluster'

run_list(
  'recipe[nec_rke2::default]'
)

default_attributes(
  'rke2' => {
    'vip' => '192.168.178.150',
    'bootstrap_node_ip' => '192.168.178.151',
    'server_ips' => [
      '192.168.178.151',
      '192.168.178.152',
      '192.168.178.153'
    ],
    'interface' => 'ens18'
  }
)
