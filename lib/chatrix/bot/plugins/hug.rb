# frozen_string_literal: true

module Chatrix
  class Bot
    module Plugins
      # Plugin that hugs sad people!
      class Hug < Plugin
        # Matches :(, :'(, D:, D':, ):, )':, ;-;, ;_;
        register_pattern(
          /(?<!\S)(?:\:'?\-?[\(cC]|[D\)]'?:|;[\-_];)(?!\S)/,
          :hug
        )

        register_pattern(/
          \A
          (?:
            don'?t\s+hug\s+me
            |
            i\s+(?:hate|don'?t\s+like)\s+hugs?
          )[\!\.]*
          \z/ix, :filter)

        register_pattern(/
          \A
          i\s+
          (?:need|want|like|love)
          \s+(?:a\s+)?hugs?[\!\.]*\z
          /ix, :reset)

        def initialize(bot)
          super
          @config[:filter] ||= {}
        end

        # Method to handle messages that contain sad faces.
        def hug(room, message, _match)
          sender = message.sender
          return if @config[:filter][sender.id]
          @log.debug "#{sender} is in need of some love!"
          room.messaging.send_emote "hugs #{sender.displayname || sender}"
          @log.debug 'Love sent'
        end

        def filter(room, message, _match)
          sender = message.sender
          return if @config[:filter][sender.id]
          @config[:filter][sender.id] = true
          save
          room.messaging.send_message(
            "I'm sorry you feel that way, #{sender.displayname}. :("
          )
        end

        def reset(room, message, _match)
          sender = message.sender
          @config[:filter][sender.id] = false
          save
          hug room, message, nil
        end
      end
    end
  end
end
