# frozen_string_literal: true

module Chatrix
  class Bot
    module Plugins
      # Responds to !ping command with a "Pong!" message.
      class Ping < Plugin
        register_command 'ping', '', 'Pings the bot', handler: :ping

        def ping(room, sender, _command, _args)
          name = sender.displayname || sender.id
          room.messaging.send_message("#{name}: Pong!")
        end
      end
    end
  end
end
