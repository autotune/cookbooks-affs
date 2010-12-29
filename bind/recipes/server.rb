#
# Cookbook Name:: bind
# Recipe:: server
#
# Copyright 2010, afistfulofservers
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

fqdns = Array.new
dnsdomains = Array.new

package "bind-chroot"
package "bind-utils"

# search for all nodes in chef server
nodes = search(:node, "hostname:[* TO *]")

# pull their fqdns into an array
nodes.each do |node|
  fqdns << node[:fqdn]
end
fqdns.compact!

fqdns.each do |fqdn|
  dnsray=fqdn.split('.')

  # obtain root domain
  tld=dnsray.pop
  domainname=dnsray.pop
  dnsdomains << domainname+'.'+tld

  while (dnsray.size > 1) do
    dnsdomains << dnsray.pop+'.'+dnsdomains.last
  end
end

dnsdomains.uniq!

# write master config file
template "/var/named/chroot/etc/named.conf" do
  source "named.conf.erb"
  variables(:dnsdomains => dnsdomains)
end



####################
# begin crazyland
####################

## nameservers
#nameservers = [{ 'fqdn', 'dev.usease.aws.afistfulofservers.net' }]
#
## mxrecords
#mxrecords = [{
#    'fqdn', 'smtp.dev.eseast.aws.afistfulofservers.net',
#    'weight', '10' 
#  }]
#
## srvrecords
#srvrecords = []
## arecords
#arecords = []
## aaaarecords
#aaaarecords = []
## cnamerecords
#aaaarecords = []
## txtrecords
#aaaarecords = []
#
#template "/var/named/chroot/var/named/master/dev.useast.aws.afistfulofservers.net.zone" do
#  source "zone.erb"
#  mode 0644
#  # arrays of hashes: okay to pass in empty arrays, but not Nill.
#  variables(
#    :nameservers => nameservers
#    :mxrecords => mxrecords
#    :srvrecords => srvrecords
#    :arecords => arecords
#    :aaaarecords => aaaarecords
#    :cnamerecords => cnamerecords
#    :txtrecords => txtrecords
#  )
#end
#
#
