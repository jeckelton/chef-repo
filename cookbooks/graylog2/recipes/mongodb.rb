version = node['graylog2']['mongodb']['version']
gpg_url = node['graylog2']['mongodb']['gpg_url']

case node['platform_family']
when 'debian'
  execute 'add_mongodb_key' do
    command "wget -qO - #{gpg_url} | apt-key add -"
    action :run
    not_if "apt-key list | grep 'MongoDB'"
  end

  file "/etc/apt/sources.list.d/mongodb-org-#{version}.list" do
    content "deb [ arch=amd64 ] #{node['graylog2']['mongodb']['repo_baseurl']['debian']} bookworm/mongodb-org/#{version} main"
    mode '0644'
  end

  execute 'apt_update' do
    command 'apt-get update'
    action :run
  end

when 'rhel'
  remote_file "/etc/pki/rpm-gpg/RPM-GPG-KEY-mongodb-#{version}" do
    source gpg_url
    mode '0644'
    action :create
  end

  yum_repository "mongodb-org-#{version}" do
    description "MongoDB #{version} Repository"
    baseurl "#{node['graylog2']['mongodb']['repo_baseurl']['rhel']}/mongodb-org/#{version}/x86_64/"
    gpgkey "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mongodb-#{version}"
    gpgcheck true
    enabled true
    action :create
  end
end

package 'mongodb-org' do
  action :upgrade
end

service 'mongod' do
  action [:enable, :start]
end
