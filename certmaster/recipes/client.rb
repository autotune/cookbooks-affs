#
# Cookbook Name:: certmaster
# Recipe:: server
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

node.set[:certmaster][:client] = true
certmaster_servers = search(:node, "certmaster_server:true")

package "certmaster"

unless certmaster_servers.empty?
  template "/etc/certmaster/minion.conf" do
    source "minion.conf.erb" 
    mode 0644
    variables :certmaster_servers => certmaster_servers
  end

  unless node[:certmaster][:server]
    # if no cert, request one.
    execute "requesting certmaster certificate" do
      not_if "ls /etc/pki/certmaster/#{node[:hostname]}.pem"
    command "/usr/bin/certmaster-request "
    end
  end
end
