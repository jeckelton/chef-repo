default['icinga2_ha']['masters'] = [
  { 'name' => 'nagios.fritz.box', 'host' => '192.168.178.62' },
  { 'name' => 'icinga-master2', 'host' => '10.0.0.2' }
]
default['icinga2_ha']['db']['root_password']   = 'a-very-strong-root-password'
default['icinga2_ha']['db']['icinga_password'] = 'a-secure-icinga-password'
default['icinga2_ha']['db']['icingaweb_password'] = 'a-secure-icingaweb-password'

default['icinga2_ha']['web']['api_password'] = 'TheSunSets2025!'