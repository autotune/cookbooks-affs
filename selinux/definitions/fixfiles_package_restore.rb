#
# Author:: Sean OMeara <sean@afistfulofservers.com>
# Cookbook Name:: selinux
# Definition:: fixfiles_package_restore
#
# Copyright 2010-2011, afistfulofservers
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

define :fixfiles_package_restore do
  package_name = params[:name]

  script "fix_selinux_lables" do
    interpreter "bash"
    user "root"
    code <<-EOF
      if [ -e /usr/sbin/selinuxenabled ] ; then
        /usr/sbin/selinuxenabled && /sbin/fixfiles -R #{package_name} restore 
      fi
    EOF
  end
end
