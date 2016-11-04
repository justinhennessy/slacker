require 'dogapi'

module Slacker
  module Plugins
    class HelpPlugin < Plugin
      def ready(robot)
        SendLog.log.info "Loading help plugin ..."

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
          "Available commands:\n"
          "@holly show events - currently shows any upcoming events for ec2 instances for staging" \
          "@holly free trials - shows the number of free trials in rackspace production" \

        output
      end
    end
  end
end
