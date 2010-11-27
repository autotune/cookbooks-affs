maintainer        "A Fistful of Enterprises, Inc."
maintainer_email  "sean@afistfulofservers.com"
license           "Apache 2.0"
description       "Installs and configures Chef for chef-client and chef-server"
long_description  IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version           "0.21.4"
recipe            "chef::client", "Sets up a client to talk to a chef-server"
recipe            "chef::delete_validation", "Deletes validation.pem after client registers"

%w{ redhat centos fedora }.each do |os|
  supports os
end
