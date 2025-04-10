group 'graylog' do
    action :create
    system true
  end
  
  user 'graylog' do
    comment 'Graylog system user'
    gid 'graylog'
    system true
    shell '/sbin/nologin'
    home '/var/lib/graylog'
    not_if "pgrep -u graylog"
  end