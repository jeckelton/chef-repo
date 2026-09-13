name             'nec_rke2'
maintainer       'Jeremy'
license          'All Rights Reserved'
description      'Installs and configures an HA RKE2 cluster on Rocky Linux'
version          '0.1.2'
chef_version     '>= 17.0'

%w(rocky redhat centos).each do |platform|
  supports platform
end
