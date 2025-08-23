# Yum Repo
default['rundeck']['repo']['description'] = 'rundeck'
default['rundeck']['repo']['baseurl'] = 'https://packages.rundeck.com/pagerduty/rundeck/rpm_any/rpm_any/$basearch'
default['rundeck']['repo']['repo_gpgcheck'] = true
default['rundeck']['repo']['gpgcheck'] = false
default['rundeck']['repo']['enabled'] = true
default['rundeck']['repo']['gpgkey'] = 'https://packages.rundeck.com/pagerduty/rundeck/gpgkey'
default['rundeck']['repo']['sslverify'] = true
default['rundeck']['repo']['sslcacert'] = '/etc/pki/tls/certs/ca-bundle.crt'
default['rundeck']['repo']['metadata_expire'] = '300'
default['rundeck']['version'] = '5.14.1.20250818-1'

# Framework config
default['rundeck']['framework']['hostname'] = 'http://testvm.fritz.box'
default['rundeck']['framework']['name'] = 'Rundeck'
default['rundeck']['framework']['port'] = '4440'
default['rundeck']['framework']['server_url'] = 'http://testvm.fritz.box:4440'
default['rundeck']['framwork']['logs'] = '/var/log/rundeck'

# DB settings
default['rundeck']['db']['name'] = 'rundeck'
default['rundeck']['db']['user'] = 'rundeck'
default['rundeck']['db']['password'] = 'TheSunSets2025!'
default['rundeck']['db']['driver'] = 'org.mariadb.jdbc.Driver'

#Additional confs
default['rundeck']['conf']['staticresource'] = 'true'
default['rundeck']['conf']['logo'] = 'rundeck-header-logo.png'
default['rundeck']['conf']['loginwelcome'] = 'Welcome to the NewCold Rundeck Instance'

# MariaDB Root Password
default['rundeck']['db']['root_pw'] = '7ck^jVwwYfVE&@wQ'

# Realm Password
default['rundeck']['admin']['password'] = 'ThisIsTheEnd2027!'

