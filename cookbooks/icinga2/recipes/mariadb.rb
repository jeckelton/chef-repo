execute 'secure mariadb install' do
  command <<-EOH
    mysqladmin -u root password '#{node['icinga2_ha']['db']['root_password']}'
  EOH
  only_if "mysql -u root -e 'status'"
  ignore_failure true 
end

bash 'create_ido_db' do
  code <<-EOH
    mysql -u root -p'#{node['icinga2_ha']['db']['root_password']}' <<EOF
    CREATE DATABASE IF NOT EXISTS icinga;
    CREATE USER IF NOT EXISTS 'icinga'@'localhost' IDENTIFIED BY '#{node['icinga2_ha']['db']['icinga_password']}';
    GRANT ALL PRIVILEGES ON icinga.* TO 'icinga'@'localhost';
    FLUSH PRIVILEGES;
EOF
  EOH
  not_if "mysql -u root -p'#{node['icinga2_ha']['db']['root_password']}' -e 'SHOW DATABASES;' | grep icinga"
end

bash 'create_web_db' do
  code <<-EOH
    mysql -u root -p'#{node['icinga2_ha']['db']['root_password']}' <<EOF
    CREATE DATABASE IF NOT EXISTS icingaweb;
    CREATE USER IF NOT EXISTS 'icingaweb'@'localhost' IDENTIFIED BY '#{node['icinga2_ha']['db']['icingaweb_password']}';
    GRANT ALL PRIVILEGES ON icingaweb.* TO 'icingaweb'@'localhost';
    FLUSH PRIVILEGES;
EOF
  EOH
  not_if "mysql -u root -p'#{node['icinga2_ha']['db']['root_password']}' -e 'SHOW DATABASES;' | grep icingaweb"
end

bash 'import_ido_schema' do
  code <<-EOH
    mysql -u root -p'#{node['icinga2_ha']['db']['root_password']}' icinga < /usr/share/icinga2-ido-mysql/schema/mysql.sql
  EOH
  not_if "mysql -u root -p'#{node['icinga2_ha']['db']['root_password']}' icinga -e 'SHOW TABLES;' | grep icinga_objects"
end

file '/etc/icinga2/features-available/ido-mysql.conf' do
  content <<~EOF
    library "db_ido_mysql"
    object IdoMysqlConnection "ido-mysql" {
      user = "icinga"
      password = "#{node['icinga2_ha']['db']['icinga_password']}"
      host = "localhost"
      database = "icinga"
    }
  EOF
  notifies :run, 'execute[enable_ido_mysql]', :immediately
end

execute 'enable_ido_mysql' do
  command 'icinga2 feature enable ido-mysql'
  action :nothing
  notifies :reload, 'service[icinga2]', :delayed
end

execute 'enable_other_icinga_features' do
  command 'icinga2 feature enable api checker mainlog'
  not_if 'icinga2 feature list | grep -q "api\\s*\\*\\*"'
  notifies :reload, 'service[icinga2]', :delayed
end
