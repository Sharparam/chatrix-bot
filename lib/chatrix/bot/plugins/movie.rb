# frozen_string_literal: true

require 'httparty'

module Chatrix
  class Bot
    module Plugins
      # Lets users look up information for a movie by its name.
      class Movie < Plugin
        ENDPOINT = 'https://api.themoviedb.org/3'

        IMDB_TEMPLATE = 'http://www.imdb.com/title/'

        EXTRACT_PATTERN = /(.+?)(?:\s+\((\d+)\))?$/

        register_command 'movie', '<title>', 'Get information about a movie' \
                         ' with the specified title, to get a movie from a' \
                         ' specific year (if there are multiple movies with' \
                         ' the same names), put the year in parentheses after' \
                         ' the title. ' \
                         'This plugin uses the TMDb API but is not endorsed' \
                         ' or certified by TMDb.',
                         handler: :movie, aliases: %w(tmdb)

        def initialize(bot)
          super

          @cache = {}
          @s_cache = {}

          unless @config[:tmdb_key]
            @log.error 'TMDb API key must be specified to use the movie plugin'
          end
        end

        def movie(room, _sender, _command, args)
          return unless @config[:tmdb_key]
          match = args[:title].match EXTRACT_PATTERN
          data = lookup match[1], match[2]
          room.messaging.send_message data ? format(data) : 'Movie not found!'
        end

        private

        def api_path(resource)
          "#{ENDPOINT}#{resource}"
        end

        def lookup(title, year = nil)
          return @cache[[title, year]] if @cache.key? [title, year]
          @cache[[title, year]] = search(title, year)
        end

        def get(id)
          request "/movie/#{id}", { append_to_response: 'credits' }
        end

        def search(title, year = nil)
          query = { query: title, include_adult: true }
          query[:year] = year if year
          response = request '/search/movie', query
          return nil if response.nil? || response['results'].empty?
          id = response['results'].first['id']
          get id
        end

        def request(resource, query = {})
          response = HTTParty.get api_path(resource), make_opts(query)
          response.parsed_response if response.code == 200
        end

        def make_opts(query = {})
          {
            query: { api_key: @config[:tmdb_key] }.merge(query),
            headers: {
              'User-Agent' => "chatrix-bot/#{Bot::VERSION}",
              'Accept' => 'application/json'
            }
          }
        end

        def format(data)
          year = Date.parse(data['release_date']).year

          "#{data['original_title']} (#{year}) by #{director(data)}" \
          " [#{data['runtime']} mins] #{langs(data)}, #{countries(data)}\n" \
          "Stars: #{stars(data)}\n#{data['overview']}\n#{imdb(data['imdb_id'])}"
        end

        def langs(data)
          data['spoken_languages'].map { |l| l['name'] }.join ', '
        end

        def countries(data)
          data['production_countries'].map { |l| l['iso_3166_1'] }.join ', '
        end

        def director(data)
          data['credits']['crew'].find { |c| c['job'] == 'Director' }['name']
        end

        def stars(data)
          data['credits']['cast'].first(3).map { |a| a['name'] }.join ', '
        end

        def imdb(id)
          "#{IMDB_TEMPLATE}#{id}"
        end
      end
    end
  end
end
