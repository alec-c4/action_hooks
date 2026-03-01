# frozen_string_literal: true

require "spec_helper"
require "active_job"

class CatchAllJob < ActiveJob::Base
  def perform(id)
  end
end

RSpec.describe ActionHooks::WebhooksController, type: :controller do
  before do
    ActionHooks.configure do |config|
      config.add_source(:catchall) do |source|
        source.worker = "CatchAllJob"
        source.allowed_ips = ["127.0.0.1"]
        source.verify_signature = ->(request) { request.headers["X-Sig"] == "ok" }
      end
    end

    routes.draw { post "webhooks/:source" => "action_hooks/webhooks#create" }
    request.remote_addr = "127.0.0.1"
    request.headers["X-Sig"] = "ok"
  end

  describe "POST #create" do
    it "resolves source from params, persists and responds 200" do
      expect {
        post :create, params: {source: "catchall"}, body: '{"x":1}', as: :json
      }.to change(ActionHooks::WebhookRequest, :count).by(1)

      expect(response).to have_http_status(:ok)
      expect(controller.instance_variable_get(:@webhook_request).source).to eq("catchall")
    end

    it "returns 404 for an unconfigured source" do
      post :create, params: {source: "unknown"}, body: "{}", as: :json
      expect(response).to have_http_status(:not_found)
    end
  end
end
