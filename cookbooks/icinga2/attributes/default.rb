default['icinga2_ha']['masters'] = [
  { 'name' => 'nagios.fritz.box', 'host' => '192.168.178.62' },
  { 'name' => 'icinga-master2', 'host' => '10.0.0.2' }
]

default['icinga2_ha']['db']['root_password']      = 'a-very-strong-root-password'
default['icinga2_ha']['db']['icinga_password']    = 'a-secure-icinga-password'
default['icinga2_ha']['db']['icingaweb_password'] = 'a-secure-icingaweb-password'
default['icinga2_ha']['db']['director_password']  = 'a-secure-director-password'

default['icinga2_ha']['web']['api_password'] = 'TheSunSets2025!'
default['icinga2_ha']['web']['server_name'] = '192.168.178.62'

default['icinga2_ha']['linux_agent_template'] = 'linux-host-template'
default['icinga2_ha']['windows_agent_template'] = 'windows-host-template'

default['icinga2_ha']['icinga_version_windows'] = '2.11.4'
