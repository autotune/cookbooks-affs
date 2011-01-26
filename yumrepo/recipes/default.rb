# Cookbook Name:: yumrepo
# Recipe:: default
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

node.set[:yumrepo][:server] = true

yumrepo_servers = search(:node, "yumrepo_server:true")
yumrepo_clients = search(:node, "yumrepo_client:true")


##### Security considerations
# Here Be Dragons. 
include_recipe "ohai"
include_recipe "sshroot2rootssh"

# for actually serving the repos
include_recipe "apache2"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_auth_pam"

# packages
package "yum-utils"
package "rsync"
package "mock"
package "git"

##### Replication
# nodes rsync a dir from master

##### Behavior
# First node sets special attribute "master"
# First node configures itself as a yum repo
# Subsequent nodes comes up
# Subsequent nodes negotiate for master
# Subsequent nodes try to sync data from master

# negotiate for master
yumrepo_masters = search(:node, "yumrepo_master:true")
if yumrepo_masters.empty? then
  node.set[:yumrepo][:master] = "true"
end


# do common stuff
user "mockbuild"
group "mock" do
  members ["mockbuild"]
end

# set the default mock config.
# make this more robust later
link "/etc/mock/default.cfg" do
  to "/etc/mock/fedora-13-x86_64.cfg"
end

#execute "initializing mock chroot" do
#  not_if "ls /var/lib/mock/fedora-13-x86_64"
#  command "mock --init"
#end

# centos target directory
directory "/srv/yum"  do 
  action :create
  recursive true
end


# do master stuff
# actual actions deferred to individual repo recipes

# do non-master stuff
unless node[:yumrepo][:master] then
  # rsync from the master
  execute "rsyncing yumrepo data" do
    cmd = "rsync -a -e \"ssh "
    cmd += " -o StrictHostKeyChecking=yes"
    cmd += " -o PasswordAuthentication=no\""
    cmd += " root@"
    cmd += "#{yumrepo_masters[0][:fqdn]}:"
    cmd += "/srv/yum/"
    cmd += " /srv/yum/"
    command cmd
    ignore_failure true
  end
end

template "#{node[:apache][:dir]}/sites-available/yumrepo.conf" do
  source "localsystem.apache2.conf.erb"
  mode 0644
  backup false
  if File.symlink?("#{node[:apache][:dir]}/sites-enabled/yumrepo.conf")
    notifies :reload, resources(:service => "apache2")
  end
end

apache_site "yumrepo.conf"

