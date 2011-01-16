#
# Cookbook Name:: ldap
# Recipe:: server
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

node.set[:ldap][:server] = true
ldap_servers = search(:node, "ldap_server:true")

if ldap_servers.empty? then
  ldap_servers << node
end

# unless ldap server is installed and functioning

package "389-ds"

package "openldap-clients" do
  action :install
end

unless File.exists?("/etc/dirsrv/slapd-#{node[:hostname]}") then
  ldap_config_directory_admin_pwd = data_bag_item('secrets','ldap_config_directory_admin_pwd')['value']
  ldap_root_dn_pwd = data_bag_item('secrets','ldap_root_dn_pwd')['value']
  ldap_server_admin_pwd = data_bag_item('secrets','ldap_server_admin_pwd')['value']

  template "/root/389-ds-setup.inf" do
    source "389-ds-setup.inf.erb"   
    variables(
      :full_machine_name => node[:fqdn],
      :admin_domain => "rds."+node[:domain],
      :config_directory_admin_pwd => ldap_config_directory_admin_pwd,
      :config_directory_ldap_url => "ldap://"+node[:fqdn]+":389/o=NetscapeRoot",
      :server_identifier => node[:hostname],
      :suffix => "dc="+node[:domain].split('.').join(",dc="),
      :root_dn_pwd => ldap_root_dn_pwd,
      :server_ip_address => node[:ipaddress],
      :server_admin_pwd => ldap_server_admin_pwd
    )
  end

  execute "initializing ldap database" do
    command "/usr/sbin/setup-ds-admin.pl -s -f /root/389-ds-setup.inf"
  end

  file "/root/root/389-ds-setup.inf" do
    action :delete
  end

end

service "dirsrv" do
  action [:enable,:start]
end


