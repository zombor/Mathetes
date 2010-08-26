# kicker.rb

# Kicks people based on public PRIVMSG regexps.

# By Pistos - irc.freenode.net#mathetes

require "open-uri"
require "cgi"

module Mathetes
  module Plugins
    class Kicker

      def initialize( mathetes )
        config = YAML.load_file 'conf/kicker.yaml'
        @watchlist = config['watchlist']
        @channels = config['channels']

        mathetes.hook_privmsg do |message|
          catch :done do
            nick = message.from.nick
            speech = message.text
            channel = message.channel
            throw :done  if channel.nil?
            throw :done  if ! @channels.find { |c| c.downcase == channel.name.downcase }

            @watchlist['regexps'].each do |r|
              next  if Regexp.new(r, true) !~ speech

              victim = $1 || nick
              if ! @watchlist['exempted'] || ! @watchlist['exempted'].include?( victim )
                reasons = @watchlist['reasons']
                mathetes.kick(
                  victim,
                  channel,
                  reasons[ rand( reasons.size ) ]
                )
                throw :done
              end
            end
          end
        end
      end
    end
  end
end