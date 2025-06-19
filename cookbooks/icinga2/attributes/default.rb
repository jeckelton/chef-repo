default['icinga2_ha']['masters'] = [
  { 'name' => 'icinga-master1', 'host' => '192.168.178.62' },
  { 'name' => 'icinga-master2', 'host' => '10.0.0.2' }
]
default['icinga2_ha']['db']['root_password']   = 'a-very-strong-root-password'
default['icinga2_ha']['db']['icinga_password'] = 'a-secure-icinga-password'