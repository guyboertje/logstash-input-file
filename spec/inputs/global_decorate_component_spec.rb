# encoding: utf-8

require "spec/spec_helper"
require "logstash/inputs/global_decorate_component"
require "logstash/event"

describe LogStash::Inputs::GlobalDecorateComponent do
  let(:upstream)   { ComponentTracer.new }
  let(:downstream) { ComponentTracer.new }
  let(:loggr)      { FileLogTracer.new }
  let(:name)       { "bar" }
  let(:ctx)        { {:action => "event"} }
  let(:ttype)      { "foo" }

  let(:event) do
    LogStash::Event.new "message" => "bar"
  end

  subject do
    described_class.new(:link, upstream, downstream).tap do |instance|
      instance.logger = loggr
      instance.accept_meta(
        {:type => ttype, :plugin_name => name, :tags => ["nginx"], :add_field => {"baz"=>"quux"} })
    end
  end

  context "when accepting an event" do
    it "the event sent downstream has been decorated" do
      subject.accept(ctx, event)
      exctx, exevent = downstream.trace_for(:accept).first
      expect(exevent["type"]).to eq(ttype)
      expect(exevent["tags"]).to eq(["nginx"])
      expect(exevent["baz"]).to eq("quux")
    end
  end
end
