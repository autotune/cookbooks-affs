action :create do
  execute "create postgresql user" do
    not_if "echo \"select datname from pg_catalog.pg_database where datname='#{new_resource.name}';\" | sudo -u postgres psql -Upostgres 2>/dev/null | grep #{new_resource.name}"
    command "echo \"CREATE DATABASE #{new_resource.name}\" | sudo -u postgres psql -Upostgres 2>/dev/null"
  end
end
 
action :delete do
  execute "delete postgresql user" do
    not_if "echo \"select datname from pg_catalog.pg_database where datname='#{new_resource.name}';\" | sudo -u postgres psql -Upostgres 2>/dev/null | grep #{new_resource.name}"
    command "echo \"DROP DATABASE #{new_resource.name}\" | sudo -u postgres psql -Upostgres 2>/dev/null"
  end
end
