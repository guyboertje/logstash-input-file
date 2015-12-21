# encoding: utf-8
require "logstash/inputs/component"
require "logstash/util/decorators"

module LogStash module Inputs class GlobalDecorateComponent
  include Component

  def do_work(context, data)
    # data is a LS Event
    put_type(data)
    LogStash::Util::Decorators.add_fields(meta_add_field, data, meta_plugin_name)
    LogStash::Util::Decorators.add_tags(meta_tags, data, meta_plugin_name)
  end

  private

  def put_type(event)
    # Only set 'type' if not already set. This is backwards-compatible behavior
    return if event.include?("type")
    if (t = meta_type)
      event["type"] = t
    end
  end

  def meta_type
    @meta[:type]
  end

  def meta_add_field
    @meta[:add_field]
  end

  def meta_tags
    @meta[:tags]
  end

  def meta_plugin_name
    @meta[:plugin_name]
  end

end end end
