# frozen_string_literal: true

module ActionHooks
  class WebhookRequest < ActiveRecord::Base
    self.table_name = "webhook_requests"

    enum :state, {pending: 0, processed: 1, failed: 2}

    validates :source, presence: true
    validates :payload, presence: true
    validates :state, presence: true

    before_create :ensure_id

    private

    def ensure_id
      self.id ||= SecureRandom.uuid
    end
  end
end
