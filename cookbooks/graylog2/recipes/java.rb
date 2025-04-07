case node['platform_family']
when 'debian'
  package 'openjdk-17-jdk' do
    action :install
  end

when 'rhel'
  package 'java-17-openjdk-devel' do
    action :install
  end
end