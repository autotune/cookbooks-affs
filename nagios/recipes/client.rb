#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Author:: Sean OMeara <sean@afistulofservers.com>
# Cookbook Name:: nagios
# Recipe:: client
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
#

# packages
packages = case node[:platform]
           when "fedora", "redhat", "centos", "scientific"
             %w{ 
            nrpe
            nagios-plugins-all
            nagios-plugins-nrpe
             }

           when "debian", "ubuntu"
             %w{
            nagios-nrpe-server
            nagios-nrpe-plugin
            nagios-plugins
            nagios-plugins-basic
            nagios-plugins-standard
             }
           end

packages.each do |pkg|
  package pkg
end

# services
service "nagios-nrpe-server" do
  case node[:platform]
  when "redhat", "centos", "scientific", "fedora"
    service_name "nrpe"
  when "debian", "ubuntu"
    service_name "nagios-nrpe-server"
  end
  supports :restart => true
  action [ :enable, :start ]
end

# config files
mon_host = Array.new
search(:node, "role:monitoring") do |n|
  mon_host << n['ipaddress']
end

if mon_host.empty? then
  raise "monitor host list empty. refusing to write templates."
end

template "/etc/nagios/nrpe.cfg" do
  source "nrpe.cfg.erb"
  owner node[:nagios][:nrpe_user]
  group node[:nagios][:nrpe_group]
  mode "0644"
  variables :mon_host => mon_host
end

if(["redhat", "centos", "scientific", "fedora" ].include?(node[:platform]) and node[:kernel][:machine] == "x86_64") then
  check_mem_file = %w{ /usr/lib64/nagios/plugins/check_mem.sh }
else
  check_mem_file = %w{ /usr/lib/nagios/plugins/check_mem.sh }
end

cookbook_file "#{check_mem_file}" do
  source "plugins/check_mem.sh"
  owner node[:nagios][:nrpe_user]
  group node[:nagios][:nrpe_group]
  mode 0755
end

