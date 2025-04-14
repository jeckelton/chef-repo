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
  content docker_compose.yml.erb
  owner 'unifi'
  group 'unifi'
  mode '0644'
  variables(
    image: node['unifi']['docker']['container']['image'],
    container_name: node['unifi']['docker']['container']['name'],
    restart: node['unifi']['docker']['container']['restart'],
    PUID: node['unifi']['puid'],
    PGID: node['unifi']['pgid'],
    TZ: node['unifi']['timezone'],
    privileged: node['unifi']['docker']['container']['privileged']
  )
end

execute 'run_unifi_container' do
  command 'docker compose -f /opt/unifi/docker-compose.yml up -d'
  not_if "docker ps -a --format '{{.Names}}' | grep -w unifi-controller"
end
