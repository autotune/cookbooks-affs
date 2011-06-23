# affs

log("starting chef-client") { level :debug }
service "chef-client" do
  action[:enable,:start]
end
