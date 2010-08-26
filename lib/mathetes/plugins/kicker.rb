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

            @watchlist.each do |watch_nick, watchlist|
              next  if ! ( watch_nick === nick )

              watchlist.each do |watch|
                watch['regexps'].each do |r|
                  next  if r !~ speech

                  victim = $1 || nick
                  if ! watch['exempted'] || ! watch['exempted'].include?( victim )
                    reasons = watch['reasons']
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
  end
end