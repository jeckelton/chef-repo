#
# Cookbook:: step_ca
# Recipe:: default
#
# Copyright:: 2026, Jeremy Eckelton, All Rights Reserved.

include_recipe 'nec_step_ca::install'
include_recipe 'nec_step_ca::configure'
include_recipe 'nec_step_ca::service'