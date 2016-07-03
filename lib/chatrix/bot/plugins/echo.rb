# encoding: utf-8
# frozen_string_literal: true

module Chatrix
  class Bot
    module Plugins
      # Provides a command to make the bot echo what was passed in as
      # argument to the command.
      class Echo < Plugin
        command_restriction 50

        register_command 'echo', '<text>',
                         'Makes the bot echo the specified text to chat',
                         aliases: ['say'], handler: :say

        register_command 'act', '<text>',
                         'Makes the bot perform an emote',
                         aliases: %w(em emote), handler: :emote

        register_command 'notice', '<text>', 'Sends a notice', handler: :notice

        def say(room, _sender, _command, args)
          room.messaging.send_message args[:text]
        end

        def emote(room, _sender, _command, args)
          room.messaging.send_emote args[:text]
        end

        def notice(room, _sender, _command, args)
          room.messaging.send_notice args[:text]
        end
      end
    end
  end
end
