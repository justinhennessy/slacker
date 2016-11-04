require 'dogapi'

module Slacker
  module Plugins
    class DatadogPlugin < Plugin
      def ready(robot)
        robot.respond /(free trials)/i do |message|
          message << aws(message.text)
        end
      end

      def datadog(text)
        #action, build, project, build_number = text.split(" ")

        case text
        when "free trials"
          result = number_free_trials
        end

        result
      end

      def number_free_trials
        api_key = ENV.fetch('DATADOG_API_KEY')
        application_key = ENV.fetch('DATADOG_APPLICATION_KEY')

        dog = Dogapi::Client.new(api_key, application_key)

        # Get points from the last hour
        from = Time.now - 600
        to = Time.now
        query = 'neto.infrastructure.free_trial.count{*}by{host}'
        test = dog.get_points(query, from, to)

        series = test[1]['series'].first

        total_free_trials = series['pointlist'].last.last
      end
    end
  end
end
