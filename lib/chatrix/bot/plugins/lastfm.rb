# frozen_string_literal: true

require 'httparty'

module Chatrix
  class Bot
    module Plugins
      # A plugin that lets users associate a Last.fm account with themselves.
      # They can then use the 'listening' command to print what they are
      # listening to. Or to find out what others are listening to.
      class Lastfm < Plugin
        ENDPOINT = 'http://ws.audioscrobbler.com/2.0/'

        register_command 'lastfm', '<user>', 'Associate a Last.fm user with' \
                         ' yourself.', handler: :lastfm

        register_command 'listening', '[user]', "Print what you're currently" \
                         ' listening to, or what someone else is listening' \
                         ' to. Note that the full user ID is needed to list' \
                         ' what someone else is listening to.',
                         handler: :listening

        def initialize(bot)
          super

          @config[:users] ||= {}

          return if @config[:api_key]

          @log.error 'Please configure API key for Last.fm plugin'
        end

        def lastfm(room, sender, _command, args)
          info = get_info args[:user]

          if info
            @config[:users][sender.id] = args[:user]
            @config.save
            room.messaging.send_notice 'Successfully associated that Last.fm' \
                                       ' user with you!'
          else
            room.messaging.send_notice 'That seems to be an invalid username!'
          end
        end

        def listening(room, sender, _command, args)
          user = @config[:users][args.key?(:user) ? args[:user] : sender.id]

          if user
            send_current room, user
          else
            room.messaging.send_notice "That user hasn't configured a Last.fm" \
                                       ' username.'
          end
        end

        private

        def send_current(room, user)
          info = get_nowplaying user

          if info
            room.messaging.send_message format(info)
          else
            room.messaging.send_notice "That user isn't listening to anything."
          end
        end

        def get_info(user)
          request 'user.getinfo', user: user
        end

        def get_nowplaying(user)
          data = request 'user.getrecenttracks', user: user, limit: 1
          return nil unless data

          data['recenttracks']['track'].find do |t|
            t.key?('@attr') && t['@attr']['nowplaying'] == 'true'
          end
        end

        # This method expects to be given the data object of a single track.
        def format(info)
          artist = info['artist']['#text']
          title = info['name']
          album = info['album']['#text']
          "#{title} by #{artist} (#{album})"
        end

        def request(meth, **params)
          query = { method: meth }.merge params
          result = HTTParty.get ENDPOINT, make_opts(query)
          result.parsed_response if result.code == 200 && result['error'].nil?
        end

        def make_opts(query)
          {
            query: query.merge(api_key: @config[:api_key], format: 'json'),
            headers: { 'User-Agent' => "chatrix-bot/#{Bot::VERSION}" }
          }
        end
      end
    end
  end
end
