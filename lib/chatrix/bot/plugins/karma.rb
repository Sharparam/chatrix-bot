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

          @config[:delay] ||= 10
          @config[:allow_self] = false if @config[:allow_self].nil?
          @config[:db] ||= {}

          @history = {}

          @config.save
        end

        def karma(room, message, match)
          return unless can_give? message.sender

          user = match[1].downcase

          return if modifying_self? message.sender, user

          update user, CHANGES[match[2]]
          room.messaging.send_message "#{user}'s karma is #{self[user]}."

          given message.sender
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

        def can_give?(user)
          return true unless @history[user.id]
          (Time.now - @history[user.id]) < @config[:delay]
        end

        def given(user)
          @history[user.id] = Time.now
        end

        def modifying_self?(sender, target)
          [sender.id.downcase, sender.displayname.downcase].member? target
        end
      end
    end
  end
end
