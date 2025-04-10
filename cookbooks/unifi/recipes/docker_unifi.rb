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
  command 'usermod -aG docker root'
  not_if 'getent group docker | grep root'
end

execute 'pull_unifi_image' do
  command 'docker pull linuxserver/unifi:latest'
  not_if "docker image inspect linuxserver/unifi:latest"
end

directory '/opt/unifi/config' do
  recursive true
  owner 'root'
  group 'root'
  mode '0755'
end

execute 'run_unifi_container' do
  command <<-EOH
    docker run -d \
      -e unifi.controller.bind_ip=0.0.0.0 \
      -p 3478:3478/udp \
      -p 10001:10001/udp \
      -p 8080:8080 \
      -p 8443:8443 \
      -p 1900:1900/udp \
      -p 8843:8843 \
      -p 8880:8880 \
      -p 6789:6789 \
      --name=unifi-controller \
      --restart unless-stopped \
      linuxserver/unifi:latest
  EOH
  not_if "docker ps -a --format '{{.Names}}' | grep -w unifi-controller"
end
