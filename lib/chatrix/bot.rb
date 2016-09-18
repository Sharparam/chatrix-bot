# frozen_string_literal: true

require 'logger'

require 'wisper'

require 'chatrix/bot/errors'
require 'chatrix/bot/version'
require 'chatrix/bot/config'
require 'chatrix/bot/markdown'
require 'chatrix/bot/plugin_manager'

require 'chatrix'

module Chatrix
  # The Chatrix bot class.
  class Bot
    include Wisper::Publisher

    # Config object containing the bot config.
    attr_reader :config

    # The Logger instance for the bot.
    attr_reader :log

    # The PluginManager for this bot.
    attr_reader :plugin_manager

    # Initializes a new Bot instance.
    # @param file [String] File to load config from.
    def initialize(file = Config::DEFAULT_CONFIG_PATH)
      @started_at = (Time.now.to_f * 1e3).round

      @config = Config.new file

      init_logger

      log.debug 'Initializing plugin manager'
      @plugin_manager = PluginManager.new self

      log.debug 'bot finished initializing'
    end

    def admin?(user)
      @config[:admins].member? user.id
    end

    def uptime
      Time.now.to_i - @started_at / 1000
    end

    # Starts the bot (starts syncing with the homeserver).
    def start
      init_client unless @client

      log.info 'Bot starting'

      @client.start_syncing
    end

    # Stops the bot (stops syncing with the homeserver).
    def stop
      log.info 'Bot stopping'
      @plugin_manager.shutdown
      @client.stop_syncing
    end

    def on_room_message(room, message)
      # Do not process messages sent before we joined, or if we sent
      # them ourselves
      return if message.sender == @client.me || message.timestamp < @started_at
      plugin_manager.parse_message room, message
    end

    def on_sync_error(error)
      log.error "SYNC ERROR: #{error.inspect}"
    end

    def on_stop_error(error)
      log.error "Chatrix failed to stop cleanly: #{error.inspect}"
    end

    def on_connection_error(error)
      log.error "Chatrix connection error: #{error.inspect}"
    end

    def on_disconnected
      log.error 'Lost connection with server'
      @plugin_manager.save_all
      broadcast(:disconnected)
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
