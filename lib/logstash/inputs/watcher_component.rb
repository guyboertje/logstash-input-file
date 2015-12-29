# encoding: utf-8
require "logstash/inputs/component"

module LogStash module Inputs class WatcherComponent
  include Component

  def add_watcher(watch)
    @watcher = watch
    self
  end

  def stop
    @watcher.quit
  end

  def do_work(context, data)
    log_line_received(context[:path], data) if line?(context)
    deliver(context, data)
  end

  def log_line_received(path, line)
    return if !@logger.debug?
    @logger.debug("Received line", :path => path, :text => line)
  end

  def line?(ctx)
    ctx[:action] == "line"
  end
end end end
