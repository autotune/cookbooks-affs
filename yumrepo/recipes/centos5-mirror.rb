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

include_recipe "yumrepo"

directory "/srv/yum/CentOS/5"  do
  action :create
  recursive true
end

template "/root/centos5mirror-exclude.txt" do
  source "centos5mirror-exclude.txt.erb"
  mode 0644
end

if node[:yumrepo][:master] then
  execute "syncing yum repo from internet" do
    cmd =  "rsync -az"
    cmd += " --exclude-from /root/centos5mirror-exclude.txt"
    #    cmd += " rsync://mirror.cogentco.com/CentOS/5.5"
    cmd += " rsync://mirror.cogentco.com/CentOS/5.5/centosplus/x86_64"
    cmd += " /srv/yum/CentOS/5"
    command cmd
    ignore_failure true
  end
end
