# frozen_string_literal: true

module Chatrix
  class Bot
    module Plugins
      # Lets users give or take karma from others (or just any term).
      class Karma < Plugin
        CHANGES = { '++' => 1, '--' => -1 }.freeze

        register_pattern(/\A([@\w:\.]+)(\+\+|--)\z/, :karma)

        def initialize(bot)
          super

          @config[:db] ||= {}
          @config.save
        end

        def karma(room, message, match)
          user = match[1].downcase
          update user, CHANGES[match[2]]
          room.messaging.send_message "#{user}'s karma is #{self[user]}."
        end

        def [](user)
          @config[:db][user] ||= 0
        end

        def []=(user, value)
          @config[:db][user] = value
          @config.save
        end

        private

        def update(user, change)
          self[user] += change
        end
      end
    end
  end
end
