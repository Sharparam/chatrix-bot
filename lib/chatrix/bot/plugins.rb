# encoding: utf-8
# frozen_string_literal: true

require 'chatrix/bot/plugin'

module Chatrix
  class Bot
    # Contains a number of standard plugins for the bot.
    module Plugins
    end
  end
end

require 'chatrix/bot/plugins/help'
require 'chatrix/bot/plugins/ping'
require 'chatrix/bot/plugins/info'
require 'chatrix/bot/plugins/echo'
require 'chatrix/bot/plugins/note'
require 'chatrix/bot/plugins/typo'
require 'chatrix/bot/plugins/quote'
require 'chatrix/bot/plugins/hug'
require 'chatrix/bot/plugins/url_info'
