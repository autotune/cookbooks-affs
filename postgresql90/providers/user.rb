action :create do
  execute "create posgresql user" do
    not_if "echo \"select usename from pg_shadow;\" | sudo -u postgres psql -Upostgres 2>/dev/null | grep #{new_resource.name}"
    command "echo \"CREATE USER #{new_resource.name}\" | sudo -u postgres psql -Upostgres 2>/dev/null"
  end
end
 
action :delete do
  execute "delete postgresql user" do
    not_if "echo \"select usename from pg_shadow;\" | sudo -u postgres psql -Upostgres 2>/dev/null | grep #{new_resource.name}"
    command "echo \"DROP USER #{new_resource.name}\" | sudo -u postgres psql -Upostgres 2>/dev/null"
  end
end
