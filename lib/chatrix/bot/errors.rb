module Chatrix
  class Bot
    class BotError < RuntimeError
    end

    class CommandError < BotError
    end

    class PermissionError < CommandError
    end
  end
end
