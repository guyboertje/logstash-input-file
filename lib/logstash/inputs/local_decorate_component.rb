# encoding: utf-8
require "logstash/inputs/component"

module LogStash module Inputs class LocalDecorateComponent
  include Component

  def do_work(context, data)
    # data is a LS Event
    put_host(data)
    put_path(context[:path], data)
    deliver(context, data)
  end

  private

  def put_host(event)
    return if event.include?("host")
    if (host = meta_host)
      event["host"] = host
    end
  end

  def put_path(path, event)
    event["[@metadata][path]"] = path
    event["path"] = path if !event.include?("path")
  end

  def meta_host
    @meta[:host]
  end
end end end
