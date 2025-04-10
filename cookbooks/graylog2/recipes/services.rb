service 'graylog-datanode' do
  action [:enable, :start]
end

service 'graylog-server' do
  action [:enable, :start]
end
