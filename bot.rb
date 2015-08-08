require 'slack-ruby-bot'

if ENV["RACK_ENV"] != "production"
  require 'pry'
end

module Bot

  REDIS_CONN = Redis.new(:url => ENV["REDIS_URL"] || "redis://localhost:6379")

  class App < SlackRubyBot::App
  end

  class Ping < SlackRubyBot::Commands::Base
    def self.call(client, data, _match)
      client.message text: 'pong', channel: data.channel
    end
  end

  class Gif < SlackRubyBot::Commands::Base
    match /boss gif me (\D+)\z/ do |client, data, _match|
      keyword = _match[1]
      send_message_with_gif(client, data.channel, "", keyword)
    end
  end

  class Karma < SlackRubyBot::Commands::Base
    # Add karma
    match /(\S+[^+:\s])[: ]*\+\+(\s|$)/ do |client, data, _match|
      mentioner = data["user"]
      input = (_match[1]).delete!("<>").delete!("@")
      user_to_karma = "@" + Slack::Web::Client.new.users_info(:user => "#{input}")["user"]["name"]

      if input.include?(mentioner)
        send_message_with_gif(client, data.channel, "Aren't you a cocky person, #{user_to_karma}!", "nuh uh uh")
      else
        karma_count_int = REDIS_CONN.get("#{user_to_karma}_karma").to_i
        REDIS_CONN.set("#{user_to_karma}_karma", "#{karma_count_int + 1}")
        karma_count = REDIS_CONN.get("#{user_to_karma}_karma")
        client.message text: "#{user_to_karma} is on the rise! (Karma: #{karma_count})", channel: data.channel
      end
    end

    # Remove karma
    match /(\S+[^+:\s])[: ]*\-\-(\s|$)/ do |client, data, _match|
      input = (_match[1]).delete!("<>").delete!("@")
      user = "@" + Slack::Web::Client.new.users_info(:user => "#{input}")["user"]["name"]

      karma_count_int = REDIS_CONN.get("#{user}_karma").to_i
      REDIS_CONN.set("#{user}_karma", "#{karma_count_int - 1}")
      karma_count = REDIS_CONN.get("#{user}_karma")
      client.message text: "#{user} lost a life. (Karma: #{karma_count})", channel: data.channel
   end
  end

  class Swanson < SlackRubyBot::Commands::Base
    match /boss swanson me/ do |client, data, _match|
      send_message_with_gif(client, data.channel, "", "ron swanson")
    end
  end

  class TableFlip < SlackRubyBot::Commands::Base
    command 'tflip' do |client, data, _match|
      send_message_with_gif(client, data.channel, "", "table flip")
    end
  end
end
