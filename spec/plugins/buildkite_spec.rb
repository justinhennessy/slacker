require_relative '../spec_helper'
require_relative "../../lib/plugins/plugin"
require_relative "../../lib/plugins/buildkite"
require 'json'

describe Slacker::Plugins::BuildKitePlugin do
  before(:each) do
    @robot.plug(Slacker::Plugins::BuildKitePlugin.new)
  end

  it "response to list builds" do
    message = construct_message("#{bot_name} list build nginx")
    response = JSON.parse(@robot.hear(message).response.first)
    expect(response.first["number"]).to eq(38)
  end

  it "responds to show build" do
    message = construct_message("#{bot_name} show build nginx 33")
    response = JSON.parse(@robot.hear(message).response.first)
    expect(response["number"]).to eq(33)
  end

  it "responds to trigger build"
end
