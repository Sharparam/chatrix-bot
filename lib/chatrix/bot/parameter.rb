# frozen_string_literal: true

module Chatrix
  class Bot
    # Describes a parameter in a command.
    class Parameter
      MATCHERS = {
        normal: /[^\s]+/,
        quoted: /"(?:\\"|[^"])*?"/,
        rest: /.+\z/m
      }.freeze

      attr_reader :name

      attr_reader :required

      def initialize(name, required, matcher = nil)
        @name = name
        @required = required
        @matcher = matcher || MATCHERS[:normal]
      end

      def required?
        required
      end

      def match(text, matcher = nil)
        (matcher || @matcher).match text
      end

      def parse(text, matcher = nil)
        if required && text.empty?
          raise CommandError, "Missing required parameter #{name}"
        end

        return nil if text.empty?

        match = match text.gsub(/^\s+/, '').gsub(/\s+$/, ''), matcher

        return nil unless valid_match? match

        {
          content: match.to_s,
          rest: match.post_match.gsub(/^\s+/, '').gsub(/\s+$/, '')
        }
      end

      private

      def valid_match?(match)
        return true unless match.nil?
        raise CommandError, "Missing required parameter #{name}" if required
        false
      end
    end
  end
end
