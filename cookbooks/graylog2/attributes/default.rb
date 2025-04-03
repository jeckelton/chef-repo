default['graylog2']['repo_url'] = 'https://packages.graylog2.org/repo/packages/graylog-5.2-repository_latest.deb'
default['graylog2']['repo_deb_path'] = '/tmp/graylog-5.2-repository_latest.deb'

default['graylog2']['server']['password_secret'] = secrets['password_secret']
default['graylog2']['server']['root_password_sha2'] = secrets['root_password_sha2']
default['graylog2']['server']['http_bind_address'] = '0.0.0.0'

default['graylog2']['mongodb']['host'] = '127.0.0.1'
default['graylog2']['elasticsearch']['host'] = '127.0.0.1'
default['graylog2']['elasticsearch']['cluster_name'] = 'graylog'
