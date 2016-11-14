require 'excon'
require 'json'
require 'buildkit'

module Slacker
  module Plugins
    class BuildKitePlugin < Plugin
      def ready(robot)
        robot.respond /(search|show|list|trigger|rebuild) build/i do |message|
          message << buildkite(message.text)
        end
        @client = Buildkit.new(token: ENV.fetch('BUILDKITE_API_KEY'))
        @organisation = 'neto-ecommerce'
        @pipeline = pipeline
        @options = { "per_page" => 1, "status" => "passed" }
      end

      def buildkite(text)
        action, pipeline, commit_sha = text.split(" ")

        case action
        when "list"
          result = list_builds(project)
        when "show"
          result = show_build(project,build_number)
        when "trigger"
          result = trigger_build(project) if project == "nginx"
        when "rebuild"
          result = trigger_rebuild(project,build_number)
        when "search"
          result = search_build(pipeline, commit_sha)
        end

        result
      end

      def search_build(pipeline, commit_sha)
        options_extra = { "commit" => commit_sha }
        @options.merge!(options_extra)

        SendLog.log.info "Making buildkite API call ..."
        build = @client.builds(@organisation, @pipeline, @options)
        Sendlog.log.info "Completed!"
        SendLog.log.info "Found build #{build}"
      end

      def list_builds(project)
        SendLog.log.info "Inside buildkite list_builds"
        result = Excon.get("https://api.buildkite.com/v1/organizations/#{@organisation}/projects/#{project}/builds/", :headers => {'Authorization' => "Bearer #{ENV.fetch('BUILDKITE_API_TOKEN')}"})
        SendLog.log.info "#{result.inspect}"
        output = '```'

        JSON.parse(result.body).take(1).each do |build|
          output << "#{build["number"]}:\n"
          build["jobs"].each do |job|
            output << "#{job["name"]} - #{job["state"]}\n" if job["type"] == "script"
          end
          output << "\n"
        end
        output << '```'
        SendLog.log.info "Debug output: #{output}"
        output
      end

      def trigger_rebuild(project,build_number)
        SendLog.log.info "Triggering rebuild of build #{build_number} in project #{project} ..."
        result = Excon.get("https://api.buildkite.com/v1/organizations/#{@organisation}/projects/#{project}/builds/#{build_number}/rebuild", :headers => {'Authorization' => "Bearer #{ENV.fetch('BUILDKITE_API_TOKEN')}"})
        SendLog.log.info "Response from API call to rebuild #{result.inspect}"
        result.body
      end

      def show_build(project,build_number)
        result = Excon.get("https://api.buildkite.com/v1/organizations/#{@organisation}/projects/#{project}/builds/#{build_number}", :headers => {'Authorization' => "Bearer #{ENV.fetch('BUILDKITE_API_TOKEN')}"})
        result.body
      end

      def trigger_build(project,build_number)
        result = Excon.get("https://api.buildkite.com/v1/organizations/#{@organisation}/projects/#{project}/builds/#{build_number}", :headers => {'Authorization' => "Bearer #{ENV.fetch('BUILDKITE_API_TOKEN')}"})

        manual_job_id = ""
        JSON.parse(result.body)["jobs"].each do |job|
          manual_job_id = job["id"] if job["state"] == "blocked" and job["type"] == "manual"
        end

        result = Excon.put("https://api.buildkite.com/v1/organizations/#{@organisation}/projects/#{project}/builds/#{build_number}/jobs/#{manual_job_id}/unblock", :headers => {'Authorization' => "Bearer #{ENV.fetch('BUILDKITE_API_TOKEN')}"})

        if JSON.parse(result.body)["state"] == "unblocked" then
          "Build #{latest_build_number} successfully triggered ..."
        else
          "Everybodys dead Dave ..."
        end
      end
    end
  end
end
