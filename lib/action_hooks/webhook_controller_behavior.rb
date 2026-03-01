# frozen_string_literal: true

module ActionHooks
  module WebhookControllerBehavior
    extend ActiveSupport::Concern

    included do
      # Skip CSRF since webhooks are typically APIs
      skip_before_action :verify_authenticity_token, raise: false if respond_to?(:skip_before_action)

      before_action :verify_webhook_ip!
      before_action :verify_webhook_signature!
      before_action :persist_webhook_request!
    end

    private

    def persist_webhook_request!
      @webhook_request = ActionHooks::WebhookRequest.create!(
        source: webhook_source_name.to_s,
        payload: parse_webhook_payload,
        state: :pending
      )
    end

    def webhook_source_name
      raise NotImplementedError, "You must define `#webhook_source_name` in your webhook controller."
    end

    def webhook_source_config
      ActionHooks.configuration.source(webhook_source_name)
    end

    def verify_webhook_ip!
      allowed_ips = webhook_source_config.allowed_ips
      return if allowed_ips.empty?

      unless allowed_ips.include?(request.remote_ip)
        head :forbidden
      end
    end

    def verify_webhook_signature!
      unless webhook_source_config.verify_signature.call(request)
        head :unauthorized
      end
    end

    def parse_webhook_payload
      if request.content_type == "application/json"
        JSON.parse(request.body.read).tap do
          request.body.rewind
        end
      else
        request.parameters.except(:controller, :action).to_unsafe_h
      end
    rescue JSON::ParserError
      {}
    end
  end
end
