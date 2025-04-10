#
# Cookbook:: unifi
# Recipe:: default
#
# Copyright:: 2025, The Authors, All Rights Reserved.

include_recipe '::firewalld'
include_recipe '::docker_unifi'