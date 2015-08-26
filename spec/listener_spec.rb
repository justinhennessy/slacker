require_relative 'spec_helper'
require_relative '../lib/listener'

include Slacker::SpecHelper

describe Slacker::Robot do
  let(:responder_block) { Proc.new { |message| }}

  it "dispatches :call to matching messages" do
    #@robot.respond(/^message$/, &responder_block)

    #expect(responder_block).to receive(:call)
    #@robot.hear(construct_message("slacker message"))
  end

  it "doesn't dispatch :call to messages that don't match" do
    @robot.respond(/foo/, &responder_block)

    expect(responder_block).not_to receive(:call)
    @robot.hear(construct_message("hubot foo"))
  end
end
