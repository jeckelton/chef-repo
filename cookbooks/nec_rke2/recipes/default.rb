#
# Cookbook:: nec_rke2
# Recipe:: default
#

include_recipe '::prerequisites'
include_recipe '::install'
include_recipe '::config'
include_recipe '::manifests'
include_recipe '::service'
include_recipe '::argocd'
