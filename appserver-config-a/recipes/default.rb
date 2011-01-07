#
# Cookbook Name:: appserver-config-a
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

## nginx section
package "nginx"

template "/etc/nginx/nginx.conf" do
    source "nginx.conf.erb"
    mode 0644
    notifies :restart, "service[nginx]"
end

template "/etc/nginx/proxy.conf" do
  source "proxy.conf.erb"
  mode 0644
  notifies :restart, "service[nginx]"
end

service "nginx" do
  action [:enable,:start]
end

## haproxy section
package "haproxy"

template "/etc/haproxy/haproxy.cfg" do
    source "haproxy.cfg.erb"
    mode 0644
    notifies :restart, "service[haproxy]"
end

service "haproxy" do
  action [:enable,:start]
end

## thin section
package "rubygem-thin"

# application deployment
directory "/srv/affs-rubywebserverinfo" do
  action [:create]
  mode 0755
end

directory "/srv/affs-rubywebserverinfo/logs" do
  action [:create]
  mode 0755
end

directory "/srv/affs-rubywebserverinfo/pids" do
  action [:create]
  mode 0755
end

cookbook_file "/srv/affs-rubywebserverinfo/config.ru" do
  source "config.ru"
  mode 0644
end

cookbook_file "/srv/affs-rubywebserverinfo/config.yml" do
  source "config.yml"
  mode 0644
end

cookbook_file "/srv/affs-rubywebserverinfo/serverinfo.rb" do
  source "serverinfo.rb"
  mode 0644
end

#thin -C config.yml -R config.ru start

template "/etc/init/thin.conf" do
  source "thin.conf.upstart.erb"
end

service "thin" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true # ?
  action [ :enable, :start ]
end

