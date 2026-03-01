# frozen_string_literal: true

ActionHooks.configure do |config|
  # Example Configuration for Stripe
  # config.add_source(:stripe) do |source|
  #   source.worker = "StripeWebhookWorker" # Ensure you have this ActiveJob defined
  #
  #   # Verify signature logic (returns a boolean)
  #   source.verify_signature = ->(request) do
  #     # Example:
  #     # payload = request.body.read
  #     # sig_header = request.env['HTTP_STRIPE_SIGNATURE']
  #     # Stripe::Webhook::Signature.verify_header(payload, sig_header, 'whsec_...', tolerance: Stripe::Webhook::DEFAULT_TOLERANCE)
  #     true
  #   end
  #
  #   # Optional: IP allowlist
  #   # source.allowed_ips = ["127.0.0.1", "10.0.0.1"]
  # end
end
