case node['platform_family']
when 'debian'
  repo_url = node['graylog2']['repo_deb_url']
  repo_deb_path = node['graylog2']['repo_deb_path']

  remote_file repo_deb_path do
    source repo_url
    action :create
    not_if { ::File.exist?(repo_deb_path) }
  end

  dpkg_package 'graylog-repository' do
    source repo_deb_path
    action :install
  end

  execute 'apt_update' do
    command 'apt-get update'
    only_if { ::File.mtime('/var/lib/apt/lists') < Time.now - 86_400 rescue true }
  end

when 'rhel'
  repo_url = node['graylog2']['repo_rpm_url']
  repo_rpm_path = node['graylog2']['repo_rpm_path']

  remote_file repo_rpm_path do
    source repo_url
    action :create
    mode '0644'
    not_if { ::File.exist?(repo_rpm_path) }
  end

  rpm_package 'graylog-repository' do
    source repo_rpm_path
    action :install
  end

  execute 'dnf_makecache' do
    command 'dnf makecache'
    action :run
  end
end