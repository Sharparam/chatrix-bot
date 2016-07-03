# frozen_string_literal: true

module Chatrix
  class Bot
    # Describes a pattern used for matching messages.
    class Pattern
      attr_reader :pattern

      attr_reader :handler

      def initialize(pattern, handler = nil)
        @pattern = pattern
        @handler = handler
      end

      def match?(text)
        !match(text).nil?
      end

      def match(text)
        @pattern.match text
      end
    end
  end
end
