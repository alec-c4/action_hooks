# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActionHooks::Configuration do
  subject(:configuration) { described_class.new }

  describe "#add_source" do
    it "adds a source to the configuration" do
      configuration.add_source(:stripe) do |source|
        source.worker = "StripeWorker"
        source.verify_signature = ->(request) { true }
        source.allowed_ips = ["127.0.0.1"]
      end

      source = configuration.source(:stripe)
      expect(source.worker).to eq("StripeWorker")
      expect(source.allowed_ips).to eq(["127.0.0.1"])
    end
  end

  describe "#source" do
    it "raises an error if the source is not defined" do
      expect { configuration.source(:unknown) }.to raise_error(ActionHooks::SourceNotDefinedError)
    end
  end
end
