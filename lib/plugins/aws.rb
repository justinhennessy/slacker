require 'aws-sdk'

module Slacker
  module Plugins
    class AWSPlugin < Plugin
      def ready(robot)
        SendLog.log.info "inside ready"
        Sendlog.log.info "rr: #{robot.respond.inspect}"
        robot.respond /(show events)/i do |message|
          message << aws(message.text)
        end
      end

      def aws(text)
        SendLog.log.info "inside aws"
        #action, build, project, build_number = text.split(" ")

        case text
        when "show events"
          result = show_events
        end

        result
      end

      def show_events
        SendLog.log.info "Inside show_events"
        result = output_events
        result.body
      end

      private

      def output_events
        instances = instances_with_events

        output = ""

        instances.each { |instance|
          output = "#{instance.instance_id} (#{instance.availability_zone})"
          instance.events.each { |event|
            output << "\n  #{event.code}: #{event.description} (not_before: #{event.not_before}, not_after: #{event.not_after})"
          }
        }
        output
      end

      def instances_with_events
        ec2_client = Aws::EC2::Client.new
        instances_status = ec2_client.describe_instance_status

        instances_status.instance_statuses.select { |instance|
          !instance.events.empty?
        }
      end

    end
  end
end
