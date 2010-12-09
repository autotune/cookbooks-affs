# Cookbook Name:: kerberos
# Recipe:: client

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

package "pam_krb5"
package "krb5-workstation"

realm = node[:domain]
krb5_kdcs = search(:node, "role:authentication")

# if no results, assume we're the first one
if krb5_kdcs.empty? then
  krb5_kdcs << node
end

template "/etc/krb5.conf" do
  source "krb5.conf.erb"
  mode 0644
  backup false
  #selinux_label "system_u:object_r:krb5_conf_t:s0"
  variables( :krb5_kdcs => krb5_kdcs,
             :realm => realm 
  )
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
