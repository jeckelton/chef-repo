default['unifi']['timezone'] = 'Europe/Amsterdam'

default['unifi']['puid'] = '1001'
default['unifi']['pgid'] = '1001'

default['unifi']['docker']['container']['image'] = 'jacobalberty/unifi:v9.0'
default['unifi']['docker']['container']['name'] = 'unifi-controller'
default['unifi']['docker']['container']['restart'] = 'unless-stopped'
default['unifi']['docker']['container']['privileged'] = 'true'