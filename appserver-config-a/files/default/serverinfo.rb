#/usr/bin/ruby
require 'rubygems'
require 'sinatra'

class ServerInfo < Sinatra::Base
  get '/' do
        fqdn = `hostname -f`.chomp!
        ipaddress = `ifconfig | grep inet | head -n 1 | awk '{ print $2 }' | awk -F: '{print $2}'`.chomp!
        "<html><body>#{fqdn}<br>#{ipaddress}<br></body></html>"
  end
end
