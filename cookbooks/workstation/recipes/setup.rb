package 'tree' do
  action :install
end

file '/etc/motd' do
  content 'Property of Jeremy Home Lab - Test pipeline2'
end
