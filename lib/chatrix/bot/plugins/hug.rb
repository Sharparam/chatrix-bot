# frozen_string_literal: true

module Chatrix
  class Bot
    module Plugins
      # Plugin that hugs sad people!
      class Hug < Plugin
        # Matches :(, :'(, D:, D':, ):, )':, ;-;, ;_;
        register_pattern(/(?<!\S)(?:\:'?\(|D'?:|\)'?:|;[\-_];)(?!\S)/, :hug)
        register_pattern(/(?<!\S)(?:\:'?c)(?!\S)/i, :hug)

        # Method to handle messages that contain sad faces.
        def hug(room, message, _match)
          sender = message.sender
          @log.debug "#{sender} is in need of some love!"
          room.messaging.send_emote "hugs #{sender.displayname || sender}"
          @log.debug 'Love sent'
        end
      end
    end
  end
end
