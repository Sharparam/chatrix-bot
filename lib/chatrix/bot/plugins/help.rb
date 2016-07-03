# frozen_string_literal: true

module Chatrix
  class Bot
    module Plugins
      # Provides a help command.
      class Help < Plugin
        register_command 'help', '[command]',
                         'Gives general help or specific help for a command',
                         handler: :help, aliases: ['h']

        def help(room, sender, _command, args)
          @log.debug "#{sender} is requesting help"
          command = args[:command]
          command.nil? ? general_help(room) : command_help(room, command)
        end

        private

        def general_help(room)
          commands = []

          @bot.plugin_manager.types.each do |type|
            commands.concat type.commands.map(&:name)
          end

          room.messaging.send_notice <<~EOF
            Available commands: #{commands.uniq.join ', '}
            For help about a command, type #{Command.stylize('help')} <command>
          EOF
        end

        def command_help(room, command)
          type = @bot.plugin_manager.types.find { |t| t.command? command }

          cmd = type.command(command) if type

          if cmd
            room.messaging.send_notice <<~EOF
              Command #{cmd.name} provided by #{type} plugin.
              #{cmd.usage}
            EOF
          else
            room.messaging.send_notice 'No plugin found providing that command'
          end
        end
      end
    end
  end
end
