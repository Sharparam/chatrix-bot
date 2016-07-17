# frozen_string_literal: true

require 'chatrix/bot/plugins/markov/database'

module Chatrix
  class Bot
    module Plugins
      class Markov < Plugin
        # A simple Markov generator.
        class Generator
          def initialize(file)
            @db = Database.new file
          end

          def process(text)
            @db.transaction do
              extract_sentences(text).each { |sentence| train sentence }
            end
          end

          def train(sentence)
            return if sentence.empty?
            words = extract_words sentence
            return if words.empty?

            words.size.times { |i| @db.add extract_pair(words, i), words[i] }
          end

          def create(seed, length)
            build(seed, length).join ' '
          end

          private

          def extract_pair(words, index)
            return [nil, nil] if index == 0
            return [nil, words[index - 1]] if index == 1
            words[index - 2..index - 1]
          end

          def extract_words(sentence)
            sentence.split.map(&:strip)
          end

          def extract_sentences(text)
            text.tr("\n", ' ').split(/[\.!?;]/).map(&:strip)
          end

          def next_word(pair)
            sum = @db.sum(pair)

            return nil if sum < 1

            rng = rand 1..sum
            get_word @db.sorted(pair), rng
          end

          def get_word(words, value, index = 0, accum = 0)
            accum += words[index][:count]
            reached = value < accum
            at_end = index == words.size - 1
            return words[index][:word] if reached || at_end
            get_word words, value, index + 1, accum
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
end
