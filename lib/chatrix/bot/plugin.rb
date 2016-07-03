# encoding: utf-8
# frozen_string_literal: true

require 'chatrix/bot/command'
require 'chatrix/bot/pattern'

module Chatrix
  class Bot
    # Base class for bot plugins.
    #
    # Plugins will get their class name (lowercased) as their main
    # command name. Meaning if you make a class as such:
    #   class MyPlugin < Plugin
    # It will be called using `!myplugin` in the chat.
    #
    # Additional command aliases can be specified with TODO.
    class Plugin
      # Initializes a new Plugin instance.
      # @param bot [Chatrix::Bot] The bot instance in control of the plugin.
      def initialize(bot)
        @bot = bot
        @log = @bot.log
      end

      # Handles a plugin command.
      #
      # @param room [Room] The room the command was sent in.
      # @param sender [User] The user who issued the command.
      # @param name [String] The name of the command.
      # @param body [String] The command body (text after command name).
      def handle_command(room, sender, name, body)
        command = self.class.command name

        unless @bot.admin? sender
          check_command_permissions(room, command, sender)
        end

        data = command.parse body
        meth = command.handler || :on_command
        send(meth, room, sender, command.name, data) if respond_to? meth
      end

      # Parses a message from a room.
      # If there are any patterns registred for the plugin that matches the
      # message body, the relevant handlers on the plugin will be invoked for
      # the message.
      #
      # All messages, regardless of patterns, will be passed to the
      # `:on_message` method, if it is defined.
      #
      # @param room [Room] The room the message was sent in.
      # @param sender [User] The user who sent the message.
      # @param message [Message] The message that was sent.
      def parse_message(room, message)
        send(:on_message, room, message) if respond_to? :on_message
        pattern = self.class.match message.body
        handle_match(room, message, pattern) if pattern
      rescue => e
        @log.error "Error while parsing message in #{self.class}: #{e.inspect}"
      end

      private

      def handle_match(room, message, pattern)
        meth = pattern.handler || :on_match
        return unless respond_to? meth
        send meth, room, message, pattern.match(message.body)
      end

      def check_command_permissions(room, command, sender)
        user_power = sender.power_in room
        raise PermissionError unless user_power >= self.class.command_power
        command.test
      end

      class << self
        attr_reader :commands

        attr_reader :command_power

        def inherited(subclass)
          {
            :@commands => [], :@patterns => [], :@command_power => 0
          }.each { |var, val| subclass.instance_variable_set(var, val) }
        end

        def command?(name)
          !command(name).nil?
        end

        # Gets the command with the specified name (or alias).
        # @param name [String] The name to search for, can also be an alias.
        # @return [Command] The command with the specified name or alias.
        def command(name)
          @commands.find { |c| c.name_or_alias?(name) }
        end

        # Attempts to match the given string against all the patterns defined
        # for the plugin.
        # @param text [String] The text to check for matches.
        # @return [Pattern, nil] The result of the first successful match,
        #   or `nil` if no match was found.
        def match(text)
          @patterns.find { |p| p.match? text }
        end

        protected

        # Registers a command that the plugin should respond to.
        #
        # @param command [String] The name of the command.
        # @param syntax [String] Command syntax, this is used to determine
        #   the parameters accepted by the command. See {Parameter} for more
        #   information on parameters and {Command} for more information
        #   regarding the structure of the syntax string.
        # @param help [String] Help text for the command.
        # @param opts [Hash] Additional options.
        #
        # @option opts [Symbol] :handler Name of the method in the plugin class
        #   that should handle this command.
        # @option opts [Array<String>] :aliases A list of aliases that can be
        #   used to call this command in addition to the main name.
        def register_command(command, syntax, help, opts = {})
          @commands.push Command.new command.to_s.downcase, syntax, help, opts
        end

        # Registers a RegEx pattern that the plugin should listen to
        # with an optional explicit handler for the match.
        #
        # @param pattern [Regexp] The RegEx pattern to add.
        # @param handler [Symbol, nil] The method to call on the plugin when
        #   a matching message is detected.
        def register_pattern(pattern, handler = nil)
          @patterns.push Pattern.new pattern, handler
        end

        # Adds RegEx patterns to the plugin.
        # @param patterns [Regexp] RegEx patterns to add.
        def register_patterns(*patterns)
          patterns.each { |p| @patterns.push Pattern.new p }
        end

        def command_restriction(level)
          @command_power = level
        end
      end
    end
  end
end
