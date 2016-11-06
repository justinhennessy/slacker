require 'dogapi'

module Slacker
  module Plugins
    class DatadogPlugin < Plugin
      def ready(robot)
        robot.respond /.*(free trials).*/i do |message|
          message << datadog(message.text)
        end
      end

      def datadog(text)
        case text
        when /.*(free trials).*/
          result = number_free_trials
        end

        result
      end

      def number_free_trials
        api_key = ENV.fetch('DATADOG_API_KEY')
        application_key = ENV.fetch('DATADOG_APPLICATION_KEY')

        SendLog.log.info "Setting up datadog api object"
        dog = Dogapi::Client.new(api_key, application_key)

        # Get points from the last hour
        from = Time.now - 600
        to = Time.now
        query = 'neto.infrastructure.free_trial.count{*}by{host}'
        free_trial_metrics = dog.get_points(query, from, to)

        series = free_trial_metrics[1]['series'].first

        total_free_trials = series['pointlist'].last.last
        SendLog.log.info "Total free trials: #{total_free_trials}"

        total_free_trials.to_i
      end
    end
  end
end
