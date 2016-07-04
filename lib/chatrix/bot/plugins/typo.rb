# frozen_string_literal: true

module Chatrix
  class Bot
    module Plugins
      class Typo < Plugin
        PATTERN = %r{^\s*s/((?:\\/|[^/])+)/((?:\\/|[^/])*)/([img]*)\s*$}

        PATTERN_OTHER = %r{
          ^\s*([\w@:\.]+)\s*: # The username to correct
          #{PATTERN.source[1..-1]} # PATTERN without the first char
        }x

        register_pattern PATTERN, :fix

        register_pattern PATTERN_OTHER, :fix_other

        def initialize(bot)
          super
          @messages = {}
        end

        def on_message(room, message)
          return unless PATTERN.match(message.body).nil?
          (@messages[room.id] ||= {})[message.sender] = message.body
        end

        def fix(room, message, match)
          old = last_message(room, message.sender)

          return unless old

          fixed = replace(old, match[1], match[2], match[3])
          name = message.sender.displayname || message.sender.id

          room.messaging.send_message "#{name} meant: #{fixed}"

          @messages[room.id][message.sender] = fixed
        end

        def fix_other(room, message, match)
          name = match[1]
          old = last_message(room, name)

          return unless old

          fixed = replace(old, match[2], match[3], match[4])
          sender = message.sender.displayname || message.sender.id

          room.messaging.send_message "#{sender} thinks #{name} meant: #{fixed}"
        end

        private

        def last_message(room, user)
          return nil unless @messages[room.id]
          return @messages[room.id][user] if user.is_a? User

          res = @messages[room.id].find do |s, _|
            s.id == user || s.displayname == user
          end

          res.last if res
        end

        def replace(msg, find, replace, opts)
          opts = opts.split('').uniq

          options = opts.member?('i') ? Regexp::IGNORECASE : 0
          options |= Regexp::MULTILINE if opts.member? 'm'

          meth = opts.member?('g') ? :gsub : :sub

          msg.send(meth, Regexp.new(find, options), replace)
        end
      end
    end
  end
end
