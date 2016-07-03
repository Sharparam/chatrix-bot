# frozen_string_literal: true

require 'logger'
require 'yaml'

module Chatrix
  class Bot
    # Manages configuration for the bot.
    #
    # Storage location for other data is based on the directory
    # containing the file for the config. I.E: If the config file is stored
    # as `~/.chatrix-bot/config.yaml`, then `~/.chatrix-bot` will be used
    # as the data directory for the bot.
    class Config
      DEFAULT_CONFIG_PATH = '~/.config/chatrix-bot/config.yaml'

      attr_reader :file

      def initialize(file = DEFAULT_CONFIG_PATH, data = nil)
        @file = file
        @dir = File.dirname File.expand_path @file
        @data = data || {}

        FileUtils.mkpath @dir unless File.exist? @dir
      end

      def [](key)
        @data[key]
      end

      def []=(key, value)
        @data[key] = value
      end

      def self.load(file)
        YAML.load_file(file)
      end

      def self.defaults
        {
          access_token: '<ACCESS TOKEN>',
          user_id: '<MY USER ID>',
          admins: ['GLOBAL ADMINS', '@user:example.com'],
          homeserver: 'https://server.example.com:1234',
          log_file: 'chatrix-bot.log',
          log_level: Logger::INFO
        }
      end

      def get(key, default)
        self[key] = default if self[key].nil?
        self[key]
      end

      def save(file = @file)
        File.open(file, 'w') { |f| f.write to_yaml }
      end
    end
  end
end
