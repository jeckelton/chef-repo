default['k3s']['version'] = 'v1.32.5+k3s1'
default['k3s']['token'] = 'pRRC3o9FBlgkztJq6EgbdutbOSXQjuCM4gIuk77YhUSvWZJhy9Yq9bi2J7eO6Kvm'

default['k3s']['cluster_name'] = 'homelab-k3s'
default['k3s']['cluster_domain'] = 'cluster.local'

default['k3s']['primary_server'] = 'k3s-cp-01'
default['k3s']['primary_server_ip'] = '192.168.178.151'

default['k3s']['api_port'] = 6443

default['k3s']['servers'] = {
  'k3s-cp-01' => '192.168.178.151',
  'k3s-cp-02' => '192.168.178.152',
  'k3s-cp-03' => '192.168.178.153'
}

default['k3s']['agents'] = {
  'k3s-worker-01' => '192.168.178.154',
  'k3s-worker-02' => '192.168.178.155',
  'k3s-worker-03' => '192.168.178.156'
}

default['k3s']['tls_sans'] = [
  '192.168.178.151',
  '192.168.178.152',
  '192.168.178.153',
  'k3s-cp-01',
  'k3s-cp-02',
  'k3s-cp-03'
]

default['k3s']['disable_components'] = []

default['k3s']['node_labels'] = []
default['k3s']['node_taints'] = []

default['k3s']['write_kubeconfig_mode'] = '0644'