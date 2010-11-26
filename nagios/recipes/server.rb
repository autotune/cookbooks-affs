#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Author:: Sean OMeara <sean@afistfulofservers.com>
# Cookbook Name:: nagios
# Recipe:: server
#
# Copyright 2009, 37signals
# Copyright 2009-2010, Opscode, Inc
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

include_recipe "apache2"
include_recipe "apache2::mod_ssl"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_auth_openid"
include_recipe "apache2::mod_cgi"
include_recipe "nagios::client"
include_recipe "selinux"

# packages 
packages = case node[:platform]
           when "redhat", "centos", "scientific", "fedora"
             %w{
                nagios
                nagios-plugins-all
             }

           when "debian", "ubuntu"
             %w{
                nagios3
                nagios-nrpe-server
                nagios-nrpe-plugin
                nagios-images
                nsca
             }
           end

packages.each do |pkg|
  package pkg
end

# services 
service "nagios3" do
  case node[:platform]
  when "redhat", "centos", "scientific", "fedora"
    service_name "nagios"
  when "debian", "ubuntu"
    service_name "nagios3"
  end
  supports :restart => true
  action [ :enable, :start ]
end

# deleting default apache config; using debian style later
file "#{node[:nagios][:dir]}/conf.d/nagios.conf" do
  action :delete
  backup false
end

# deleting unused config file
file "#{node[:nagios][:dir]}/conf.d/internet.cfg" do
  action :delete
  backup false
end


# variables
sysadmins = search(:users, 'groups:sysadmin')
nodes = search(:node, "hostname:[* TO *] AND role:#{node[:app_environment]}")

members = Array.new
sysadmins.each do |s|
  #puts "sysadmin: #{s['id']}" # debug
  members << s['id']
end

role_list = Array.new
service_hosts= Hash.new

search(:role, "*:*") do |r|
  role_list << r.name
  search(:node, "role:#{r.name}") do |n|
    service_hosts[r.name] = n['hostname']
  end
end

if node[:public_domain]
  public_domain = node[:public_domain]
else
  public_domain = node[:domain]
end

# files
nagios_conf "nagios" do
  config_subdir false
end

directory "#{node[:nagios][:dir]}/dist" do
  owner "nagios"
  group "nagios"
  mode "0755"
end

directory node[:nagios][:dir]/node[:nagios][:config_subdir] do
  owner "nagios"
  group "nagios"
  mode "0755"
  action :create
end

directory node[:nagios][:state_dir] do
  owner "nagios"
  group "nagios"
  mode "0751"
end

directory "#{node[:nagios][:state_dir]}/rw" do
  owner "nagios"
  group node[:apache][:user]
  mode "2710"
end

directory "#{node[:nagios][:httplog_dir]}" do
  owner "nagios"
  group node[:apache][:user]
  mode "0755"
  selinux_label "system_u:object_r:nagios_log_t:s0"
end

execute "archive default nagios object definitions" do
  command "mv #{node[:nagios][:dir]}/conf.d/*_nagios*.cfg #{node[:nagios][:dir]}/dist"
  not_if { Dir.glob(node[:nagios][:dir] + "/conf.d/*_nagios*.cfg").empty? }
end

file "#{node[:apache][:dir]}/conf.d/nagios3.conf" do
  action :delete
  backup false
  selinux_label "system_u:object_r:nagios_conf_t:s0"
end

apache_site "000-default" do
  enable false
end

apacheconf = case node[:platform]
             when "redhat", "centos", "scientific", "fedora"
               #%w{ apache2.conf.htpasswd.erb }
               %w{ apache2.conf.openid.erb }
             when "debian", "ubuntu"
               %w{ apache2.conf.openid.erb }
             end


template "#{node[:apache][:dir]}/sites-available/nagios3.conf" do
  source "#{apacheconf}"
  mode 0644
  variables :public_domain => public_domain
  if File.symlink?("#{node[:apache][:dir]}/sites-enabled/nagios3.conf")
    notifies :reload, resources(:service => "apache2")
  end
end

apache_site "nagios3.conf"

%w{ nagios cgi }.each do |conf|
  nagios_conf conf do
    config_subdir false
  end
end

%w{ commands templates timeperiods}.each do |conf|
  nagios_conf conf
end

nagios_conf "services" do
  variables :service_hosts => service_hosts
end

# nagios will refuse to start with broken config.
if members.empty? then
  raise "sysadmin members list empty. refusing to write template"
else
  nagios_conf "contacts" do
    variables :admins => sysadmins, :members => members
  end
end

# nagios will refuse to start with broken config.
if role_list.empty? then
  raise "role members list empty. refusing to write template"
else
  nagios_conf "hostgroups" do
    variables :roles => role_list
  end
end

if nodes.empty? then
  raise "nodes list empty. refusing to write template"
else
  nagios_conf "hosts" do
    variables :nodes => nodes
  end
end

