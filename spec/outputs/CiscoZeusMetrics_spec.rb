# encoding: utf-8
require "logstash/devutils/rspec/spec_helper"
require "logstash/outputs/Ciscozeusmetrics"
require "logstash/codecs/plain"
require "logstash/event"

describe LogStash::Outputs::Ciscozeusmetrics do

  def performTest(input, expected_output, configuration)
    event = LogStash::Event.new(input)

    configuration["token"] = "tk"
    metrics_plugin = LogStash::Outputs::Ciscozeusmetrics.new(configuration)

    expected_output[:timestamp] = event.get("@timestamp").to_f

    output = metrics_plugin.reform(event)

    #Workaround to convert string keys into symbols
    output[:point] = output[:point].inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}

    expect(output).to eq(expected_output)
  end

  describe "Simple message with one metric" do
    input = {"metric1": 6}
    output = {"point": {"metric1": 6}}
    it "works as expected" do
      performTest(input,output,{})
    end
  end

  describe "Simple message with several metric" do
    input = {"metric1": 6, "metric2":7}
    output = {"point":{"metric1":6, "metric2":7}}
    it "works as expected" do
      performTest(input,output,{})
    end
  end

  describe "Message with non numerical fields" do
    input = {"message": "hello", "world": "earth", "metric1": 6.5, "metric2":7}
    output = {"point":{"metric1":6.5, "metric2":7}}
    it "works as expected" do
      performTest(input,output,{})
    end
  end

  describe "Field selection" do
    input = {"message": "hello", "world": "earth", "metric1": 6.5, "metric2":7}
    output = {"point":{"metric1":6.5}}
    conf = {"fields" => "metric1"}
    it "works as expected" do
      performTest(input,output,conf)
    end
  end

  describe "Field selection with type cast needed" do
    input = {"metric1": 6.5, "metric2":7, "metric3":"24"}
    output = {"point":{"metric1":6.5, "metric3": 24}}
    conf = {"fields" => ["metric1", "metric3"]}
    it "works as expected" do
      performTest(input,output,conf)
    end
  end
end
