#
# Cookbook:: graylog2
# Recipe:: default
#
# Copyright:: 2025, The Authors, All Rights Reserved.
#
include_recipe 'graylog2::apt'
include_recipe 'graylog2::java'
include_recipe 'graylog2::mongodb'
include_recipe 'graylog2::elasticsearch'
include_recipe 'graylog2::install'
include_recipe 'graylog2::configure'
include_recipe 'graylog2::service'
