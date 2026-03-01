# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActionHooks::WebhookRequest, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      request = described_class.new(source: "stripe", payload: {foo: "bar"}.to_json, state: :pending)
      expect(request).to be_valid
    end

    it "is invalid without a source" do
      request = described_class.new(source: nil)
      expect(request).not_to be_valid
    end
  end

  describe "state enum" do
    it "defaults to pending" do
      request = described_class.new(source: "stripe", payload: {}.to_json)
      expect(request.state).to eq("pending")
    end
  end
end
