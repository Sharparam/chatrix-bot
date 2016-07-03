# frozen_string_literal: true

module Chatrix
  class Bot
    # General bot error.
    class BotError < RuntimeError
    end

    # Error raised while parsing a command.
    class CommandError < BotError
    end

    class PermissionError < CommandError
    end
  end
end
