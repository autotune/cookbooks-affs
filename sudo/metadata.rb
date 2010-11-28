maintainer        "A Fistful of Enterprises, Inc."
maintainer_email  "sean@afisffulofservers.com"
license           "Apache 2.0"
description       "places a sudoers template"
version           "0.0.1"

recipe "sudo", "places a sudoers template"

%w{redhat centos fedora ubuntu debian freebsd}.each do |os|
  supports os
end
