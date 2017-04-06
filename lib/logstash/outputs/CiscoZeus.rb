# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require "logstash/json"
require 'zeus/api_client'

# Outputs events to CiscoZeus 
class LogStash::Outputs::Ciscozeus < LogStash::Outputs::Base
  config_name "CiscoZeus"

  config :token, :validate => :string, :required => true
  config :endpoint, :validate => :string, :default => "api.ciscozeus.io"
  config :log_name, :validate => :string, :default => "logstash_data"

  concurrency :shared

  def register
    @zeus_client = Zeus::APIClient.new({
      access_token: @token,
      endpoint: @endpoint
    })
  end # def register

  def multi_receive(events)
    events.group_by{ |ev| ev.sprintf(@log_name) }.each do |log_name, events_group| 
      result = @zeus_client.send_logs(log_name, events_group)
      if not result.success?
        STDERR.puts "Failed to send data to zeus: " + result.data.to_s
      end
    end
  end # def receive
end # class LogStash::Outputs::Ciscozeus
