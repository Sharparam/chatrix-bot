# frozen_string_literal: true

module Chatrix
  class Bot
    module Plugins
      # Plugin to query various information about the bot.
      class Info < Plugin
        TIME_MULTS = [24, 60, 60, 1].freeze

        register_command 'info', nil, 'Provides info about the bot',
                         handler: :info

        register_command 'uptime', nil,
                         'Tells how long the bot has been running for',
                         handler: :uptime

        def initialize(bot)
          super
          @info = "I am chatrix-bot v#{Chatrix::Bot::VERSION}, " \
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
          values = get_values(seconds)
          format '%03d' + ':%02d' * (values.size - 1), *values
        end

        def get_values(remain, index = 0, acc = [])
          return acc if index == TIME_MULTS.count

          mult = time_mult index

          acc.push remain / mult

          get_values remain - acc.last * mult, index + 1, acc
        end

        def time_mult(index)
          TIME_MULTS[index..-1].reduce { |a, e| a * e }
        end
      end
    end
  end
end
