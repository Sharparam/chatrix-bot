# frozen_string_literal: true

require 'chatrix/bot/parameter'

module Chatrix
  class Bot
    # Describes a plugin command.
    class Command
      PREFIX = '!'

      attr_reader :name

      attr_reader :syntax

      attr_reader :help

      attr_reader :handler

      attr_reader :required_power

      def initialize(name, syntax, help, opts = {})
        @name = name
        @syntax = syntax
        @help = help || 'No special help available for this command.'
        @aliases = opts[:aliases] || []
        @handler = opts[:handler]
        @required_power = opts[:power] || 0

        configure_parameters syntax, opts
      end

      def self.command?(message)
        !message.match(/^#{PREFIX}[^\s]/).nil?
      end

      def self.extract_name(message)
        message.match(/^#{PREFIX}([^\s]+)/)[1]
      end

      def self.stylize(name)
        "#{PREFIX}#{name}" unless command? name
      end

      def self.parse(message)
        return nil unless command? message

        name = message.match(/^#{PREFIX}([^\s]+)/)[1]
        rest = message.match(/ (.+)$/)
        body = rest.is_a?(MatchData) ? rest[1].to_s : ''

        { name: name, body: body }
      end

      def name_or_alias?(name)
        @name == name || @aliases.member?(name)
      end

      def parse(message)
        data = {}

        @parameters.each_with_index do |param, index|
          last = index == @parameters.count - 1
          parsed = param.parse message, last ? Parameter::MATCHERS[:rest] : nil

          break if parsed.nil?

          data[param.name] = parsed[:content]
          message = parsed[:rest]
        end

        data
      end

      def usage
        <<~EOF
        Usage: #{self.class.stylize(name)} #{syntax || ''}
        #{help}
        Required power level to use: #{required_power}
        Aliases: #{@aliases.join ', '}
        EOF
      end

      def test(user, room)
        raise PermissionError unless user.power_in(room) >= required_power
      end

      private

      def configure_parameters(syntax, options = {})
        @parameters = []
        return if syntax.nil? || syntax.empty?
        syntax.scan(/([<\[])([\w\ ]+)[>\]]/) do |match|
          param = match[1].gsub(/\s+/, '_').to_sym
          required = match[0] == '<'
          matcher = options[:matchers][param] if options.key? :matchers
          @parameters.push Parameter.new param, required, matcher
        end
      end
    end
  end
end
