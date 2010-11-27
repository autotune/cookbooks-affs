maintainer        "A Fistful of Enterprises, Inc."
maintainer_email  "sean@afistfulofservers.com"
license           "Apache 2.0"
description       "Installs openssh"
version           "0.8.0"

recipe "openssh", "Installs openssh"

%w{ redhat centos fedora ubuntu debian arch}.each do |os|
  supports os
end
