module Chatrix
  class Bot
    module Plugins
      class Karma < Plugin
        CHANGES = { '++' => 1, '--' => -1 }

        register_pattern(/\A([@\w:\.]+)(\+\+|--)\z/, :karma)

        def karma(room, message, match)
          user = match[1].downcase
          update_karma user, CHANGES[match[2]]
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

        def update_karma(user, change)
          self[user] += change
        end
      end
    end
  end
end
