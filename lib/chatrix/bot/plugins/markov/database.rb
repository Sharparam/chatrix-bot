# frozen_string_literal: true

require 'sqlite3'
require 'sequel'

module Chatrix
  class Bot
    module Plugins
      class Markov < Plugin
        # A database to store Markov word data.
        class Database
          def initialize(file)
            init_db! file

            @data = @db[:data]

            @insert = @data.prepare(:insert, :insert_data,
                                    first: :$f, second: :$s, word: :$w)

            @update = @data.where(first: :$f, second: :$s, word: :$w)
                           .prepare(:update, :update_data,
                                    count: Sequel.+(:count, 1))
          end

          def add(pair, word)
            # First try to update an existing entry
            rows = @update.call(f: pair.first, s: pair.last, w: word)

            return if rows > 0

            # If no rows were affected it means that entry doesn't exist
            @insert.call(f: pair.first, s: pair.last, w: word)
          end

          def sum(pair)
            @data.where(first: pair.first, second: pair.last).sum(:count) || 0
          end

          def sorted(pair)
            @data.where(first: pair.first, second: pair.last)
                 .select(:word, :count).reverse_order(:count).all
          end

          def transaction
            @db.transaction { yield }
          end

          private

          def init_db!(file)
            @db = Sequel.sqlite file

            @db.create_table? :data do
              primary_key :id
              String :first, null: true
              String :second, null: true
              String :word, null: false
              Integer :count, null: false, default: 1
            end
          end
        end
      end
    end
  end
end
