# frozen_string_literal: true

require 'pstore'

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
          # We do to_s on the parameter since it can be nil, in which case
          # to_s makes it an empty string and reply will make an empty array.
          reply(room, args[:phrase].to_s.downcase)
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
          return if words.empty?
          words.size.times do |i|
            pair = extract_pair words, i
            add pair, words[i]
          end
        end

        def extract_pair(words, index)
          return [nil, nil] if index == 0
          return [nil, words[index - 1]] if index == 1
          words[index - 2..index - 1]
        end

        def extract_words(sentence)
          sentence.split.map(&:strip)
        end

        def add(pair, word)
          @db.transaction do
            ((@db[pair] ||= {})[word] ||= { count: 0 })[:count] += 1
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
          seed = make_seed message.split(' ')
          sentence = make_sentence(seed, rand(5..40)).strip
          sentence = "I can't talk about that :(" if sentence.empty?
          room.messaging.send_message sentence
        end

        def make_seed(words)
          return [nil, nil] if words.empty?
          return [nil, words.first] if words.size == 1
          rng = rand 0..words.size - 2
          words[rng..rng + 1]
        end

        def make_sentence(seed, length)
          build(seed, length).join ' '
        end

        def build(words, count)
          to_add = next_word extract_pair(words, words.size)
          return words if to_add.nil?
          words << to_add
          count == 0 ? words : build(words, count - 1)
        end
      end
    end
  end
end
