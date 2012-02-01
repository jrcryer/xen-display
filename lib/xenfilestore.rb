require 'sinatra/base'
require 'json'

module Sinatra
	module XenFileStore

		module Helpers

      def fetch_servers
        file      = File.open(settings.cache_file, "r")
        content   = file.read
        servers   = content.empty? ? {} : JSON.parse(content) 
        file.close
        servers
      end

    	def update_servers(host, data)
        servers       = fetch_servers
      	servers[host] = []
      	guests        = data.split("\n\n\n")

      	guests.each do |guest|
        	next if guest.include?("Control domain")

        	server = get_server_detail(guest) 
        	next if server.empty?
        
        	servers[host] << server
      	end
      	servers
    	end

      def cache_servers(content)
        file = File.open(settings.cache_file, "w")
        file.write content.to_json
        file.close
      end 

    	protected 
    	
    	def get_server_detail(guest)

      	server     = {}
      	attributes = guest.split("\n")

      	attributes.each do |attribute|
        	label, value = attribute.split(':')
        	next if label.empty? || label.include?('uuid')

        	label = 'name'  if label.include?('name')
        	label = 'state' if label.include?('state')
        	server[label] = value.strip
      	end
      	server
    	end
    end

  	def self.registered(app)
  		app.helpers XenFileStore::Helpers
  		app.set :cache_file, File.join(settings.root, 'tmp/cache')

      app.before {
        unless File.readable?(settings.cache_file) and File.writable?(settings.cache_file)
          File.open(settings.cache_file, 'w')
        end
      }
		end
	end

	register XenFileStore
end