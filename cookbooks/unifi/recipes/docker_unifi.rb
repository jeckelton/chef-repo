execute 'add_docker_repo' do
  command 'dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo'
  not_if 'test -f /etc/yum.repos.d/docker-ce.repo'
end

execute 'dnf_makecache' do
  command 'dnf makecache'
  action :run
end

execute 'wait_for_repo' do
  command 'sleep 15'
  action :run
end

package %w(yum-utils device-mapper-persistent-data lvm2 docker-ce docker-ce-cli containerd.io) do
  action :install
  retries 10
  retry_delay 5
end

service 'docker' do
  action [:enable, :start]
end

group 'docker' do
  action :create
end

execute 'enable_docker_user_namespace' do
  command 'usermod -aG docker unifi'
  not_if 'getent group docker | grep unifi'
end

directory '/opt/unifi/config' do
  owner 'unifi'
  group 'unifi'
  mode '0755'
  recursive true
end

file '/opt/unifi/docker-compose.yml' do
  content <<-EOH
version: '3.7'
services:
  unifi-controller:
    image: jacobalberty/unifi:latest
    container_name: unifi-controller
    restart: unless-stopped
    environment:
      - PUID=#{node['unifi']['puid']}
      - PGID=#{node['unifi']['pgid']}
      - TZ=#{node['unifi']['timezone']}
    volumes:
      - /opt/unifi/config:/unifi:z
    ports:
      - "3478:3478/udp"
      - "10001:10001/udp"
      - "8080:8080"
      - "8443:8443"
      - "1900:1900/udp"
      - "8843:8843"
      - "8880:8880"
      - "6789:6789"
    privileged: true
  EOH
  owner 'unifi'
  group 'unifi'
  mode '0644'
end

execute 'run_unifi_container' do
  command 'docker compose -f /opt/unifi/docker-compose.yml up -d'
  not_if "docker ps -a --format '{{.Names}}' | grep -w unifi-controller"
end
