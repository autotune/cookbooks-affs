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

node.set[:freeipa][:client] = true

# become aware servers
freeipa_servers = search(:node, "freeipa_server:true")
freeipa_clients = search(:node, "freeipa_client:true")
freeipa_masters = search(:node, "freeipa_master:true")

unless freeipa_servers.empty? then
  package "ipa-client"
  package "openldap-clients"
  package "dbus"
  package "certmonger"

  puts "DEBUG: got here!"
  service "messagebus" do
    action [:enable,:start]
  end
  service "certmonger" do
    action [:enable,:start]
  end

  #### Join node to freeipa 'domain'
  # configures kerberos client to point to kdc on freeipa::server
  # configures ldap to look up posix information via sssd/nss
  execute "joining freeipa client to domain" do
    not_if "ls /var/lib/ipa-client/sysrestore/sysrestore.index"
    cmd = "ipa-client-install -U"
    cmd += " --server " + freeipa_masters[0][:fqdn]
    cmd += " --domain " + node[:domain]
    cmd += " --realm " + node[:domain].upcase
    command cmd
    ignore_failure true
  end


  #### pki enrollment
  # gotta wait for ipav2 apparently
  #
  # generate csr
  # submit csr
  # enable dbus
  # get host cert?
#  execute "requesting host principal certificate" do 
#    cmd = "ipa-getcert request -r"
#    cmd += " -f /tmp/affs-server.crt"
#    cmd += " -k /tmp/affs-server.key"
#    cmd += " -N CN= " + node[:fqdn]
#    cmd += " -K host/" + node[:fqdn]
#    cmd += " -D " + node[:fqdn]
#    cmd += " -U id-kp-serverAuth"
#    puts "DEBUG: #{cmd}"
#    command cmd
#  end

  # get http cert?
end

