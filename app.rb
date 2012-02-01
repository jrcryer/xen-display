require_relative 'lib/xenfilestore'

module XenDisplay

  class Application < Sinatra::Base    
    register Sinatra::XenFileStore

    get '/' do  
      @servers = fetch_servers

      erb :index
    end

    post '/update/:host' do
      
      host = params[:host]
      data = params[:data]

      if data.empty?
          raise "Invalid parameters"
      end
      servers = fetch_servers

      servers = update_servers(servers, host, data)
      cache_servers(settings.cache_file, servers)

      content_type :text
      puts 'complete'
    end
    
  end

end