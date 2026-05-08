default['step_ca']['user']  = 'step'
default['step_ca']['group'] = 'step'

default['step_ca']['version']      = '0.30.1'
default['step_ca']['arch']         = 'x86_64'
default['step_ca']['package_type'] = 'rpm'

default['step_ca']['config_dir']    = '/etc/step-ca'
default['step_ca']['certs_dir']     = '/etc/step-ca/certs'
default['step_ca']['secrets_dir']   = '/etc/step-ca/secrets'
default['step_ca']['templates_dir'] = '/etc/step-ca/templates'
default['step_ca']['db_dir']        = '/var/lib/step-ca/db'
default['step_ca']['log_dir']       = '/var/log/step-ca'

default['step_ca']['address'] = ':8443'

default['step_ca']['dns_names'] = [
  node['fqdn'],
  node['hostname']
].compact.uniq

default['step_ca']['ca_name'] = 'NewCold Step CA Test'

default['step_ca']['root_common_name']         = 'NewCold Test Root CA'
default['step_ca']['intermediate_common_name'] = 'NewCold Step CA Intermediate'

default['step_ca']['root_cert'] = '/etc/step-ca/certs/root_ca.crt'
default['step_ca']['root_key']  = '/etc/step-ca/secrets/root_ca_key'

default['step_ca']['intermediate_cert'] = '/etc/step-ca/certs/intermediate_ca.crt'
default['step_ca']['intermediate_key']  = '/etc/step-ca/secrets/intermediate_ca_key'

default['step_ca']['password_file'] = '/etc/step-ca/secrets/password'

default['step_ca']['use_encrypted_data_bag']     = false
default['step_ca']['test_intermediate_password'] = 'ChangeMe-Only-For-Homelab'

default['step_ca']['encrypted_data_bag_secret'] = '/etc/chef/encrypted_data_bag_secret'
default['step_ca']['encrypted_password_bag']    = 'step_ca'
default['step_ca']['encrypted_password_item']   = 'passwords'
default['step_ca']['password_key']              = 'intermediate_password'

default['step_ca']['create_test_ca'] = true

default['step_ca']['ssh']['enabled'] = true

default['step_ca']['ssh']['host_key'] = '/etc/step-ca/secrets/ssh_host_ca_key'
default['step_ca']['ssh']['host_pub'] = "#{node['step_ca']['ssh']['host_key']}.pub"

default['step_ca']['ssh']['user_key'] = '/etc/step-ca/secrets/ssh_user_ca_key'
default['step_ca']['ssh']['user_pub'] = "#{node['step_ca']['ssh']['user_key']}.pub"

default['step_ca']['x509_default_duration'] = '24h'
default['step_ca']['x509_min_duration']     = '5m'
default['step_ca']['x509_max_duration']     = '2160h'

default['step_ca']['ssh_user_default_duration'] = '8h'
default['step_ca']['ssh_user_min_duration']     = '5m'
default['step_ca']['ssh_user_max_duration']     = '8h'

default['step_ca']['ssh_host_default_duration'] = '720h'
default['step_ca']['ssh_host_min_duration']     = '5m'
default['step_ca']['ssh_host_max_duration']     = '2160h'

default['step_ca']['entra']['enabled']           = false
default['step_ca']['entra']['name']              = 'entra-id'
default['step_ca']['entra']['tenant_id']         = ''
default['step_ca']['entra']['client_id']         = ''
default['step_ca']['entra']['domains']           = ['newcold.com']
default['step_ca']['entra']['admins']            = []
default['step_ca']['entra']['client_secret_key'] = 'entra_client_secret'
default['step_ca']['entra']['listen_address']    = '127.0.0.1:10000'