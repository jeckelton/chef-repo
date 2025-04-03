package 'openjdk-17-jdk' do
  action :install
  not_if 'dpkg -l | grep openjdk-17-jdk'
end
