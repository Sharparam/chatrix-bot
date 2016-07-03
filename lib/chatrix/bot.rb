# frozen_string_literal: true

require 'logger'

require 'chatrix/bot/errors'
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
    def initialize(file = Config::DEFAULT_CONFIG_PATH)
      @started_at = (Time.now.to_f * 1e3).round

      @config = Config.load file

      init_logger

      log.debug 'bot finished initializing'
    end

    def admin?(user)
      @config[:admins].member? user.id
    end

    # Starts the bot (starts syncing with the homeserver).
    def start
      init_client unless @client

      log.info 'Bot starting to sync'

      @client.start_syncing
    end

    # Stops the bot (stops syncing with the homeserver).
    def stop
      log.info 'Bot stopping sync'
      @client.stop_syncing
    end

    def on_sync_error(error)
      log.error "SYNC ERROR: #{error.inspect}"
    end

    private

    def init_logger
      if @config[:debug]
        @log = Logger.new $stdout
        @log.level = Logger::DEBUG
      else
        @log = Logger.new @config[:log_file], 'daily'
        @log.level = @config[:log_level]
      end

      @log.progname = 'chatrix-bot'
    end

    def init_client
      log.debug 'Client initialization'

      @client = Chatrix::Client.new(
        @config[:access_token],
        @config[:user_id],
        homeserver: @config[:homeserver]
      )

      log.debug 'Client event registrations'

      @client.subscribe(self, prefix: :on)
    end
  end
end
