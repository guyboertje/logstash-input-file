# encoding: utf-8

require "spec/spec_helper"
require "logstash/inputs/component"

class InputTestComponent
  include LogStash::Inputs::Component
end

describe LogStash::Inputs::Component do
  let(:upstream)   { ComponentTracer.new }
  let(:downstream) { ComponentTracer.new }

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

  describe "Public API" do
    it "has methods" do
      expect(subject).to respond_to(:component_type)
      expect(subject).to respond_to(:upstream)
      expect(subject).to respond_to(:downstream)
      expect(subject).to respond_to(:accept)
      expect(subject).to respond_to(:deliver)
      expect(subject).to respond_to(:do_work)
      expect(subject).to respond_to(:accept_meta)
    end
  end
end
