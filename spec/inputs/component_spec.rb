# encoding: utf-8

require "spec/spec_helper"
require "logstash/inputs/component"

class InputTestComponent
  include LogStash::Inputs::Component
end

describe LogStash::Inputs::Component do
  let(:upstream)   { FileInput::ComponentTracer.new }
  let(:downstream) { FileInput::ComponentTracer.new }

  subject { InputTestComponent.new(:link, upstream, downstream) }

  context "when constructing new instances" do
    it "has a type, upstream and downstream components" do
      expect(subject.upstream).to eq(upstream)
      expect(subject.downstream).to eq(downstream)
      expect(subject.component_type).to eq(:link)
    end
  end

  context "when accepting context and data" do
    let(:ctx)  { Object.new }
    let(:data) { Object.new }

    it "passes the args downstream" do
      subject.accept(ctx, data)
      expect(downstream.trace_for(:accept)).to eq([[ctx, data]])
    end
  end

  describe "attr_accessors" do
    subject { InputTestComponent.new(:link, nil, nil) }

    it "allows upstream to be specified" do
      expect(subject.upstream).to be_nil
      subject.upstream = upstream
      expect(subject.upstream).to eq(upstream)
    end

    it "allows downstream to be specified" do
      expect(subject.downstream).to be_nil
      subject.downstream = downstream
      expect(subject.downstream).to eq(downstream)
    end

    it "allows logger to be specified" do
      expect(subject.logger).to be_a(Cabin::Channel)
      subject.logger = Object.new
      expect(subject.logger).not_to be_a(Cabin::Channel)
    end
  end

  describe "Public API" do
    it "has methods" do
      expect(subject).to respond_to(:component_type)
      expect(subject).to respond_to(:upstream)
      expect(subject).to respond_to(:downstream)
      expect(subject).to respond_to(:accept)
      expect(subject).to respond_to(:deliver)
      expect(subject).to respond_to(:do_work)
      expect(subject).to respond_to(:meta)
      expect(subject).to respond_to(:accept_meta)
    end
  end
end
