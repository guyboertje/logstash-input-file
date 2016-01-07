# encoding: utf-8

require "logstash/namespace"
require "cabin"

module LogStash module Inputs module Component
  # if component_type is :head then it will only redefine the deliver method
  # if component_type is :tail then it will only redefine the accept method
  # if component_type is :link then it will only redefine the do_work method

  attr_accessor :upstream, :downstream, :logger
  attr_reader :meta

  def initialize(component_type, upstream, downstream)
    @component_type, @upstream, @downstream = component_type, upstream, downstream
    @logger = Cabin::Channel.get(LogStash)
  end

  def component_type
    @component_type
  end

  def accept_meta(opts = {})
    @meta = opts
    self
  end

  def accept(context, data = nil)
    do_work(context, data)
  end

  def do_work(context, data)
    deliver(context, data)
  end

  def deliver(context, data)
    downstream.accept(context, data)
  end

  private

  def meta_valid?
    meta.is_a(Hash)
  end
end end end
