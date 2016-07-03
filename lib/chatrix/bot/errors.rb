module Chatrix
  class Bot
    class BotError < RuntimeError
    end

    class CommandError < BotError
    end
  end
end
