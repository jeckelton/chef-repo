#
# Cookbook:: unifi
# Recipe:: default
#
# Copyright:: 2025, The Authors, All Rights Reserved.
include_recipe '::unifi_user'
include_recipe '::ulimit'
include_recipe '::docker_unifi'
include_recipe '::firewalld'
