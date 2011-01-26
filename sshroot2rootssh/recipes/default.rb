#
# Cookbook Name:: sshroot2rootssh
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

nodes = search(:node, "*:*")

execute "generating SSH key for root user" do
  not_if "ls /root/.ssh/id_rsa"
  command "/usr/bin/ssh-keygen -b 4096 -t rsa -f /root/.ssh/id_rsa -P ''"
end

unless nodes.empty? then
  template "/etc/ssh/ssh_known_hosts" do
    source "ssh_known_hosts.erb"
    mode 0440
    owner "root"
    group "root"
    variables(
      :nodes => nodes
    )
  end
end

# extract keys from node objects
keys = Array.new
nodes.each do |n| 
  if n[:keys][:rootuser] then
    keys << n[:keys][:rootuser][:user_rsa_public] 
  end
end
keys.compact!

template "/root/.ssh/authorized_keys_auto" do
  source "authorized_keys_auto.erb"
  owner "root"
  variables(
    :keys => keys
  )
  mode 0600
end

# back up the original authorized_keys file
execute "backing up original root authorized_keys" do
  not_if "ls /root/.ssh/authorized_keys.orig"
  command "cp /root/.ssh/authorized_keys /root/.ssh/authorized_keys.orig"
end

execute "generating authorized_keys" do
  only_if "ls  /root/.ssh/authorized_keys.orig"
  only_if "ls  /root/.ssh/authorized_keys_auto"
  cmd  = "cat"
  cmd += " /root/.ssh/authorized_keys.orig"
  cmd += " /root/.ssh/authorized_keys_auto"
  cmd += " > /root/.ssh/authorized_keys"
  command cmd
end

