require 'aws-sdk'

module Slacker
  module Plugins
    class AwsMaintenancePlugin < Plugin
      def ready(robot)
        robot.respond /aws maintenance/i do |message|
          message << aws_maintenance
        end
      end

      def aws_maintenance
        #access_key_id     = "AKIAIL6WBQJCCNDNEWQQ"
        #secret_access_key = "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"
        
        access_key_id     = "AKIAI6AFWTSRZ7BADQAQ"
        secret_access_key = "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"

        output = "Summary\n"

        AWS.config(
          :access_key_id     => access_key_id,
          :secret_access_key => secret_access_key)

        ec2 = AWS.ec2

        node = ec2.client.describe_instance_status

        node.instance_status_set.each { |instance|
          instance.events_set && instance.events_set.each { |event|
            output << "#{ec2.instances[instance.instance_id].tags["Name"]} (#{instance.instance_id} #{instance.availability_zone}) - #{event.description}, Not Before: #{event.not_before}, Not After: #{event.not_after}\n"
          }
        }

        output
      end
    end
  end
end
