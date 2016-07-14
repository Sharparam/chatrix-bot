# frozen_string_literal: true

module Chatrix
  class Bot
    module Plugins
      # Lets users give or take karma from others (or just any term).
      class Karma < Plugin
        CHANGES = { '++' => 1, '--' => -1 }.freeze

        register_pattern(/\A([@\w:\.]+)(\+\+|--)\z/, :karma)

        def karma(room, message, match)
          user = match[1].downcase
          update user, CHANGES[match[2]]
          room.messaging.send_message "#{user}'s karma is #{self[user]}."
        end

        def [](user)
          @config[user] ||= 0
        end

        def []=(user, value)
          @config[user] = value
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
