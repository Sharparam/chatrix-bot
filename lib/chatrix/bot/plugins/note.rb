# frozen_string_literal: true

module Chatrix
  class Bot
    module Plugins
      # Allows users to keep a personal note.
      class Note < Plugin
        register_command 'note', '[content]',
                         'Set a new personal note, or clear an existing one ' \
                         'if the note content is "clear". Use without an ' \
                         'argument to see your current note.',
                         handler: :note

        def note(room, sender, _command, args)
          return read_note(room, sender) unless args[:content]
          set_note(room, sender, args[:content])
        end

        private

        def read_note(room, sender)
          content = @config[sender.id]

          if content
            room.messaging.send_notice "Note: #{content}"
          else
            room.messaging.send_notice "You don't have a note set!"
          end
        end

        def set_note(room, sender, content)
          return clear_note(room, sender) if content == 'clear'
          @config[sender.id] = content.to_s
          @config.save
          room.messaging.send_notice "OK! Note set: #{@config[sender.id]}"
        end

        def clear_note(room, sender)
          @config[sender.id] = nil
          @config.save
          room.messaging.send_notice 'OK! Note cleared.'
        end
      end
    end
  end
end
