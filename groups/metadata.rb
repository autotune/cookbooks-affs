maintainer       "A Fistful of Enterprises, Inc."
maintainer_email "sean@afistfulofservers.com"
license          "Apache 2.0"
description      "Creates group from a databag search"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1.0"
recipe "groups", "searches groups data bag for posix groups and creates them"
