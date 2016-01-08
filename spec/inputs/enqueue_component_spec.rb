# encoding: utf-8

require "spec/spec_helper"
require "logstash/inputs/enqueue_component"
require "logstash/event"

describe LogStash::Inputs::EnqueueComponent do
  let(:upstream)   { FileInput::ComponentTracer.new }
  let(:downstream) { FileInput::ComponentTracer.new }
  let(:loggr)      { FileInput::FileLogTracer.new }
  let(:queue)      { [] }
  let(:ctx)        { {:action => "event"} }

  let(:event) do
    LogStash::Event.new "message" => "foo"
  end

  subject do
    described_class.new(:link, upstream, downstream).tap do |instance|
      instance.logger = loggr
      instance.add_queue(queue)
    end
  end

  context "when accepting an event" do
    it "the event is put into the queue" do
      subject.accept(ctx, event)
      expect(queue.first).to eq(event)
    end
  end
end
