# encoding: utf-8

require "spec/spec_helper"
require "logstash/inputs/identity_map_codec_component"

describe LogStash::Inputs::IdentityMapCodecComponent do
  let(:codec)      { CodecTracer.new }
  let(:upstream)   { ComponentTracer.new }
  let(:downstream) { ComponentTracer.new }
  let(:loggr)      { FileLogTracer.new }
  let(:path)       { "path/to/some/file.log" }
  let(:ctx)        { {:path => path} }
  let(:line)       { "line1" }

  let(:event) do
    { "message" => line }
  end

  subject do
    described_class.new(:link, upstream, downstream).tap do |instance|
      instance.logger = loggr
      instance.add_codec(codec)
    end
  end

  context "when accepting a line of data" do
    it "calls accept on downstream with an event and context" do
      ctx.update(:action => 'line')
      subject.accept(ctx, line)
      expect(codec).to receive_call_and_args(:decode_accept, [[ctx, line]])
      exctx, exevent = downstream.trace_for(:accept).first
      expect(exctx[:action]).to eq("event")
      expect(exevent).to eq(event)
    end
  end

  context "when accepting a timed_out action" do
    before do
      subject.accept(ctx.merge(:action => 'line'), line)
      codec.clear
      downstream.clear
      ctx.update(:action => 'timed_out')
    end

    it "calls auto_flush on codec" do
      subject.accept(ctx, line)
      expect(codec).to receive_call_and_args(:auto_flush, [true])
    end

    it "does not call accept on downstream" do
      subject.accept(ctx, line)
      expect(downstream).to receive_call_and_args(:accept, false)
    end

    it "evicts the identity" do
      count = 0 + subject.codec.identity_count
      expect(count).to eq(1)
      subject.accept(ctx, line)
      expect(subject.codec.identity_count).to eq(count.pred)
    end
  end

end
