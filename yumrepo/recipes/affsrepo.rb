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

directory "/srv/yum/affs"  do
  action :create
  recursive true
end

directory "/home/mockbuild/bin" do
  action :create
  owner "mockbuild"
end

# disable strict hostkey checking
template "/home/mockbuild/bin/git_ssh_wrapper.sh" do
  source "git_ssh_wrapper.sh.erb"
  mode 0755
end

#### Set up keys for cloning package repo
### This depends on github site config
directory "/home/mockbuild/.ssh" do
  action :create
  owner "mockbuild"
end

# public
affs_packages_mockbuild_deploy_pub = data_bag_item('secrets','affs_packages_mockbuild_deploy_pub')['value']
template "/home/mockbuild/.ssh/affs-packages_mockbuild_rsa.pub" do
  source "affs-packages_mockbuild_rsa.pub.erb"
  variables( :key => affs_packages_mockbuild_deploy_pub )
  owner "mockbuild"
end

# private
affs_packages_mockbuild_deploy_key = data_bag_item('secrets','affs_packages_mockbuild_deploy_key')['value']
template "/home/mockbuild/.ssh/affs-packages_mockbuild_rsa" do
  source "affs-packages_mockbuild_rsa.erb"
  variables( :key => affs_packages_mockbuild_deploy_key )
  owner "mockbuild"
end

# sync down git repo
git  "/home/mockbuild/affs-packages" do
  repository "git@github.com:someara/affs-packages.git"
  reference "master"
  user "mockbuild"
  group "mockbuild"
  ssh_wrapper "/home/mockbuild/git_ssh_wrapper.sh"
  action :sync
  ignore_failure true
end

