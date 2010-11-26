maintainer       "A Fistful of Enterprises, Inc."
maintainer_email "sean@afistfulofservers.com"
license          "Apache 2.0"
description      "Creates users from a databag search"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1.0"
recipe "users", "searches users data bag for posix users and creates them"
