require 'excon'
require 'json'

module Slacker
  module Plugins
    class BuildKitePlugin < Plugin
      def ready(robot)
        robot.respond /(show|list|trigger|rebuild) build/i do |message|
          message << buildkite(message.text)
        end
      end

      def buildkite(text)
        action, build, project, build_number = text.split(" ")

        case action
        when "list"
          result = list_builds(project)
        when "show"
          result = show_build(project,build_number)
        when "trigger"
          result = trigger_build(project) if project == "nginx"
        when "rebuild"
          result = trigger_rebuild(project,build_number)
        end

        result
      end

      def list_builds(project)
        result = Excon.get("https://api.buildkite.com/v1/organizations/everyday-hero/projects/#{project}/builds/", :headers => {'Authorization' => "Bearer #{ENV.fetch('BUILDKITE_API_TOKEN')}"})
        output = '```'

        JSON.parse(result.body).take(1).each do |build|
          output << "#{build["number"]}:\n"
          build["jobs"].each do |job|
            output << "#{job["name"]} - #{job["state"]}\n" if job["type"] == "script"
          end
          output << "\n"
        end
        output << '```'
        output
      end

      def trigger_rebuild(project,build_number)
        SendLog.log.info "Triggering rebuild of build #{build_number} in project #{project} ..."
        result = Excon.get("https://api.buildkite.com/v1/organizations/everyday-hero/projects/#{project}/builds/#{build_number}/rebuild", :headers => {'Authorization' => "Bearer #{ENV.fetch('BUILDKITE_API_TOKEN')}"})
        SendLog.log.info "Response from API call to rebuild #{result.inspect}"
        result.body
      end

      def show_build(project,build_number)
        result = Excon.get("https://api.buildkite.com/v1/organizations/everyday-hero/projects/#{project}/builds/#{build_number}", :headers => {'Authorization' => "Bearer #{ENV.fetch('BUILDKITE_API_TOKEN')}"})
        result.body
      end

      def trigger_build(project,build_number)
        result = Excon.get("https://api.buildkite.com/v1/organizations/everyday-hero/projects/#{project}/builds/#{build_number}", :headers => {'Authorization' => "Bearer #{ENV.fetch('BUILDKITE_API_TOKEN')}"})

        manual_job_id = ""
        JSON.parse(result.body)["jobs"].each do |job|
          manual_job_id = job["id"] if job["state"] == "blocked" and job["type"] == "manual"
        end

        result = Excon.put("https://api.buildkite.com/v1/organizations/everyday-hero/projects/#{project}/builds/#{build_number}/jobs/#{manual_job_id}/unblock", :headers => {'Authorization' => "Bearer #{ENV.fetch('BUILDKITE_API_TOKEN')}"})

        if JSON.parse(result.body)["state"] == "unblocked" then
          "Build #{latest_build_number} successfully triggered ..."
        else
          "Everybodys dead Dave ..."
        end
      end
    end
  end
end
