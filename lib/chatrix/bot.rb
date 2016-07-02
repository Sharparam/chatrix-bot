# frozen_string_literal: true

require 'logger'

require 'chatrix/bot/version'
require 'chatrix/bot/config'

require 'chatrix'

module Chatrix
  # The Chatrix bot class.
  class Bot
    # Config object containing the bot config.
    attr_reader :config

    # The Logger instance for the bot.
    attr_reader :log

    # Initializes a new Bot instance.
    # @param file [String] File to load config from.
    def initialize(file = 'config.yaml')
      @config = Config.load file
      @log = Logger.new @config[:log_file], 'daily'
      @log.level = @config[:log_level]
      @log.progname = 'chatrix-bot'
    end

    # Starts the bot (starts syncing with the homeserver).
    def start
      @client = Chatrix::Client.new(
        @config[:access_token],
        @config[:user_id],
        @config[:homeserver]
      ) unless @client

      @client.start_syncing
    end

    # Stops the bot (stops syncing with the homeserver).
    def stop
      @client.stop_syncing
    end
  end
end
