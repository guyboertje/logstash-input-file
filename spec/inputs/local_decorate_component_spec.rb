# encoding: utf-8

require "spec/spec_helper"
require "logstash/inputs/local_decorate_component"

describe LogStash::Inputs::LocalDecorateComponent do
  let(:upstream)   { ComponentTracer.new }
  let(:downstream) { ComponentTracer.new }
  let(:loggr)      { FileLogTracer.new }
  let(:path)       { "baz" }
  let(:ctx)        { {:action => "event", :path => path} }
  let(:host)       { "foo" }

  let(:event) do
    { "message" => "bar" }
  end

  subject do
    described_class.new(:link, upstream, downstream).tap do |instance|
      instance.logger = loggr
      instance.accept_meta({:host => host})
    end
  end

  context "when accepting an event" do
    it "the event sent downstream has been decorated" do
      subject.accept(ctx, event)
      exctx, exevent = downstream.trace_for(:accept).first
      expect(exevent["host"]).to eq(host)
      expect(exevent["path"]).to eq(path)
      expect(exevent["[@metadata][path]"]).to eq(path)
    end
  end

  context "when the host is not specified" do
    it "the event sent downstream has been decorated without host" do
      subject.accept_meta({})
      subject.accept(ctx, event)
      exctx, exevent = downstream.trace_for(:accept).first
      expect(exevent).not_to include("host")
      expect(exevent["path"]).to eq(path)
      expect(exevent["[@metadata][path]"]).to eq(path)
    end
  end
end
