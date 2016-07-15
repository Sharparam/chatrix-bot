# frozen_string_literal: true

require 'pstore'

module Chatrix
  class Bot
    module Plugins
      # Markov plugin using chat text for data.
      class Markov < Plugin
        register_command 'markov', '<word1> <word2>', 'Sends a reply built' \
                         ' from the specified two words (more than two words' \
                         ' can also be passed, in which a random pair is' \
                         ' selected from the sentence and used as the seed' \
                         ' value.', handler: :force

        def initialize(bot)
          super

          @config[:db] ||= {}
          @config[:delay] ||= 600
          @config[:threshold] ||= 30

          init_db

          @last = Time.now
          @counter = 0
        end

        def on_message(room, message)
          process message.body.downcase
          @counter += 1

          return unless can_reply? message

          # If the return from #reply is non-nil, it means a reply was
          # sent, and we should reset the counters.
          return if reply(room, message.body.downcase).nil?
          @last = Time.now
          @counter = 0
        end

        def force(room, _sender, _command, args)
          reply(room, "#{args[:word1].downcase} #{args[:word2].downcase}")
        end

        private

        def init_db
          @db = PStore.new File.join(@config.dir, 'db.pstore')
        end

        def process(text)
          text.tr("\n", ' ').split(/[\.!?]/).each do |sentence|
            train(sentence.strip)
          end
        end

        def train(sentence)
          return if sentence.empty?
          words = extract_words sentence
          return if words.size < 3
          (words.size - 2).times do |i|
            add words[i..i + 1].join(' '), words[i + 2]
          end
        end

        def extract_words(sentence)
          sentence.split.map(&:strip)
        end

        def add(pair, word)
          @db.transaction do
            @db[pair] = {} unless @db.root? pair
            @db[pair][word] = { count: 0 } unless @db[pair].key? word
            @db[pair][word][:count] += 1
          end
        end

        def next_word(pair)
          sum = @db.transaction(true) do
            @db.abort unless @db.root? pair
            @db[pair].values.reduce(0) { |a, e| a + e.count }
          end

          return nil if sum.nil? || sum < 1

          rng = rand 1..sum
          get_word sorted_words(pair), rng
        end

        def sorted_words(pair)
          arr = @db.transaction(true) do
            @db[pair].map { |w, d| { word: w, count: d[:count] } }
          end

          arr.sort { |a, b| b[:count] - a[:count] }
        end

        def get_word(words, value, index = 0, accum = 0)
          accum += words[index][:count]
          return words[index][:word] if value < accum || index == words.size - 1
          get_word words, value, index + 1, accum
        end

        def can_reply?(message)
          return false if Command.command? message.body
          return false unless message.body =~ /^\w/
          elapsed = Time.now - @last
          elapsed > @config[:delay] && @counter > @config[:threshold]
        end

        def reply(room, message)
          words = message.split ' '
          return unless words.size > 1
          rng = rand 0..words.size - 2
          seed = words[rng..rng + 1]
          room.messaging.send_message make_sentence(seed, rand(5..40))
        end

        def make_sentence(seed, length)
          words = build(seed, length)
          words.join ' '
        end

        def build(words, count)
          to_add = next_word words[-2..-1].join(' ')
          return words if to_add.nil?
          words << to_add
          count == 0 ? words : build(words, count - 1)
        end
      end
    end
  end
end
