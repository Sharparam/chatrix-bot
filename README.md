# chatrix-bot

A bot for [Matrix][matrix], written in Ruby with plugin support.

## License

Copyright (c) 2016 by [Adam Hellberg][sharparam].

The project is available as open source under
the terms of the [MIT License][license].

## Installation

### As a system application

Install the project as a gem on your system by running `gem install chatrix-bot`
and then refer to the [Usage](#usage) section in this document.

### In another Ruby project

Add this line to your application's Gemfile:

```ruby
gem 'chatrix-bot'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chatrix-bot

## Usage

**NOTE: chatrix-bot is very early in development and probably very unstable.**

This project is not ready for deployment as a stable bot, it's for
development use only at the moment.

Run the `chatrix-bot` executable in the `exe` directory to start the bot
with default options (loading config from `config.yaml`). To generate a new
config, pass the `-g` option with optional path to the config file to generate.

To specify a config file to use when running the bot, pass the `-c` option
with the path to the config file to use.

The bot can also be used from within other Ruby scripts by requiring
`chatrix/bot` and creating a new instance of `Chatrix::Bot`.

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests. You can also run `bin/console`
for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on [GitHub][issues].

[matrix]: http://matrix.org
[issues]: https://github.com/Sharparam/chatrix-bot/issues
[sharparam]: https://github.com/Sharparam
[license]: http://opensource.org/licenses/MIT
