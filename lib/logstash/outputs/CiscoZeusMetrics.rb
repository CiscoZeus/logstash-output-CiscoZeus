# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require "logstash/json"
require 'zeus/api_client'

# Outputs metrics to CiscoZeus
class LogStash::Outputs::Ciscozeusmetrics < LogStash::Outputs::Base
  config_name "CiscoZeusMetrics"

  config :token, :validate => :string, :required => true
  config :endpoint, :validate => :string, :default => "api.ciscozeus.io"
  config :metric_name, :validate => :string, :default => "logstash_metric"

  # The plugin forwards all the numeric fields in the event by default.
  # Use this variable to select a specific set of fields instead,
  #   in such a case, only the selected fields will be forwarded to Zeus.
  #   Besides, even if some field is of a non-numeric type,
  #   the plugin will try to convert it using ruby type casting.
  config :fields, :validate => :string, :list => true, :default => nil

  concurrency :shared

  def register
    @zeus_client = Zeus::APIClient.new({
      access_token: @token,
      endpoint: @endpoint
    })
  end # def register

  def multi_receive(events)
    metrics = events.map{|event| reform(event)}
    result = @zeus_client.send_metrics(@metric_name, metrics)
    if not result.success?
      STDERR.puts "Failed to send data to zeus: " + result.data.to_s
    end
  end # def receive

  #Matches Zeus metrics API format
  def reform(event)
    datapoint = {}
    if @fields == nil
      datapoint = event.to_hash.select{ |k,v| k != "@timestamp" and v.is_a? Numeric }
    else
      datapoint = event.to_hash.select{ |k,v| @fields.include? k }
      datapoint = Hash[datapoint.map{ |k,v|  [k,if v.is_a? Numeric then v else v.to_f end]}]
    end
    return {timestamp: event.get("@timestamp").to_f, point: datapoint}
  end # def reform

end # class LogStash::Outputs::Ciscozeusmetrics
