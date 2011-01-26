#
# Cookbook Name:: freeipa
# Recipe:: client
#
# Copyright 2011, afistfulofservers
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

node.set[:pki][:client] = true
node.set[:ldap][:client] = true
node.set[:kerberos][:client] = true
node.set[:freeipa][:client] = true

# become aware servers
freeipa_servers = search(:node, "freeipa_server:true")
freeipa_clients = search(:node, "freeipa_client:true")
freeipa_masters = search(:node, "freeipa_master:true")

unless freeipa_servers.empty? then
  package "ipa-client"
  package "openldap-clients"
  package "openldap-clients"

  execute "joining freeipa client to domain" do
    cmd = "ipa-client-install -U"
    cmd += " --server " + freeipa_masters[0][:fqdn]
    cmd += " --domain " + node[:domain]
    cmd += " --realm " + node[:domain].upcase
    command cmd
    ignore_failure true
  end
end
