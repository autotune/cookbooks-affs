#
# Cookbook Name:: cfengine
# Recipe:: server
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

node.set[:cfengine][:server]=true

# become aware of clients and servers
cfengine_servers = search(:node, "cfengine_server:true")
cfengine_clients = search(:node, "cfengine_client:true")

# packages
package "cfengine-community"

# negotiate for master
cfengine_masters = search(:node, "cfengine_master:true")
if cfengine_masters.empty? then
  node.set[:cfengine][:master] = "true"
end

# do master stuff
if node[:cfengine][:master] then
  # /var/cfengin3/inputs
  template "/var/cfengine/inputs/failsafe.cf" do
    source "inputs/failsafe.cf.erb"
  end

  # what should we promise to do?
  # - accept connections from clients  
  # - serve them a configuration based on fqdn 
  # -- role name extracted from hostname?

  # bundle agent update
  # mycopy("$(master_location)","localhost"),
  template "/var/cfengine/inputs/update.cf" do
    source "inputs/update.cf.erb"
    variables(  
      :cfengine_servers => [ node ]
    )
  end

  # change from default
  # bundle server access_rules()
  
  template "/var/cfengine/inputs/site.cf" do
    source "inputs/site.cf.erb"
  end

  template "/var/cfengine/inputs/cfengine_stdlib.cf" do
    source "inputs/cfengine_stdlib.cf.erb"
  end

  # promises!
  # include a config dir?
  template "/var/cfengine/inputs/promises.cf" do
    source "inputs/promises.cf.erb"
  end


  # start cfengine
  service "cfengine3" do
    action [:enable,:start]
  end

end

# do slave stuff
unless node[:cfengine][:master] then
  # /var/cfengin3/inputs
  template "/var/cfengine/inputs/failsafe.cf" do
    source "inputs/failsafe.cf.erb"
  end

  # copy configs from the master

  # updates.cf
  template "/var/cfengine/inputs/update.cf" do
    source "inputs/update.cf.erb"
    variables(  
      :cfengine_servers => cfengine_servers
    )
  end

  template "/var/cfengine/inputs/site.cf" do
    source "inputs/site.cf.erb"
  end

  template "/var/cfengine/inputs/cfengine_stdlib.cf" do
    source "inputs/cfengine_stdlib.cf.erb"
  end

  # promises!
  # include a config dir?
  template "/var/cfengine/inputs/promises.cf" do
    source "inputs/promises.cf.erb"
  end

  # start cfengine
  service "cfengine3" do
    action [:enable,:start]
  end
end


