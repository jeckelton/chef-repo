case node['platform_family']
when 'debian'
  execute 'add_mongodb_key' do
    command 'wget -qO - https://pgp.mongodb.com/server-7.0.asc | apt-key add -'
    action :run
    not_if 'apt-key list | grep "MongoDB"'
  end

  file '/etc/apt/sources.list.d/mongodb-org-7.0.list' do
    content 'deb [ arch=amd64 ] https://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main'
    mode '0644'
    not_if { ::File.exist?('/etc/apt/sources.list.d/mongodb-org-7.0.list') }
  end

  execute 'apt_update' do
    command 'apt-get update'
    only_if { ::File.mtime('/var/lib/apt/lists') < Time.now - 86_400 rescue true }
  end

when 'rhel'
  remote_file '/etc/pki/rpm-gpg/RPM-GPG-KEY-mongodb' do
    source 'https://pgp.mongodb.com/server-7.0.asc'
    mode '0644'
    action :create
  end

  yum_repository 'mongodb-org-7.0' do
    description 'MongoDB Repository'
    baseurl 'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/7.0/x86_64/'
    gpgkey 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mongodb'
    gpgcheck true
    enabled true
    action :create
  end
end

package 'mongodb-org' do
  action :install
end

service 'mongod' do
  action [:enable, :start]
end
