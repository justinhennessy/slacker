require 'dogapi'

module Slacker
  module Plugins
    class HelpPlugin < Plugin
      def ready(robot)
        robot.respond /(help)$/i do |message|
          message << help(message.text)
        end
      end

      def help(text)
        case text
        when "help"
          result = show_help
        end

        result
      end

      def show_help
        output = "```"

        output << \
          "Available commands:\n\n" \
          "free trials - shows the number of free trials in rackspace production\n"
          "provisioner [new|running] - shows how many provisioner tasks are new or running\n"
          "show events - currently shows any upcoming events for ec2 instances for staging\n" \

        output << "```"

        output
      end
    end
  end
end
