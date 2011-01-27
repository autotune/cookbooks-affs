#
# Cookbook Name:: selinux
# Recipe:: default
#
# Copyright 2010, A Fistful of Enterprises
#
# Apache2 license
#

execute "disable selinux enforcement" do
  only_if "selinuxenabled"
  command "setenforce 0"
  action :run
end

