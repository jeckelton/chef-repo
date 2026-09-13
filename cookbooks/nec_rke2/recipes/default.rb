#
# Cookbook:: nec_rke2
# Recipe:: default
#

include_recipe 'nec_rke2::prerequisites'
include_recipe 'nec_rke2::install'
include_recipe 'nec_rke2::config'
include_recipe 'nec_rke2::manifests'
include_recipe 'nec_rke2::service'
