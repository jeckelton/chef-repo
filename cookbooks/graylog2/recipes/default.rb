#
# Cookbook:: graylog2
# Recipe:: default
#
# Copyright:: 2025, The Authors, All Rights Reserved.
#
include_recipe 'graylog2::firewalld'
include_recipe 'graylog2::java'
include_recipe 'graylog2::mongodb'
include_recipe 'graylog2::datampde_install'
include_recipe 'graylog2::datanode_configure'
include_recipe 'graylog2::server_install'
include_recipe 'graylog2::server_configure'
include_recipe 'graylog2::services'
include_recipe 'graylog2::authbind'

