require 'json'
require_relative 'lib/xenfilestore'

module XenDisplay

  class Application < Sinatra::Base    
    register Sinatra::XenFileStore

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