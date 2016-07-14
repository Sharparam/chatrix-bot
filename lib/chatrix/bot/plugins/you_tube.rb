# frozen_string_literal: true

require 'httparty'

module Chatrix
  class Bot
    module Plugins
      # Lets users search for YouTube videos.
      class YouTube < Plugin
        ENDPOINT = 'https://www.googleapis.com/youtube/v3/search'

        register_command 'youtube', '<query>', 'Searches YouTube for the ' \
                         'specififed query and returns the top result.',
                         handler: :search, aliases: ['yt']

        def initialize(bot)
          super

          if @config[:api_key].nil?
            @config[:api_key] = '_'
            @config.save
            @log.error 'API key must be specified to use YouTube plugin'
          end

          @cache = {}
        end

        def search(room, _sender, _command, args)
          return if @config[:api_key] == '_'
          str = info(args[:query])
          room.messaging.send_message str || 'No video found matching query.'
        rescue => e
          room.messaging.send_message "Error getting YT video: #{e.inspect}" \
                                      " - #{e.message}"
        end

        private

        def info(query)
          return @cache[query] if @cache.key? query
          @cache[query] = get_info(query)
        end

        def get_info(query)
          response = HTTParty.get ENDPOINT, make_opts(query)
          return nil unless response['items'] && !response['items'].empty?
          item = response['items'].first
          "#{item['snippet']['title']} - #{url(item['id']['videoId'])}"
        end

        def make_opts(query)
          {
            query: {
              q: query,
              maxResults: 1,
              order: 'relevance',
              safeSearch: 'none',
              type: 'video',
              key: @config[:api_key]
            }
          }
        end

        def url(id)
          "https://youtu.be/#{id}"
        end
      end
    end
  end
end
