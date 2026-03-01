# frozen_string_literal: true

module ActionHooks
  class WebhooksController < ActionHooks::WebhookController
    rescue_from ActionHooks::SourceNotDefinedError, with: -> { head :not_found }

    private

    def webhook_source_name
      params[:source]
    end
  end
end
