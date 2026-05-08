#
# Cookbook:: step_ca
# Recipe:: default
#
# Copyright:: 2026, Jeremy Eckelton, All Rights Reserved.

include_recipe 'step_ca::install'
include_recipe 'step_ca::configure'
include_recipe 'step_ca::service'