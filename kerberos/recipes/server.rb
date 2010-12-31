#
# Cookbook Name:: kerberos
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

# only support single master kerberos for now. 
# I hope to try this out if I can get around to it.

node.set[:kerberos][:server] = true

krb5_kdcs = search(:node, "kerberos_server:true")

# if no results, assume we're the first one
if krb5_kdcs.empty? then
  krb5_kdcs << node
end

realm = node[:domain]

# templates should be identical to kerberos::client
template "/etc/krb5.conf" do
  source "krb5.conf.erb"
  mode 0644
  backup false
  #selinux_label "system_u:object_r:krb5_conf_t:s0"
  variables( :krb5_kdcs => krb5_kdcs,
            :realm => realm )
end
template "/etc/pam.d/system-auth-ac" do
  source "system-auth-ac.erb"
  mode 0644
  backup false
  #selinux_label "system_u:object_r:etc_t:s0"
end
template "/etc/pam.d/password-auth-ac" do
  source "password-auth-ac.erb"
  mode 0644
  backup false
  #selinux_label "system_u:object_r:etc_t:s0"
end

package "krb5-server"

service "krb5kdc" do
  action [:enable, :start]
end

service "kadmin" do
  action [:enable, :start]
end


# search through data bags and use kerberos_user LWRP to idempotently make principles
# (implement me)

#setsebool -P allow_kerberos 1

#unless File.exists?("/var/kerberos/krb5kdc/.k5.#{realm.upcase}") then
#kdb5_util create -s 
#end

#/usr/kerberos/sbin/kdb5_util create -s 
#/usr/kerberos/sbin/kadmin.local
#add_policy -minlength 8 -minclasses 3 admin
#add_policy -minlength 8 -minclasses 4 host
#add_policy -minlength 8 -minclasses 4 service
#add_policy -minlength 8 -minclasses 2 user
#
#addprinc -policy user someara
####
