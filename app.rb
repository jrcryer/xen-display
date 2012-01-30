require 'json'

module XenDisplay

  class Application < Sinatra::Base

    get '/' do  
      file_path = "#{settings.root}/tmp/cache"
      @servers   = []

      if File.readable?(file_path)
        file      = File.open(file_path, "r")
        contents  = file.read
        @servers  = JSON.parse(contents) 
      end
      erb :index
    end

    post '/update' do
    	
    end

  end

end