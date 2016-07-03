# encoding: utf-8
# frozen_string_literal: true

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
      end

      class << self
        @commands = []

        # @return [Array] an array of RegEx patterns that the plugin should
        #   listen to.
        @patterns = []

        alias register_pattern register_patterns

        # Gets the command with the specified name (or alias).
        # @param name [String] The name to search for, can also be an alias.
        # @return [Command] The command with the specified name or alias.
        def command(name)
          @commands.find { |c| c.name_or_alias?(name) }
        end

        # Attempts to match the given string against all the patterns defined
        # for the plugin.
        # @param text [String] The text to check for matches.
        # @return [MatchData, nil] The result of the first successful match,
        #   or `nil` if no match was found.
        def match(text)
          @patterns.each do |pattern|
            match = pattern.match text
            return match if match
          end
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

        # Adds RegEx patterns to the plugin.
        # @param patterns [Regexp] RegEx patterns to add.
        def register_patterns(*patterns)
          @patterns.concat patterns
        end

        private

        def parse_parameters(syntax, &block)
          ret = []
          syntax.scan(/([<\[])([\w\ ]+)[>\]]/) do |match|
            clean = match[1].gsub(/\s+/, '_')
            required = match[0] == '<'
            yield clean, required if block
            ret.push [clean, required]
          end
          ret
        end
      end
    end
  end
end
