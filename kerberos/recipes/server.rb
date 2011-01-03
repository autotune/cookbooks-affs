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
# high availability will rely on N-way openldap

node.set[:kerberos][:server] = true

krb5_kdcs = search(:node, "kerberos_server:true")

# if no results, assume we're the first one
if krb5_kdcs.empty? then
  krb5_kdcs << node
end

realm = node[:domain]

package "krb5-server"
package "expect"
package "pwgen"

# templates should be identical to kerberos::client
template "/etc/krb5.conf" do
  source "krb5.conf.erb"
  mode 0644
  #selinux_label "system_u:object_r:krb5_conf_t:s0"
  variables( :krb5_kdcs => krb5_kdcs,
            :realm => realm )
end
template "/etc/pam.d/system-auth-ac" do
  source "system-auth-ac.erb"
  mode 0644
  #selinux_label "system_u:object_r:etc_t:s0"
end
template "/etc/pam.d/password-auth-ac" do
  source "password-auth-ac.erb"
  mode 0644
  #selinux_label "system_u:object_r:etc_t:s0"
end

# fix me when selinux is seriously revisited.
#setsebool -P allow_kerberos 1

# if the kerberos database has not been initialized
unless File.exists?("/var/kerberos/krb5kdc/.k5.#{realm.upcase}") then
  kdc_database_master_key = data_bag_item('secrets','kdc_database_master_key')['value']

  template "/root/kdb5_util-create.expect" do 
    source "kdb5_util-create.expect.erb"
    mode "0700"
    variables( :kdc_database_master_key => kdc_database_master_key )
    backup false
  end

  execute "initializing kerberos database" do
    command "/root/kdb5_util-create.expect"
  end

  file "/root/kdb5_util-create.expect" do
    action :delete
  end
end

# configure policy
execute "setting kerberos admin policy" do
  not_if "kadmin.local -q listpols | grep admin"
  command "kadmin.local -q \"add_policy -minlength 8 -minclasses 3 admin\""
end

# configure policy
execute "setting kerberos host policy" do
  not_if "kadmin.local -q listpols | grep host"
  command "kadmin.local -q \"add_policy -minlength 8 -minclasses 4 host\""
end

# configure policy
execute "setting kerberos service policy" do
  not_if "kadmin.local -q listpols | grep service"
  command "kadmin.local -q \"add_policy -minlength 8 -minclasses 4 service\""
end

# configure policy
execute "setting kerberos user policy" do
  not_if "kadmin.local -q listpols | grep user"
  command "kadmin.local -q \"add_policy -minlength 8 -minclasses 2 user\""
end

# services
service "krb5kdc" do
  action [:enable, :start]
end

service "kadmin" do
  action [:enable, :start]
end

# set a random password, have an admin manually change it later.
search(:users, '*:*') do |u|
  kerberos_user u['uid'] do
    action :create
    password `pwgen 8 1`.chomp
  end
end

