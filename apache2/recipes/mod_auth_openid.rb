#
# Cookbook Name:: apache2
# Recipe:: mod_auth_openid
#
# Copyright 2008-2009, Opscode, Inc.
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

packages = case node[:platform]
    when "redhat", "centos", "scientific", "fedora"
        # see http://yum.afistfulofservers.net/affs/ for packages
        %w{ mod_auth_openid } 
    when "debian", "ubuntu"
        %w{ apache2-prefork-dev libopkele-dev libopkele3 g++ }
end

packages.each do |pkg|
    package pkg
end

case node[:platform]
    when "debian", "ubuntu"
        remote_file "/tmp/mod_auth_openid-0.4.tar.gz" do
            source "http://butterfat.net/releases/mod_auth_openid/mod_auth_openid-0.4.tar.gz"
            mode 0644
        end

        bash "install mod_auth_openid" do
            cwd "/tmp"
            code <<-EOH
            tar zxvf mod_auth_openid-0.4.tar.gz
            cd mod_auth_openid-0.4 && ./configure
            perl -pi -e "s/-i -a -n 'authopenid'/-i -n 'authopenid'/g" Makefile
            make && make install
            EOH
            not_if { File.exists?("/usr/lib/apache2/modules/mod_auth_openid.so") }
        end

end

file "#{node[:apache][:cache_dir]}/mod_auth_openid.db" do
    owner node[:apache][:user]
    mode 0600
end

template "/usr/local/bin/mod_auth_openid.rb" do
    source "mod_auth_openid.rb.erb"
    owner node[:apache][:user]
    group node[:apache][:user]
    mode 0750
end

template "#{node[:apache][:dir]}/mods-available/auth_openid.load" do
    source "mods/authopenid.load.erb"
    owner "root"
    group "root"
    mode 0644
    backup false
end

apache_module "auth_openid"


