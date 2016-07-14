# frozen_string_literal: true

require 'uri'
require 'httparty'
require 'filesize'
require 'nokogiri'

module Chatrix
  class Bot
    module Plugins
      # Provides information about URLs posted in chat.
      class UrlInfo < Plugin
        ANALYZERS = {
          'text/html' => :analyze_page
        }.tap { |h| h.default = :analyze_file }.freeze

        register_pattern URI.regexp, :url

        def initialize(bot)
          super
          @cache = {}
        end

        def url(room, message, _match)
          URI.extract(message.body).each do |uri|
            handle_uri room, URI.parse(uri)
          end
        end

        private

        def handle_uri(room, uri)
          return unless %w(http https).member? uri.scheme

          # Don't notify the room of errors, but do log them internally.
          begin
            room.messaging.send_message format_info(uri, uri.host)
          rescue SocketError
            @log.warn "URI invalid or not found: #{uri}"
          rescue => e
            @log.error "Error getting info for #{uri}: #{e.inspect}"
          end
        end

        def analyze_url(uri)
          @log.debug "Analyzing url: #{uri}"

          response = HTTParty.head uri, maintain_method_across_redirects: true
          raise 'Failed to retrieve HEAD response' unless response.code == 200

          type = response['Content-Type'].match(%r{^\s*.+?/[^;]+}).to_s

          @log.debug "Detected type: #{type}"

          {
            type: type
          }.merge send(ANALYZERS[type], uri, response)
        end

        def analyze_file(uri, response)
          @log.debug "Analyzing file: #{uri}"

          {
            title: File.basename(uri.path),
            size: response['Content-Length']
          }
        end

        def analyze_page(uri, _response)
          @log.debug "Analyzing page: #{uri}"

          get = HTTParty.get uri

          doc = Nokogiri::HTML(get.body, &:nonet)

          title = doc.css('title').text

          @log.debug "Page title: #{title}"

          {
            title: title.empty? ? 'Untitled' : title,
            size: get.body.size
          }
        end

        def get_info(uri)
          @log.debug "Getting info for #{uri}"
          @cache[uri.to_s] ||= analyze_url uri
        end

        def format_info(uri, domain)
          @log.debug 'format_info, calling get_info'
          data = get_info uri
          @log.debug 'Formatting result'
          str = "[#{domain || '???'}] #{data[:title] || url}"
          str = "#{str} - #{human_size(data[:size])}" if data[:size]
          str
        end

        def human_size(bytes)
          Filesize.from("#{bytes} B").pretty
        rescue
          '??? B'
        end
      end
    end
  end
end
