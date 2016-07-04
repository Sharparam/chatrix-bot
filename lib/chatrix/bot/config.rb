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

      DEFAULTS = {
        access_token: '<ACCESS TOKEN>',
        user_id: '<MY USER ID>',
        admins: ['GLOBAL ADMINS', '@user:example.com'],
        homeserver: 'https://server.example.com:1234',
        log_file: 'chatrix-bot.log',
        log_level: Logger::INFO
      }.freeze

      attr_reader :file

      attr_reader :dir

      def initialize(file = DEFAULT_CONFIG_PATH, data = nil)
        @file = File.expand_path file
        @dir = File.dirname @file

        FileUtils.mkpath @dir unless File.exist? @dir

        load_data = File.exist?(@file) && data.nil?

        @data = load_data ? YAML.load_file(@file) : (data || {})
      end

      def [](key)
        @data[key]
      end

      def []=(key, value)
        @data[key] = value
      end

      def get(key, default)
        self[key] = default if self[key].nil?
        self[key]
      end

      def save(file = @file)
        File.open(file, 'w') { |f| f.write @data.to_yaml }
      end

      def get_pluginconfig(type)
        path = type.to_s.downcase.gsub(/::/, '/')
        file = "#{path.match(/\w+$/)}.yaml"
        self.class.new File.join(dir, 'plugins', path, file)
      end
    end
  end
end
