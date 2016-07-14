# encoding: utf-8
# frozen_string_literal: true

require 'chatrix/bot/plugins'

module Chatrix
  class Bot
    # Manages plugins for the bot.
    class PluginManager
      def initialize(bot)
        @bot = bot

        @log = @bot.log

        # The plugins hash will have the plugin type as the key, and the
        # instance of the plugin as the value.
        @plugins = {}

        add_standard_plugins
      end

      def add(type)
        unless type < Plugin
          raise ArgumentError, 'Argument must be a plugin type'
        end

        return if @plugins.key? type

        @log.info "Adding new plugin: #{type}"

        @plugins[type] = type.new @bot
      end

      def remove(type)
        return unless @plugins.key? type
        @log.info "Removing plugin: #{type}"
        plugin = @plugins[type]
        plugin.removed if plugin.respond_to? :removed
        @plugins[type] = nil
      end

      def types
        @plugins.keys
      end

      def plugins
        @plugins.values
      end

      def parse_message(room, message)
        return parse_command(room, message) if Command.command? message.body
        plugins.each { |p| p.parse_message room, message }
      end

      private

      def parse_command(room, message)
        data = Command.parse message.body

        type = types.find { |t| t.command? data[:name] }

        plugin = @plugins[type]

        send_command(plugin, room, message.sender, data) if plugin
      end

      def send_command(plugin, room, sender, data)
        plugin.handle_command(room, sender, data[:name], data[:body])
      rescue PermissionError
        room.messaging.send_notice <<~EOF
          I'm sorry, #{sender}, I cannot let you do that.
        EOF
      rescue => e
        @log.error "Error parsing #{data[:name]} command in #{room}" \
                   ": #{e.inspect}"
        room.messaging.send_notice "Command error: #{e.class}:#{e.message}"
      end

      def add_standard_plugins
        Plugins.constants.each { |c| add(Plugins.const_get(c)) }
      end
    end
  end
end
