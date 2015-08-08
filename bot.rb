require 'slack-ruby-bot'

if ENV["RACK_ENV"] != "production"
  require 'pry'
end

module Bot

  REDIS_CONN = Redis.new(:url => ENV["REDISTOGO_URL"] || "redis://localhost:6379")

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

  class Karma < SlackRubyBot::Commands::Base
    # Add karma
    match /(\S+[^+:\s])[: ]*\+\+(\s|$)/ do |client, data, _match|
      user = _match[1]
      REDIS_CONN.incr("#{user}_karma")
      karma_count = REDIS_CONN.get("#{user}_karma")
      client.message text: "#{user} is on the rise! (Karma: #{karma_count})", channel: data.channel
    end

    # Remove karma
  end
end
