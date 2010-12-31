#
# Cookbook Name:: ganglia
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

node.set[:ganglia][:server] = true
nodes = search(:node, "hostname:[* TO *]")

include_recipe "apache2"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_auth_pam"

package "ganglia-gmetad" 
package "ganglia-gmond"
package "ganglia"
package "ganglia-gmond-python"
package "ganglia-web"

template "/etc/ganglia/gmond.conf" do
  source "server.gmond.conf.erb"
  variables(:ganglia_nodes => nodes)
  mode 0644
  backup false
  notifies :restart, "service[gmond]"
end

template "/etc/ganglia/gmetad.conf" do
  source "gmetad.conf.erb"
  variables(:ganglia_nodes => nodes)
  mode 0644
  backup false
  notifies :restart, "service[gmond]"
end

template "#{node[:apache][:dir]}/sites-available/ganglia.conf" do
  source "localsystem.apache2.conf.erb"
  mode 0644
  if File.symlink?("#{node[:apache][:dir]}/sites-enabled/ganglia.conf")
    notifies :reload, resources(:service => "apache2")
  end
end

service "gmond" do
  supports :restart => true
  action [:start, :enable]
end

service "gmetad" do
  supports :restart => true
  action [:start, :enable]
end

apache_site "ganglia.conf"

# is this really necessary?
apache_site "000-default" do
  enable false
end
