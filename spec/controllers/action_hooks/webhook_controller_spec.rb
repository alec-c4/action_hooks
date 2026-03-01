# frozen_string_literal: true

require "spec_helper"
require "active_job"

class DummyJob < ActiveJob::Base
  def perform(id)
  end
end

class TestWebhooksController < ActionHooks::WebhookController
  private

  def webhook_source_name
    :test_source
  end
end

RSpec.describe TestWebhooksController, type: :controller do
  before do
    ActionHooks.configure do |config|
      config.add_source(:test_source) do |source|
        source.worker = "DummyJob"
        source.allowed_ips = ["127.0.0.1"]
        source.verify_signature = ->(request) { request.headers["X-Sig"] == "ok" }
      end
    end

    routes.draw { post "test_webhooks" => "test_webhooks#create" }
    request.remote_addr = "127.0.0.1"
    request.headers["X-Sig"] = "ok"
  end

  it "responds 200 and sets @webhook_request" do
    post :create, body: '{"type":"ping"}', as: :json
    expect(response).to have_http_status(:ok)
    expect(controller.instance_variable_get(:@webhook_request)).to be_a(ActionHooks::WebhookRequest)
  end

  it "calls process_webhook with the webhook_request" do
    allow(controller).to receive(:process_webhook)
    post :create, body: '{"foo":"bar"}', as: :json
    expect(controller).to have_received(:process_webhook).with(instance_of(ActionHooks::WebhookRequest))
  end

  context "when process_webhook is overridden" do
    before do
      described_class.define_method(:process_webhook) do |wr|
        @processed = wr
      end
    end

    it "calls the overridden implementation" do
      post :create, body: '{"foo":"bar"}', as: :json
      expect(controller.instance_variable_get(:@processed)).to be_a(ActionHooks::WebhookRequest)
    end
  end
end
