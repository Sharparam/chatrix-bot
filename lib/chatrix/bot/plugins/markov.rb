# frozen_string_literal: true

require 'chatrix/bot/plugins/markov/generator'

module Chatrix
  class Bot
    module Plugins
      # Markov plugin using chat text for data.
      class Markov < Plugin
        register_command 'markov', '[phrase]', 'Sends a reply based on the' \
                         ' specified phrase (if no phrase is given, a random' \
                         ' phrase will be constructed).', handler: :force

        def initialize(bot)
          super

          @config[:delay] ||= 600
          @config[:threshold] ||= 30

          @gen = Generator.new File.join(@config.dir, 'markov.db')

          @last = Time.now
          @counter = 0

          save
        end

        def on_message(room, message)
          @gen.process message.body.downcase
          @counter += 1

          return unless can_reply? message

          # If the return from #reply is non-nil, it means a reply was
          # sent, and we should reset the counters.
          return if reply(room, message.body.downcase).nil?
          @last = Time.now
          @counter = 0
        end

        def force(room, _sender, _command, args)
          # We do to_s on the parameter since it can be nil, in which case
          # to_s makes it an empty string and reply will make an empty array.
          reply(room, args[:phrase].to_s.downcase)
        end

        private

        def can_reply?(message)
          return false if Command.command? message.body
          return false unless message.body =~ /^\w/
          elapsed = Time.now - @last
          elapsed > @config[:delay] && @counter > @config[:threshold]
        end

        def reply(room, message)
          seed = make_seed message.split(' ')
          sentence = @gen.create(seed, rand(5..40)).strip
          sentence = "I can't talk about that :(" if sentence.empty?
          room.messaging.send_message sentence
        end

        def make_seed(words)
          return [nil, nil] if words.empty?
          return [nil, words.first] if words.size == 1
          rng = rand 0..words.size - 2
          words[rng..rng + 1]
        end
      end
    end
  end
end
