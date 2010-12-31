#
# Cookbook Name:: ganglia
# Recipe:: client
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

ganglia_servers = search(:node, "ganglia_server:true")

unless ganglia_servers.empty?
  package "ganglia-gmond" do
    action :install
  end

  template "/etc/ganglia/gmond.conf" do
    source "sender.gmond.conf.erb"
    variables(:ganglia_servers => ganglia_servers)
    mode 0644
    backup false
    notifies :restart, "service[gmond]"
  end

  service "gmond" do
    supports :restart => true
    action [:start, :enable]
  end
end
