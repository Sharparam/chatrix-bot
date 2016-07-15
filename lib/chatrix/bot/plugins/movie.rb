# frozen_string_literal: true

require 'httparty'

module Chatrix
  class Bot
    module Plugins
      # Lets users look up information for a movie by its name.
      class Movie < Plugin
        ENDPOINT = 'http://www.omdb.com'.freeze

        IMDB_TEMPLATE = 'http://www.imdb.com/title/'

        EXTRACT_PATTERN = /(.+?)(?:\s+\((\d+)\))?$/

        register_command 'movie', '<title>', 'Get information about a movie' \
                         ' with the specified title, to get a movie from a' \
                         ' specific year (if there are multiple movies with' \
                         ' the same names), put the year in parentheses after' \
                         ' the title.', handler: :movie,
                         aliases: ['imdb', 'omdb']

        def movie(room, _sender, _command, args)
          match = args[:title].match EXTRACT_PATTERN
          data = lookup match[1], match[2]
          room.messaging.send_message data ? format(data) : 'Movie not found!'
        end

        private

        def lookup(title, year = nil)
          response = HTTParty.get ENDPOINT, query: make_query(title, year)
          response.parsed_response unless response['Response'] == 'False'
        end

        def make_query(title, year = nil)
          { t: title, y: year, r: 'json', tomatoes: true, plot: 'short' }
        end

        def format(data)
          "#{data['Title']} (#{data['Year']}) by #{data['Director']}" \
          " [#{data['Runtime']}] #{data['Language']}, #{data['Country']}\n" \
          "Stars: #{data['Actors']}\n" \
          "Plot: #{data['Plot']}\n" \
          "Ratings: Metascore: #{data['Metascore']}, " \
          "RT: #{data['tomatoMeter']}%, IMDb: #{data['imdbRating']}\n" \
          "#{IMDB_TEMPLATE}#{data['imdbID']}"
        end
      end
    end
  end
end