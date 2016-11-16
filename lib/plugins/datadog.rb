require 'dogapi'

module Slacker
  module Plugins
    class DatadogPlugin < Plugin
      def ready(robot)
        robot.respond /(provisioner|trials|dumb|iq)/i do |message|
          message << datadog(message)
        end
      end

      def datadog(message)

        username = message.user['name']

        case message.text
        when /trials/
          result = provisioner_stats('trials.free')
          output = random_response(username, result)
        when /new/
          result = provisioner_stats('tasks.new')
          output = random_response(username, result)
        when /running/
          result = provisioner_stats('tasks.running')
          output = random_response(username, result)
        when /iq/
          output = "I have an IQ of 6000"
        when /dumb/
          output = "Ill have you know I have the IQ of 6000 PE teachers"
        else
          output = random_i_dont_know(username)
        end

        output
      end

      def random_i_dont_know(username)
        responses = ["Hey <@#{username}>, not sure what you mean by that",
                     "<@#{username}>, I am unsure what you are after",
                     "<@#{username}>, perhaps google it, im not sure what you mean",
                     "<@#{username}>, try help?"
          ]
        response_output = responses[rand(responses.length)]
        response_output
      end

      def random_response(name, result)
        responses = ["Hey <@#{name}>, there are #{result}",
                     "<@#{name}>, looks like there are #{result}",
                     "<@#{name}>, there are approximately #{result}",
                     "<@#{name}>, I am fairly certain there are #{result}",
                     "Hmm, there could possibly be #{result}"
          ]
        response_output = responses[rand(responses.length)]
        puts response_output
        response_output
      end

      def provisioner_stats(metric)
        api_key = ENV.fetch('DATADOG_API_KEY')
        application_key = ENV.fetch('DATADOG_APPLICATION_KEY')

        puts "Setting up datadog api object"
        dog = Dogapi::Client.new(api_key, application_key)

        # Get points from the last hour
        from = Time.now - 600
        to = Time.now
        query = "neto.provisioner.production.#{metric}.count{*}by{host}"
        metrics = dog.get_points(query, from, to)

        series = metrics[1]['series'].first

        metric_total = series['pointlist'].last.last
        puts "#{metric}: #{metric_total}"

        metric_total.to_i
      end
    end
  end
end
