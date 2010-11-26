# Author:: Sean OMeara <sean@afistfulofservers.com>
# Cookbook Name:: munin
# Attributes:: server
#
# Copyright 2010-2011, Sean OMeara
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

case platform
when "fedora", "redhat", "centos", "scientific"
  set[:munin][:docroot]    =   "/var/www/html/munin"
  set[:munin][:db_dir]     =   "/var/lib/munin"
  set[:munin][:log_dir]    =   "/var/log/munin"
  set[:munin][:run_dir]    =   "/var/run/munin"
when "debian", "ubuntu" 
  set[:munin][:docroot]    =   "/var/www/munin"
  set[:munin][:db_dir]     =   "/var/lib/munin"
  set[:munin][:log_dir]    =   "/var/log/munin"
  set[:munin][:run_dir]    =   "/var/run/munin"
end
