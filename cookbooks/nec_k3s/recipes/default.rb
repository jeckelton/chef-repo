#
# Cookbook:: nec_k3s
# Recipe:: default
#
# Copyright:: 2026, NewCold Digital B.V., All Rights Reserved.

include_recipe 'nec_k3s::prereqs'

hostname = node['hostname']

if node['k3s']['servers'].key?(hostname)
  include_recipe 'nec_k3s::server'
elsif node['k3s']['agents'].key?(hostname)
  include_recipe 'nec_k3s::agent'
else
  Chef::Log.warn("Node #{hostname} is not listed as a K3s server or agent. Skipping K3s install.")
end