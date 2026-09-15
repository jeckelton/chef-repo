#
# Cookbook:: nec_rke2
# Recipe:: argocd
#

return unless node['rke2']['argocd']['enabled']

bootstrap_ip = node['rke2']['argocd']['bootstrap_node_ip']
kubeconfig   = '/etc/rancher/rke2/rke2.yaml'
data_dir     = node['rke2']['data_dir']
namespace    = node['rke2']['argocd']['namespace']
version      = node['rke2']['argocd']['version']

#
# Determine this node's RKE2 IP.
#
node_ip = node['rke2']['node_ip']

if node_ip.nil? || node_ip.empty?
  interface = node['rke2']['interface']

  node_ip = node.dig(
    'network',
    'interfaces',
    interface,
    'addresses'
  )&.find do |_address, details|
    details['family'] == 'inet'
  end&.first
end

#
# Only bootstrap Argo CD on the first RKE2 server.
#
unless node_ip == bootstrap_ip
  Chef::Log.info(
    "Skipping Argo CD bootstrap on #{node_ip}; " \
    "bootstrap node is #{bootstrap_ip}"
  )

  return
end

argocd_manifest =
  "https://raw.githubusercontent.com/argoproj/argo-cd/" \
  "#{version}/manifests/install.yaml"

#
# Wait for RKE2 to generate its kubeconfig.
#
ruby_block 'wait_for_rke2_kubeconfig' do
  block do
    60.times do
      break if ::File.exist?(kubeconfig)

      sleep 5
    end

    unless ::File.exist?(kubeconfig)
      raise "RKE2 kubeconfig #{kubeconfig} was not created"
    end
  end
end

#
# Bootstrap Argo CD.
#
ruby_block 'bootstrap_argocd' do
  block do
    kubectl = Dir.glob(
      "#{data_dir}/data/*/bin/kubectl"
    ).first

    raise 'Unable to locate RKE2 kubectl binary' if kubectl.nil?

    #
    # Wait for Kubernetes API.
    #
    ready = false

    60.times do
      result = shell_out(
        kubectl,
        '--kubeconfig',
        kubeconfig,
        'get',
        '--raw=/readyz'
      )

      if result.exitstatus.zero?
        ready = true
        break
      end

      sleep 5
    end

    raise 'Kubernetes API did not become ready' unless ready

    #
    # Create namespace idempotently.
    #
    namespace_yaml = shell_out!(
      kubectl,
      '--kubeconfig',
      kubeconfig,
      'create',
      'namespace',
      namespace,
      '--dry-run=client',
      '-o',
      'yaml'
    ).stdout

    result = shell_out(
      kubectl,
      '--kubeconfig',
      kubeconfig,
      'apply',
      '-f',
      '-',
      input: namespace_yaml
    )

    unless result.exitstatus.zero?
      raise "Failed to create Argo CD namespace: #{result.stderr}"
    end

    #
    # Install/update pinned Argo CD version.
    #
    shell_out!(
      kubectl,
      '--kubeconfig',
      kubeconfig,
      'apply',
      '--server-side',
      '--force-conflicts',
      '-n',
      namespace,
      '-f',
      argocd_manifest
    )
  end
end