# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chatrix/bot/version'

Gem::Specification.new do |spec|
  spec.name          = 'chatrix-bot'
  spec.version       = Chatrix::Bot::VERSION
  spec.authors       = ['Adam Hellberg']
  spec.email         = ['sharparam@sharparam.com']

  spec.summary       = 'A Ruby chatbot for Matrix with plugin support'
  # spec.description   = %q{}
  spec.homepage      = 'https://github.com/Sharparam/chatrix-bot'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3.0'

  spec.add_runtime_dependency 'chatrix', '~> 1.1'
  spec.add_runtime_dependency 'redcarpet', '~> 3.3'
  spec.add_runtime_dependency 'wisper', '~> 1.6'
  spec.add_runtime_dependency 'daemons', '~> 1.2'
  spec.add_runtime_dependency 'httparty', '~> 0.13'
  spec.add_runtime_dependency 'filesize', '~> 0.1'
  spec.add_runtime_dependency 'nokogiri', '~> 1.6'
  spec.add_runtime_dependency 'sqlite3', '~> 1.3'
  spec.add_runtime_dependency 'sequel', '~> 4.36'

  spec.add_development_dependency 'bundler', '~> 1.12'
end
