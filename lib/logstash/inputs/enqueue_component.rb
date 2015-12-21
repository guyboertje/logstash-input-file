# encoding: utf-8
require "logstash/inputs/component"

# refactor when the pipeline has an accept method

module LogStash module Inputs class EnqueueComponent
  include Component

  attr_reader :queue # could be the persistance queue

  def add_queue(queue)
    @queue = queue
    self
  end

  def accept(context, data)
    # by this time, data is definitely an event
    # blocking
    queue.push(data)
  end
end end end
