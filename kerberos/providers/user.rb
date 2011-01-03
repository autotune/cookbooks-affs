action :create do
  execute "create kerberos user #{new_resource.name}" do
    not_if "/usr/kerberos/sbin/kadmin.local -q listprincs | grep ^#{new_resource.name}@"
    command "/usr/kerberos/sbin/kadmin.local -q \"addprinc -pw #{new_resource.password} #{new_resource.name}\""
  end
end

action :delete do
  execute "delete kerberos user #{new_resource.name}" do
    not_if "/usr/kerberos/sbin/kadmin.local -q listprincs | grep ^#{new_resource.name}@"
      command "/usr/kerberos/sbin/kadmin.local -q \"delprinc -force #{new_resource.name}\""
  end
end
