# nec_rke2

Chef cookbook for a three-node HA RKE2 homelab cluster on Rocky Linux.

## Network

| Purpose | Address |
|---|---|
| Kubernetes/RKE2 VIP | 192.168.178.150 |
| RKE2 node 1 / bootstrap | 192.168.178.151 |
| RKE2 node 2 | 192.168.178.152 |
| RKE2 node 3 | 192.168.178.153 |

All three machines are RKE2 server nodes, so they run:

- Kubernetes control plane
- embedded etcd
- workloads

RKE2 servers are schedulable by default.

## Stack

- Rocky Linux
- RKE2
- embedded etcd
- Cilium
- Hubble + Relay + UI
- Traefik
- kube-vip for the control-plane VIP

kube-vip is intentionally configured only for the control-plane VIP.
Later, Cilium L2 Announcements/IPAM can be used for application
`LoadBalancer` addresses.

## VM recommendation

Per node:

- 4 vCPU
- 8-12 GB RAM
- 40 GB OS disk
- 100 GB RKE2/data disk if you want to separate `/var/lib/rancher/rke2`

For Prometheus, Grafana, Loki, Argo CD and applications, 12 GB/node is
more comfortable than 8 GB/node.

## Important before running Chef

### 1. Confirm the interface name

The cookbook defaults to:

    ens18

Check each node:

    ip -br addr
    ip route

If the interface is different, override:

    node['rke2']['interface']

### 2. Confirm each node's primary IP

Chef uses `node['ipaddress']` by default.

If Ohai chooses the wrong address on a multi-NIC VM, set:

    node['rke2']['node_ip']

per node.

### 3. Create the cluster token

Generate a token:

    openssl rand -hex 32

Place it in the `rke2/homelab` encrypted data bag item under the key:

    token

Example JSON exists at:

    examples/data_bags/rke2/homelab.json

The cookbook uses `Chef::EncryptedDataBagItem.load`, so the nodes need access
to the encrypted data bag secret through their normal Chef configuration.

If you do not use encrypted data bags, override:

    default['rke2']['token']['encrypted'] = false

## Deployment order

The bootstrap node MUST be converged first because it:

1. creates the initial embedded-etcd cluster;
2. installs the Cilium HelmChartConfig;
3. installs kube-vip;
4. brings up VIP 192.168.178.150.

Then converge nodes .152 and .153. They register through:

    https://192.168.178.150:9345

Recommended order:

    192.168.178.151
    192.168.178.152
    192.168.178.153

Joining nodes wait for TCP/9345 on the VIP before starting RKE2.

## Role

An example role is provided:

    examples/roles/homelab_rke2.rb

Apply the same role to all three nodes.

## Verification

On 192.168.178.151:

    sudo systemctl status rke2-server
    sudo journalctl -u rke2-server -n 100 --no-pager

Set kubeconfig:

    export KUBECONFIG=/etc/rancher/rke2/rke2.yaml

Check nodes:

    sudo /var/lib/rancher/rke2/bin/kubectl get nodes -o wide

Expected:

    three Ready control-plane/etcd nodes

Check Cilium:

    sudo /var/lib/rancher/rke2/bin/kubectl -n kube-system get pods | grep cilium

Check Hubble:

    sudo /var/lib/rancher/rke2/bin/kubectl -n kube-system get pods | grep hubble

Check kube-vip:

    sudo /var/lib/rancher/rke2/bin/kubectl -n kube-system get pods -l name=kube-vip-ds -o wide

Check VIP:

    ip addr show ens18
    curl -k https://192.168.178.150:6443/livez

From another machine on the LAN:

    nc -vz 192.168.178.150 6443
    nc -vz 192.168.178.150 9345

## Kubeconfig for your workstation

Copy:

    /etc/rancher/rke2/rke2.yaml

Then replace the server address inside it with:

    https://192.168.178.150:6443

Do not expose that kubeconfig publicly; it contains administrative credentials.

## Etcd snapshots

Snapshots are configured every six hours with retention of 20 and compression
enabled.

Check them with:

    sudo /var/lib/rancher/rke2/bin/rke2 etcd-snapshot ls

## Firewall

This homelab cookbook disables firewalld so RKE2/Cilium can manage the required
packet handling without a second host firewall layer.

Only do this on a trusted/private LAN.

If you retain firewalld instead, you must allow at least the RKE2 control-plane
ports between nodes (6443, 9345, 10250, 2379-2381) and the ports needed by the
selected Cilium tunnelling mode.

## SELinux

SELinux is kept enabled. The cookbook installs RKE2 using the official RPM
method, and RKE2 is configured with:

    selinux: true

## Upgrades

RKE2 is pinned in attributes/default.rb.

Do not point the cookbook at an unpinned `latest` channel.

For upgrades:

1. test the new version;
2. change the pinned version;
3. converge one control-plane node at a time;
4. verify cluster health between nodes.

## Deliberately not enabled yet

The first build does NOT enable:

- Cilium kube-proxy replacement
- Cilium WireGuard encryption
- Cilium L2 Announcements
- Cilium LoadBalancer IPAM
- BGP
- Longhorn
- Argo CD
- Prometheus/Grafana/Loki

Those are better introduced after the base three-node cluster is healthy.
