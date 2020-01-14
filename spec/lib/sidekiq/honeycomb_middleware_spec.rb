require "rails_helper"

class TestSidekiqWorker
  include Sidekiq::Worker
  sidekiq_options queue: :low_priority

  def perform(arg = nil)
    raise StandardError, "BOOM" if arg == "fail"
  end
end

RSpec.describe Sidekiq::HoneycombMiddleware do
  let(:expected_hash) do
    {
      "sidekiq.class" => TestSidekiqWorker.to_s,
      "sidekiq.queue" => "low_priority",
      "sidekiq.jid" => instance_of(String),
      "sidekiq.args" => ["dont fail"],
      "sidekiq.result" => "success"
    }
  end

  before do
    Sidekiq::Testing.inline!

    Sidekiq::Testing.server_middleware do |chain|
      chain.add described_class
    end
  end

  it "sends an event with expected keys" do
    TestSidekiqWorker.perform_async(*args)

    collected_data = Honeycomb.client.send("client").events.map(&:data).first
    expect(collected_data).to include(expected_hash)
  end

  context "with an error" do
    let(:error_hash) do
      {
        "sidekiq.class" => TestSidekiqWorker.to_s,
        "sidekiq.queue" => "low_priority",
        "sidekiq.jid" => instance_of(String),
        "sidekiq.args" => ["fail"],
        "sidekiq.error" => "BOOM",
        "sidekiq.result" => "error"
      }
    end

    it "sends an event with expected keys" do
      expect { TestSidekiqWorker.perform_async("fail") }.to raise_error(StandardError)

      collected_data = Honeycomb.client.send("client").events.map(&:data).detect { |h| h.key?("sidekiq.error") }
      expect(collected_data).to include(error_hash)
    end
  end
end
