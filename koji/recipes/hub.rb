#
# Cookbook Name:: koji
# Recipe:: hub
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


node.set[:koji][:server] = true


###########
# Databag input and definitions
###########
koji_dbname = data_bag_item('secrets','koji_dbname')['value']
koji_dbuser = data_bag_item('secrets','koji_dbuser')['value']
koji_dbhost = data_bag_item('secrets','koji_dbhost')['value']

# Right now we're just going to use one kojihub on the same node as its database.
include_recipe "postgresql::server"

# set up ssl certificates
pki_servers = search(:node, "pki_server:true")

pki_servercert "kojihub.afistfulofservers.net" do 
  pkiserver pki_servers[0][:fqdn]
  action [:create]
end

koji_ssl_certificate_file = "/etc/pki/tls/certs/kojihub.afistfulofservers.net.crt"
koji_ssl_certificate_key_file = "/etc/pki/tls/private/kojihub.afistfulofservers.net.key"
koji_ssl_certificate_chain_file = "/etc/pki/tls/certs/ca.crt"
koji_ssl_ca_certificate_file = "/etc/pki/tls/certs/ca.crt"


#postgresql_database "#{koji_dbname}" do
#  action [:create] 
#end
#
#postgresql_database "#{koji_dbuser}" do
#  action [:create]
#end

###########
#### Install and configure Apache
###########

# packages
package "httpd"
package "mod_python"

# set apache variables to recommended values in docs
template "/etc/httpd/conf/httpd.conf" do
  source "httpd.conf.erb"
end

# point mod_ssl to use koji's CA
template "/etc/httpd/conf.d/ssl.conf" do
  source "ssl.conf.erb"
#  notifies :restart, "service[httpd]"
  variables(
    :koji_ssl_certificate_file => koji_ssl_certificate_file,
    :koji_ssl_certificate_key_file => koji_ssl_certificate_key_file,
    :koji_ssl_certificate_chain_file => koji_ssl_certificate_chain_file,
    :koji_ssl_ca_certificate_file => koji_ssl_ca_certificate_file
  )
end

###########
#### Install and configure koji-hub
###########

package "koji-hub"
package "httpd"
package "mod_ssl"

# Apache configuration for koji web interface
template "/etc/httpd/conf.d/kojihub.conf" do
  source "kojihub.conf.erb"
#  notifies :restart, "service[httpd]"
end

# koji-hub appliation configuration
template "/etc/koji-hub/hub.conf" do
  source "hub.conf.erb"
  variables(
    :koji_dbname => koji_dbname,
    :koji_dbuser => koji_dbuser,
    :koji_dbhost => koji_dbhost,
    :koji_dir => "/mnt/koji",
    :koji_weburl => "http://#{node[:fqdn]}/koji"
  )
end

###########
# services
###########

#service "postgresql" do
#  action [:enable,:start]
#end
#
#service "httpd" do
#  action [:enable,:start]
#end
#
