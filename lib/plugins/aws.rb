require 'aws-sdk'

module Slacker
  module Plugins
    class AWSPlugin < Plugin
      def ready(robot)
        robot.respond /(show|events|tainted)/i do |message|
          message << aws(message.text)
        end
      end

      def aws(text)
        #action, build, project, build_number = text.split(" ")

        case
        when text.match(/show events/)
          result = show_events
        when text.match(/show tainted/)
          result = show_tainted
        else
          result = cant_find_response
        end

        result
      end

      def show_events
        output_events
      end

      def show_tainted
          ec2_client = Aws::EC2::Client.new
          instances = ec2_client.describe_instances(filters:[{ name: 'tag:tainted', values: ["true"] }])

          tainted_instances_detail = []

          instances.reservations.each { |reservation|
            reservation.instances.each { |instance|
              tainted_instances = {}
              tainted_instances[:instance_id] = instance.instance_id
              instance.tags.each { |tag|
                tainted_instances[tag.key] = tag.value if ['Name', 'environment'].include?(tag.key)
              }
              tainted_instances_detail.push(tainted_instances)
            }
          }

        if tainted_instances_detail.empty?
          output = "There are no tainted instances"
        else
          sorted_instances = tainted_instances_details.sort_by { |k| k["environment"] }

          output = "```"

           sorted_instances.each { |instance|
             output << "#{instance.name} (#{instance.instance_id}) - #{instance.environment}"
           }

          output = "```"
        end
        output
      end

      private

      def output_events
        instances = instances_with_events

        if instances.empty?
          output = "There are no scheduled events"
        else
          output = "```"

          instances.each { |instance|
            output << "#{instance.instance_id} (#{instance.availability_zone})"
            instance.events.each { |event|
              output << "\n  #{event.code}: #{event.description} (not_before: #{event.not_before}, not_after: #{event.not_after})"
            }
          }
          output << "```"
        end
        output
      end

      def instances_with_events
        ec2_client = Aws::EC2::Client.new
        instances_status = ec2_client.describe_instances(filters:[{ name: 'tag:tainted', values: ["true"] }])

        instances_status.instance_statuses.select { |instance|
          !instance.events.empty?
        }
      end

    end
  end
end
