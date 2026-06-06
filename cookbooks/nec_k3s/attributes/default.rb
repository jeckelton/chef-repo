default['k3s']['version'] = 'v1.33.1+k3s1'
default['k3s']['token'] = 'J80hMclrU6CFoe1RlRdO1J0UjpSAYxbm7KbJpZtyAjGpqXwsuwQb75JZpuaM5FU6'

default['k3s']['cluster_name'] = 'homelab-k3s'
default['k3s']['cluster_domain'] = 'cluster.local'

default['k3s']['primary_server'] = 'k3s-cp-01'
default['k3s']['primary_server_ip'] = '192.168.178.231'

default['k3s']['api_port'] = 6443

default['k3s']['servers'] = {
  'k3s-cp-01' => '192.168.178.231',
  'k3s-cp-02' => '192.168.178.232',
  'k3s-cp-03' => '192.168.178.233'
}

default['k3s']['agents'] = {
  'k3s-worker-01' => '192.168.178.234',
  'k3s-worker-02' => '192.168.178.235',
  'k3s-worker-03' => '192.168.178.236'
}

default['k3s']['tls_sans'] = [
  '192.168.178.231',
  '192.168.178.232',
  '192.168.178.233',
  'k3s-cp-01',
  'k3s-cp-02',
  'k3s-cp-03'
]

default['k3s']['disable_components'] = [
  'traefik',
  'servicelb'
]

default['k3s']['node_labels'] = []
default['k3s']['node_taints'] = []

default['k3s']['write_kubeconfig_mode'] = '0644'