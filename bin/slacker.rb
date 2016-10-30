#!/usr/bin/ruby

# Load all environment variables from @bkeeper's "dotenv"
require 'dotenv'
Dotenv.load

require_relative '../lib/robot'
require_relative '../lib/adapters/slack/slack_adapter'
#require_relative '../lib/plugins/util_plugin'
#require_relative '../lib/plugins/jira/jira_integration'
require_relative '../lib/plugins/coin_flip_plugin'
#require_relative '../lib/plugins/timezone_plugin'
#require_relative '../lib/plugins/remember_plugin'
#require_relative '../lib/plugins/graphite/graphite_ensemble'
require_relative '../lib/plugins/github/github_ensemble'
require_relative '../lib/plugins/buildkite'
require_relative '../lib/plugins/aws'
#require_relative '../lib/plugins/aws_maintenance'
#require_relative '../lib/plugins/pagerduty'
require_relative '../lib/sendlog'


["         __           __               ",
 "   _____/ /___ ______/ /_____  _____   ",
 "  / ___/ / __ `/ ___/ //_/ _ \\/ ___/  ",
 " (__  ) / /_/ / /__/ ,< /  __/ /       ",
 "/____/_/\\__,_/\\___/_/|_|\\___/_/     ",
 "",                                      ].each do |segment|
  puts segment.green
end


r = Slacker::Robot.new(ENV["NAME"])

SendLog.log.info "Loading plugins ..."
# Attach all the plugins
#r.plug(Slacker::Plugins::UtilPlugin.new)
#r.plug(Slacker::Plugins::JiraIntegration.new)
r.plug(Slacker::Plugins::CoinFlipPlugin.new)
#r.plug(Slacker::Plugins::AwsMaintenancePlugin.new)
r.plug(Slacker::Plugins::BuildKitePlugin.new)
#r.plug(Slacker::Plugins::PagerDutyPlugin.new)
#r.plug(Slacker::Plugins::TimezonePlugin.new)
#r.plug(Slacker::Plugins::RememberPlugin.new)
#r.plug(Slacker::Plugins::GraphiteEnsemble.new)
#r.plug(Slacker::Plugins::GitHubEnsemble.new)
SendLog.log.info "Loaded plugins!"
SendLog.log.info "Launching ..."
# Plug in the adapter and run
r.attach(Slacker::Adapters::SlackAdapter.new(r))
