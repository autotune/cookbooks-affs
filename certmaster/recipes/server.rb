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

node.set[:certmaster][:server] = true
certmaster_clients = search(:node, "certmaster_client:true")

package "certmaster"
package "func"

template "/etc/certmaster/certmaster.conf" do
  source "certmaster.conf.erb"
  notifies :restart, "service[certmaster]"
end

service "certmaster" do
  action [:enable,:start]
end

# if no cert, request one.
execute "requesting certmaster certificate" do
  not_if "ls /var/lib/certmaster/certmaster/certs.#{node[:hostname]}"
  command "/usr/bin/certmaster-request "
end
