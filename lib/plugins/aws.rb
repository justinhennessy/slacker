require 'aws-sdk'

module Slacker
  module Plugins
    class AWSPlugin < Plugin
      def ready(robot)
        robot.respond /show events/i do |message|
          message << aws(message.text)
        end
      end

      def aws(text)
        #action, build, project, build_number = text.split(" ")

        case text
        when "show events"
          result = show_events
        end

        result
      end

      def show_events
        ec2_client = Aws::EC2::Client.new
        result = output_events
        result.body
      end

      private

      def output_events
        instances = instances_with_events

        instances.each { |instance|
          puts "#{instance.instance_id} (#{instance.availability_zone})"
          instance.events.each { |event|
            puts "  #{event.code}: #{event.description} (not_before: #{event.not_before}, not_after: #{event.not_after})"
          }
        }
      end

      def instances_with_events
        instances_status = @ec2_client.describe_instance_status

        instances_status.instance_statuses.select { |instance|
          !instance.events.empty?
        }
      end

    end
  end
end
