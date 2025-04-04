#
# Cookbook:: graylog2
# Recipe:: default
#
# Copyright:: 2025, The Authors, All Rights Reserved.
#
include_recipe '::firewalld'
include_recipe '::java'
include_recipe '::mongodb'
include_recipe '::datampde_install'
include_recipe '::datanode_configure'
include_recipe '::server_install'
include_recipe '::server_configure'
include_recipe '::service'

