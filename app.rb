require 'json'

module XenDisplay

  class Application < Sinatra::Base

    set :cache_file, File.join(settings.root, 'tmp/cache')

    def cache_servers(path, content)
      file = File.open(path, "w")
      file.write content.to_json
      file.close
    end

    def update_servers(servers, host, data)
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

    before do
      unless File.readable?(settings.cache_file) and File.writable?(settings.cache_file)
        File.open(settings.cache_file, 'w')
      end
    end

    get '/' do  
      file      = File.open(settings.cache_file, "r")
      content   = file.read
      @servers  = content.empty? ? {} : JSON.parse(content) 
      file.close

      erb :index
    end

    post '/update/:host' do
      
      host = params[:host]
      data = params[:data]

      if data.empty?
          raise "Invalid parameters"
      end
      file    = File.open(settings.cache_file, "r")
      content = file.read
      servers = content.empty? ? {} : JSON.parse(content)
      file.close

      servers = update_servers(servers, host, data)
      cache_servers(settings.cache_file, servers)

      content_type :text
      puts 'complete'
    end

  end

end