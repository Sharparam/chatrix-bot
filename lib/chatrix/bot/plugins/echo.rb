# encoding: utf-8
# frozen_string_literal: true

module Chatrix
  class Bot
    module Plugins
      # Provides a command to make the bot echo what was passed in as
      # argument to the command.
      class Echo < Plugin
        register_command 'echo', '<text>',
                         'Makes the bot echo the specified text to chat',
                         aliases: ['say'], handler: :say

        def say(room, sender, command, args)
          @bot.send_message room, args[:text]
        end
      end
    end
  end
end
