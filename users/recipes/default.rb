#
# Cookbook Name:: users
# Recipe:: default
#
# Copyright 2010, fistfulofservers
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

data_bag('groups').each do |g|
  posixGroup = data_bag_item('groups', g)
  group(g) do
    gid posixGroup['gidNumber']
    action [:create]
  end
end

search(:users, '*:*') do |u|
  user u['uid'] do
    uid u['uidNumber']
    gid u['gidNumber']
    shell u['loginShell']
    comment u['gecos']
    home u['homeDirectory']
    supports :manage_home => true
    action [:create, :manage]
  end
  
end

data_bag('groups').each do |g|
  posixGroup = data_bag_item('groups', g)
  group(g) do
    gid posixGroup['gidNumber']
    members posixGroup['memberUids']
    action [:create, :manage]
  end
end
