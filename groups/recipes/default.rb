#
# Cookbook Name:: users
# Recipe:: sysadmins
#
# Copyright 2009, Opscode, Inc.
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

# this method is blocked because of
# http://tickets.opscode.com/browse/CHEF-1467
#search(:groups, '*:*') do |g|
#  puts "gpasswd #{g['cn']} #{g['gidNumber'].to_i} #{g['memberUids']}"
#  group g['cn'] do
#    gid g['gidNumber'].to_i
#    members g['memberUids']
#    action [:create, :manage]
#  end
#end

#search(:groups, '*:*') do |g|
#  puts "adding group #{g['cn']} #{g['gidNumber'].to_i} #{g['memberUids']}"
#end

