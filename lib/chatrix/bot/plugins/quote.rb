# frozen_string_literal: true

module Chatrix
  class Bot
    module Plugins
      # Lets users add quotes on a topic and retrieve a random quote from
      # a given topic.
      class Quote < Plugin
        register_command 'quote', '[topic] [quote]',
                         'Get a quote from a topic, or add quotes to a topic.' \
                         ' Calling without arguments lists a selection' \
                         ' of topics.',
                         handler: :quote, aliases: ['q']

        register_command 'qprotect', '<topic>',
                         'Toggles protection for a topic', handler: :protect

        register_pattern(/\A~([^\s]+)\s*(.+)?\z/m, :tilde)

        def initialize(bot)
          super
          @db = (@config[:db] ||= {})
          @protected = (@config[:protected] ||= [])
        end

        def quote(room, _sender, _command, args)
          return list_topics(room) if args[:topic].nil?
          topic = args[:topic].downcase
          quote = args[:quote]
          return random_quote(room, topic) if quote.nil?
          add_quote(room, topic, quote)
        end

        def protect(room, sender, _command, args)
          raise PermissionError unless @bot.admin? sender
          topic = args[:topic]
          @protected.send(@protected.member?(topic) ? :delete : :push, topic)
          kind = @protected.member?(topic) ? 'protected' : 'unprotected'
          room.messaging.send_notice "#{topic} #{kind}!"
          @config.save
        end

        def tilde(room, message, match)
          quote(room, message.sender, 'quote', topic: match[1], quote: match[2])
        end

        private

        def list_topics(room)
          top = top_topics 10
          topics = top.empty? ? 'None!' : top.join(', ')
          room.messaging.send_notice "Available topics: #{topics}\n" \
                                     '(Only the top 10 topics are shown)'
        end

        def random_quote(room, topic)
          quote = @db[topic].sample if @db[topic]
          quote ||= "I have nothing to say about #{topic}..."
          room.messaging.send_message quote
        end

        def add_quote(room, topic, quote)
          quote.strip!
          return if quote.empty? || (@db[topic] ||= []).member?(quote)
          return notify_protected(room, topic) if @protected.member? topic
          @db[topic].push quote
          room.messaging.send_notice 'Quote added!'
          @config.save
        end

        def top_topics(amount)
          @db.keys.sort { |a, b| @db[b].size - @db[a].size }.first amount
        end

        def notify_protected(room, topic)
          room.messaging.send_notice "Unable to add to #{topic}, topic has " \
                                     'been made protected.'
        end
      end
    end
  end
end
