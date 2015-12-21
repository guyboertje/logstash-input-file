# encoding: utf-8

require "spec/spec_helper"
require "tempfile"
require "stud/temporary"
require "logstash/inputs/watcher_component"
require "filewatch/tail"

describe LogStash::Inputs::WatcherComponent do
  let(:upstream)   { ComponentTracer.new }
  let(:downstream) { ComponentTracer.new }

  let(:loggr)      { FileLogTracer.new }
  let(:watchloggr) { FileLogTracer.new }

  let(:tmpfile_path) { Stud::Temporary.pathname }
  let(:sincedb_path) { Stud::Temporary.pathname }
  let(:conf) do
    { :exclude => [],
      :stat_interval => 0.1,
      :discover_interval => 3,
      :sincedb_write_interval => 15,
      :sincedb_path => sincedb_path,
      :delimiter => $/,
      :start_new_files_at => :beginning,
      :ignore_after => 10 * 60,
      :logger => watchloggr }
  end

  let(:watcher) do
    FileWatch::Tail.new_accepting(conf).tap do |instance|
      instance.tail(tmpfile_path)
    end
  end

  let(:start_lines) { ["dont ignore me 1", "dont ignore me 2"] }

  subject do
    described_class.new(:head, upstream, downstream).tap do |instance|
      instance.logger = loggr
      instance.add_watcher(watcher)
    end
  end

  before do
    File.open(tmpfile_path, "w") do |fd|
      start_lines.each {|l| fd.puts(l) }
    end
    Thread.new { subject.run }
  end

  after do
    subject.stop
  end

  context "when reading the file from the beginning" do
    it "passes the context downstream" do
      sleep(0.3)
      expected_logs = [
        ["Received line", {:path=>tmpfile_path, :text=>start_lines[0]}],
        ["Received line", {:path=>tmpfile_path, :text=>start_lines[1]}]
      ]
      expect(loggr.trace_for(:debug)).to eq(expected_logs)
      expected_accept_args = [
        [{:path=>tmpfile_path, :action=>"created"}, nil],
        [{:path=>tmpfile_path, :action=>"line"}, start_lines[0]],
        [{:path=>tmpfile_path, :action=>"line"}, start_lines[1]],
        [{:path=>tmpfile_path, :action=>"eof"}, nil],
        [{:path=>tmpfile_path, :action=>"eof"}, nil]
      ]
      expect(downstream.trace_for(:accept)).to eq(expected_accept_args)
    end
  end
end
