#
# Cookbook:: step_ca
# Recipe:: configure
#
# Copyright:: 2026, Jeremy Eckelton, All Rights Reserved.

if node['step_ca']['use_encrypted_data_bag']
  ruby_block 'validate encrypted data bag secret exists' do
    block do
      secret_file = node['step_ca']['encrypted_data_bag_secret']

      unless ::File.exist?(secret_file)
        raise "Encrypted data bag secret not found at #{secret_file}"
      end
    end
  end

  secret = Chef::EncryptedDataBagItem.load_secret(
    node['step_ca']['encrypted_data_bag_secret']
  )

  password_data = data_bag_item(
    node['step_ca']['encrypted_password_bag'],
    node['step_ca']['encrypted_password_item'],
    secret.to_s
  )

  intermediate_password = password_data[node['step_ca']['password_key']]
  entra_client_secret = password_data[node['step_ca']['entra']['client_secret_key']]
else
  intermediate_password = node['step_ca']['test_intermediate_password']
  entra_client_secret = nil
end

ruby_block 'validate intermediate password exists' do
  block do
    if intermediate_password.nil? || intermediate_password.empty?
      raise 'Missing step-ca intermediate password'
    end
  end
end

ruby_block 'validate entra settings' do
  block do
    next unless node['step_ca']['entra']['enabled']

    if node['step_ca']['entra']['tenant_id'].nil? || node['step_ca']['entra']['tenant_id'].empty?
      raise 'Missing step-ca Entra tenant_id'
    end

    if node['step_ca']['entra']['client_id'].nil? || node['step_ca']['entra']['client_id'].empty?
      raise 'Missing step-ca Entra client_id'
    end

    if node['step_ca']['use_encrypted_data_bag'] &&
       (entra_client_secret.nil? || entra_client_secret.empty?)
      raise "Missing #{node['step_ca']['entra']['client_secret_key']} in encrypted data bag #{node['step_ca']['encrypted_password_bag']}/#{node['step_ca']['encrypted_password_item']}"
    end
  end
end

file node['step_ca']['password_file'] do
  content "#{intermediate_password}\n"
  owner node['step_ca']['user']
  group node['step_ca']['group']
  mode '0600'
  sensitive true
end

if node['step_ca']['create_test_ca']
  execute 'create test root ca' do
    command [
      '/usr/bin/step certificate create',
      "'#{node['step_ca']['root_common_name']}'",
      node['step_ca']['root_cert'],
      node['step_ca']['root_key'],
      '--profile root-ca',
      "--password-file #{node['step_ca']['password_file']}"
    ].join(' ')
    user node['step_ca']['user']
    group node['step_ca']['group']
    creates node['step_ca']['root_cert']
    sensitive true
  end

  execute 'create test intermediate ca' do
    command [
      '/usr/bin/step certificate create',
      "'#{node['step_ca']['intermediate_common_name']}'",
      node['step_ca']['intermediate_cert'],
      node['step_ca']['intermediate_key'],
      '--profile intermediate-ca',
      "--ca #{node['step_ca']['root_cert']}",
      "--ca-key #{node['step_ca']['root_key']}",
      "--ca-password-file #{node['step_ca']['password_file']}",
      "--password-file #{node['step_ca']['password_file']}"
    ].join(' ')
    user node['step_ca']['user']
    group node['step_ca']['group']
    creates node['step_ca']['intermediate_cert']
    sensitive true
  end
end

if node['step_ca']['jwk']['enabled'] && !node['step_ca']['entra']['enabled']
  execute 'create jwk provisioner keypair' do
    command [
      '/usr/bin/step crypto jwk create',
      node['step_ca']['jwk']['public_key'],
      node['step_ca']['jwk']['encrypted_key'],
      '--kty EC',
      '--crv P-256',
      "--password-file #{node['step_ca']['password_file']}"
    ].join(' ')
    user node['step_ca']['user']
    group node['step_ca']['group']
    creates node['step_ca']['jwk']['encrypted_key']
    sensitive true
  end
end

if node['step_ca']['ssh']['enabled']
  execute 'create ssh host ca keypair' do
    command "ssh-keygen -t ed25519 -f #{node['step_ca']['ssh']['host_key']} -N '' -C 'step-ca ssh host ca'"
    user node['step_ca']['user']
    group node['step_ca']['group']
    creates node['step_ca']['ssh']['host_key']
    sensitive true
  end

  execute 'create ssh user ca keypair' do
    command "ssh-keygen -t ed25519 -f #{node['step_ca']['ssh']['user_key']} -N '' -C 'step-ca ssh user ca'"
    user node['step_ca']['user']
    group node['step_ca']['group']
    creates node['step_ca']['ssh']['user_key']
    sensitive true
  end
end

template "#{node['step_ca']['config_dir']}/ca.json" do
  source 'ca.json.erb'
  owner node['step_ca']['user']
  group node['step_ca']['group']
  mode '0640'
  sensitive true
  variables(
    entra_client_secret: entra_client_secret
  )
  notifies :restart, 'service[step-ca]', :delayed
end

template '/etc/default/step-ca' do
  source 'defaults.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[step-ca]', :delayed
end