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

        register_pattern(/^~([^\s]+)\s*(.+)?$/, :tilde)

        def initialize(bot)
          super
          @db = (@config[:db] ||= {})
        end

        def quote(room, _sender, _command, args)
          return list_topics(room) if args[:topic].nil?
          topic = args[:topic].downcase
          quote = args[:quote]
          return random_quote(room, topic) if quote.nil?
          add_quote(room, topic, quote)
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
          @db[topic].push quote
          room.messaging.send_notice 'Quote added!'
          @config.save
        end

        def top_topics(amount)
          @db.keys.sort { |a, b| @db[b].size - @db[a].size }.first amount
        end
      end
    end
  end
end
