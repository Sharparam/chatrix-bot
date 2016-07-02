# frozen_string_literal: true

require 'yaml'

module Chatrix
  class Bot
    # Manages configuration for the bot.
    class Config
      attr_accessor :file

      def initialize(file: nil, data: {})
        @file = file
        @data = data
      end

      def [](key)
        @data[key]
      end

      def []=(key, value)
        @data[key] = value
      end

      def self.load(file)
        YAML.load_file(file).tap { |c| c.file = file }
      end

      def self.make_template
        new data: {
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
