# frozen_string_literal: true

module Chatrix
  class Bot
    module Plugins
      # Plugin to query various information about the bot.
      class Info < Plugin
        register_command 'info', nil, 'Provides info about the bot',
                         handler: :info

        register_command 'uptime', nil,
                         'Tells how long the bot has been running for',
                         handler: :uptime

        def initialize(bot)
          super
          @info = "I am chatrix-bot v#{Chatrix::Bot::VERSION}, " +
                  "using chatrix v#{Chatrix::VERSION}."
        end

        def info(room, _sender, _command, _data)
          room.messaging.send_notice @info
        end

        def uptime(room, _sender, _command, _data)
          duration = pretty_duration @bot.uptime
          room.messaging.send_notice "Current uptime: #{duration}"
        end

        private

        def pretty_duration(seconds)
          days = seconds / 60**2 / 24
          hours = seconds / 60**2 - days * 24
          minutes = seconds / 60 - hours * 60 - days * 24 * 60
          seconds -= minutes * 60 + hours * 60**2 + days * 24 * 60**2
          '%02d:%02d:%02d:%02d' % [days, hours, minutes, seconds]
        end
      end
    end
  end
end
