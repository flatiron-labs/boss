require 'slack-ruby-bot'

module Bot
  class App < SlackRubyBot::App
  end

  class Ping < SlackRubyBot::Commands::Base
    def self.call(client, data, _match)
      client.message text: 'pong', channel: data.channel
    end
  end

  class Gif < SlackRubyBot::Commands::Base
    match /boss gif me (\S+)\z/ do |client, data, _match|
      keyword = _match[1]
      send_message_with_gif(client, data.channel, "", keyword)
    end
  end
end
