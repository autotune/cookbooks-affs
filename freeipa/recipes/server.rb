#
# Cookbook Name:: freeipa
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

node.set[:freeipa][:server] = true

# become aware of clients and servers
freeipa_servers = search(:node, "freeipa_server:true")
freeipa_clients = search(:node, "freeipa_client:true")

# gather data bag secrets
ldap_server_admin_pwd = data_bag_item('secrets','ldap_server_admin_pwd')['value']
kdc_database_master_key = data_bag_item('secrets','kdc_database_master_key')['value']
ipa_user_pwd = data_bag_item('secrets','ipa_user_pwd')['value']

# packages
package "dbus"
package "oddjob"
package "rsync"
package "ipa-client"
package "ipa-server"

##### Security considerations
# All FreeIPA server hosts need to be able to ssh to each other as root to copy replication configs
# That kind of sucks, but what are the real consequences?
# Since they are replicants of each other, this can be justified, since the data is already compromised.
# Can selinux help mitigate this?
include_recipe "ohai"
include_recipe "sshroot2rootssh" 

##### Replication
# We're going to have to 
# a) detect any new freeipa_servers
# b) generate ipa-replica-prepare output for them
# c) copy the configs to them

### Behavor
# First node sets special attribute "master"
# First node configures itself with newly generated crypto

# Subsequent nodes comes up
# Subsequent nodes try to to scp their fqdn's configuration from master
# Subsequent nodes negotiate for master

# negotiate for master
freeipa_masters = search(:node, "freeipa_master:true")
if freeipa_masters.empty? then
  node.set[:freeipa][:master] = "true"
end

##### Do master stuff
if node[:freeipa][:master] then

  # write better tests to see if freeipa is already set up.
  ## Bootstrap FreeIPA
  execute "initializing freeipa-server" do
    not_if "ls /var/lib/ipa/sysrestore/sysrestore.state"
    cmd = "ipa-server-install"
    cmd += " --hostname " + node[:fqdn]
    cmd += " -u " + "ipaadmin"
    cmd += " -r " + node[:domain].upcase
    cmd += " -n " + node[:domain]
    cmd += " -p " + ldap_server_admin_pwd
    cmd += " -P " + kdc_database_master_key
    cmd += " -a " + ipa_user_pwd
    cmd += " -N "
    cmd += " -U "
    cmd += " --no-host-dns "
    command "#{cmd}"
    notifies :start, "service[dirsrv]"
  end

  # Compare list of freeipa_servers with contents of /var/lib/ipa/
  configured_replicants =`ipa-replica-manage -p #{ldap_server_admin_pwd} -H #{node[:fqdn]} list`.split
  configured_replicants.each { |r| puts "DEBUG: configured_replicant: #{r}" }

  freeipa_server_fqdns  = Array.new
  freeipa_servers.each { |n|  freeipa_server_fqdns << n[:fqdn] }
  freeipa_server_fqdns.compact!

  freeipa_server_fqdns.each do |f|
    unless node[:fqdn] == f then
      unless configured_replicants.include?( f ) then
        execute "generating replica config for #{f}" do
          not_if "ls /var/lib/ipa/replica-info-#{f}.gpg"
          command "ipa-replica-prepare -p #{ldap_server_admin_pwd} #{f}"
        end
      end
    end
  end

end


### Subsequent nodes 
unless node[:freeipa][:master] then

  # check to see if slave is setup to replicat from master
  #"ipa-replica-manage -p 0123456789 -H authentication-1.dev.us-east-1.aws.afistfulofservers.net list"

  # Check for replication config
  # Attempt to copy config from master.
  # Fail gracefully if not found.
  execute "rsyncing freeipa replication data" do
    #only_if "ipa-replica-manage -p #{ldap_server_admin_pwd} -H #{freeipa_masters[0][:fqdn]} list | grep #{node[:fqdn]}"
    cmd = "rsync -a -e \"ssh "
    cmd += " -o StrictHostKeyChecking=yes"
    cmd += " -o PasswordAuthentication=no\""
    cmd += " root@"
    cmd += "#{freeipa_masters[0][:fqdn]}:"
    cmd += "/var/lib/ipa/replica-info*"
    cmd += " /var/lib/ipa"
    command cmd
    ignore_failure true
  end

  execute "joining freeipa cluster" do
    not_if "ipa-replica-manage -p #{ldap_server_admin_pwd} -H #{freeipa_masters[0][:fqdn]} list | grep #{node[:fqdn]}"
    only_if "ls /var/lib/ipa/replica-info-#{node[:fqdn]}.gpg"
    cmd = "ipa-replica-install"
    cmd += " -p " + ldap_server_admin_pwd
    cmd +=" /var/lib/ipa/replica-info-#{node[:fqdn]}.gpg"
    command cmd
  end

  # copy CA private key 
  # /etc/dirsrv/slapd-DEV-US-EAST-1-AWS-AFISTFULOFSERVERS-NET/pwdfile.txt
  execute "copying CA private key" do 
    only_if "ipa-replica-manage -p #{ldap_server_admin_pwd} -H #{freeipa_masters[0][:fqdn]} list | grep #{node[:fqdn]}"
    only_if "ls /etc/dirsrv/slapd-#{node[:domain].upcase}/"
    not_if "ls /etc/dirsrv/slapd-#{node[:domain].upcase}/cacert.p12"
    cmd = "rsync -a -e \"ssh "
    cmd += " -o StrictHostKeyChecking=yes"
    cmd += " -o PasswordAuthentication=no\""
    cmd += " root@"
    cmd += "#{freeipa_masters[0][:fqdn]}:"
    cmd += "/etc/dirsrv/slapd-#{node[:domain].upcase}/cacert.p12"
    cmd += " /etc/dirsrv/slapd-#{node[:domain].upcase}/"
    #puts "DEBUG: #{cmd}"
    command cmd
    ignore_failure true
  end

end

##### services
# enable all the default services recommended by the freeipa docs

service "dirsrv" do
  action [:enable,:start]
end

#service "krb5kdc" do
#  only_if service[:dirsrv] => running
#  action [:enable,:start]
#end

#template "/etc/httpd/conf.d/ipa.conf" do
#  source "ipa.conf.erb"
#  mode 0644
#  notifies :restart, "service[httpd]"
#end

service "httpd" do
  action [:enable,:start]
end

service "ipa_kpasswd" do
  action [:enable,:start]
end

service "ipa_webgui" do
  action [:enable,:start]
end

service "messagebus" do
  action [:enable,:start]
end

service "oddjobd" do
  action [:enable,:start]
end

