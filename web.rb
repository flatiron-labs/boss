require 'sinatra/base'

module Bot
  class Web < Sinatra::Base
    get '/' do
      'Sup.'
    end
  end
end
