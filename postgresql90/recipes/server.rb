#
# Cookbook Name:: postgresql90
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

require 'fileutils'

# regex bug?
package "postgresql90-server" do
  action :install
end

# patch this properly. ugly hack.
if File.exists?("/etc/init.d/postgresql-9.0") then
  exec "mv /etc/init.d/postgresql-9.0 /etc/init.d/postgresql90"
end

# patch this properly. ugly hack.
def fix_sysv_symlinks
  (2..6).each do |i|
    file "/etc/rc#{i.to_s}.d/K36postgresql-9.0" do
      action :delete
    end
    link "/etc/rc#{i.to_s}.d/K36postgresql90" do
      to "/etc/init.d/postgresql90"
    end
  end
end

fix_sysv_symlinks

execute "executing postgresql initdb" do
  not_if "ls -la /var/lib/pgsql/9.0/data/base"
  command "/sbin/service postgresql90 initdb"
end


####

service "postgresql90" do
  supports :restart => true
  action [ :enable, :start ]
end

postgresql90_user "affs" do
  action :create
  provider "postgresql90_user"
end

postgresql90_database "affstest" do
  action :create
  provider "postgresql90_database"  
end

