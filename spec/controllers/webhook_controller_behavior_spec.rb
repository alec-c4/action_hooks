# frozen_string_literal: true

require "spec_helper"
require "active_job"

class DummyWorker < ActiveJob::Base
  def perform(webhook_request_id)
  end
end

class DummyWebhooksController < ActionHooks::WebhookController
  private

  def webhook_source_name
    :dummy
  end
end

RSpec.describe DummyWebhooksController, type: :controller do
  before do
    ActionHooks.configure do |config|
      config.add_source(:dummy) do |source|
        source.worker = "DummyWorker"
        source.allowed_ips = ["127.0.0.1"]
        source.verify_signature = ->(request) { request.headers["X-Signature"] == "valid" }
      end
    end

    routes.draw { post "dummy_webhooks" => "dummy_webhooks#create" }
  end

  describe "POST #create" do
    let(:valid_ip) { "127.0.0.1" }
    let(:invalid_ip) { "192.168.1.1" }

    it "returns 403 Forbidden if IP is not allowed" do
      request.remote_addr = invalid_ip
      post :create, body: '{"foo":"bar"}', as: :json
      expect(response).to have_http_status(:forbidden)
    end

    it "returns 401 Unauthorized if signature is invalid" do
      request.remote_addr = valid_ip
      request.headers["X-Signature"] = "invalid"
      post :create, body: '{"foo":"bar"}', as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns 200 OK, saves webhook, and enqueues job if valid" do
      request.remote_addr = valid_ip
      request.headers["X-Signature"] = "valid"

      expect {
        post :create, body: '{"foo":"bar"}', as: :json
      }.to change(ActionHooks::WebhookRequest, :count).by(1)

      expect(response).to have_http_status(:ok)

      webhook_request = controller.instance_variable_get(:@webhook_request)
      expect(webhook_request.source).to eq("dummy")

      parsed_payload = webhook_request.payload.is_a?(String) ? JSON.parse(webhook_request.payload) : webhook_request.payload
      expect(parsed_payload).to eq({"foo" => "bar"})
      expect(webhook_request.state).to eq("pending")
    end

    it "sets @webhook_request as an instance variable after persistence" do
      request.remote_addr = valid_ip
      request.headers["X-Signature"] = "valid"
      post :create, body: '{"foo":"bar"}', as: :json
      expect(controller.instance_variable_get(:@webhook_request)).to be_a(ActionHooks::WebhookRequest)
    end
  end
end
