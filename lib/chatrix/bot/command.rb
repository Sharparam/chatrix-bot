# frozen_string_literal: true

require 'chatrix/bot/parameter'

module Chatrix
  class Bot
    class Command
      PREFIX = '!'

      attr_reader :name

      attr_reader :syntax

      attr_reader :help

      attr_reader :handler

      def initialize(name, syntax, help, opts = {})
        @name = name
        @syntax = syntax
        @help = help
        @aliases = opts[:aliases] || []
        @handler = opts[:handler]

        configure_parameters syntax, opts
      end

      def self.command?(message)
        !message.match(/^#{PREFIX}[^\s]/).nil?
      end

      def self.parse(message)
        return nil unless command? message

        name = message.match(/^#{PREFIX}([^\s]+)/)[1]
        rest = message.match(/ (.+)$/)
        body = rest.is_a?(MatchData) ? m[1].to_s : ''

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

      private

      def configure_parameters(syntax, options = {})
        @parameters = []
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
