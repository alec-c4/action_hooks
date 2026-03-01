# frozen_string_literal: true

module ActionHooks
  class WebhookController < ActionController::API
    include ActionHooks::WebhookControllerBehavior

    def create
      process_webhook(@webhook_request)
      head :ok
    end

    private

    def process_webhook(webhook_request)
      worker_class = webhook_source_config.worker
      worker_class&.constantize&.perform_later(webhook_request.id)
    end
  end
end
