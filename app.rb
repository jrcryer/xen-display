require_relative 'lib/xenfilestore'

module XenDisplay

  class Application < Sinatra::Base    
    register Sinatra::XenFileStore

    get '/' do  
      @servers = fetch_servers

      if params[:hosts]
        hosts    = params[:hosts].split(',')
        @servers = @servers.select {|key, value| hosts.include?(key)}
      end

      erb :index
    end

    post '/update/:host' do
      
      host = params[:host]
      data = params[:data]
      raise "Invalid parameters" if data.empty?

      servers = update_servers(host, data)
      cache_servers(servers)

      content_type :text
      "complete"
    end
    
  end

end