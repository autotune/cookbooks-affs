#
# Cookbook Name:: etchosts
# Recipe:: default
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

nodes = search(:node, "hostname:[* TO *]")


# self
localhostentry = [ { "ipv4addr", node[:ipaddress], "fqdn", node[:fqdn] } ]

## ^ break out if this fucks up


# 'A' records, from the chef server node list
nodeentries = Array.new

nodes.each do |node|
  #puts "ipv4addr, #{node[:cloud][:public_ips][0]}, fqdn, #{node[:fqdn]}"
  nodeentries << { "ipv4addr", node[:cloud][:public_ips][0], "fqdn", node[:fqdn] }
  #nodeentries << { "ipv4addr", node[:ipv4addr] "fqdn", node[:fqdn],  }
end

#
# 'C' records, from a data bag.
# write me later

## ye ole file
template "/etc/hosts" do
  source "etchosts.erb"
  variables(
    :localhostentry => localhostentry,
    :nodeentries => nodeentries
  )
end
