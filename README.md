# ActionHooks

ActionHooks is a Ruby on Rails engine designed to securely handle incoming webhooks. It standardizes the process of receiving webhooks from various third-party services (like Stripe, GitHub, etc.) by:

1. **Persisting Webhooks:** Saving all incoming requests to the database (`webhook_requests` table) with their payload, source, and processing state before any business logic is executed.
2. **Security & Verification:** Verifying the authenticity of the webhook via signature validation logic and optionally restricting access by IP address.
3. **Asynchronous Processing:** Automatically dispatching the saved webhook to a configured background worker (`ActiveJob`) for asynchronous processing.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "action_hooks"
```

And then execute:

```bash
$ bundle install
```

After installing the gem, you need to run the installation generator. This will create the necessary database migration for the `webhook_requests` table and an initializer file.

```bash
$ rails generate action_hooks:install
```

Run the database migrations:

```bash
$ rails db:migrate
```

## Usage

### 1. Configuration

Configure your webhook sources in the generated initializer (`config/initializers/action_hooks.rb`). Each source represents a third-party service sending webhooks to your application. ActionHooks automatically mounts a catch-all route `POST /webhooks/:source`, so configuring a source is enough to start receiving requests.

```ruby
# config/initializers/action_hooks.rb
ActionHooks.configure do |config|
  config.add_source(:stripe) do |source|
    # The ActiveJob worker class that will process the webhook
    source.worker = "StripeWebhookJob"

    # Lambda to verify the signature of the incoming request
    source.verify_signature = ->(request) do
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      # Example using Stripe's library:
      # Stripe::Webhook::Signature.verify_header(payload, sig_header, ENV['STRIPE_WEBHOOK_SECRET'])
      true
    end

    # Optional: Restrict incoming requests to specific IP addresses/hosts
    # source.allowed_hosts = ["127.0.0.1", "10.0.0.1"] # Also aliased as `allowed_ips`
  end
end
```

### 2. Generating a Job

By default, an incoming webhook is authenticated, persisted, and handed over to a background job. You can easily generate a job template for your source:

```bash
$ rails generate action_hooks:webhook stripe
```

This will create `app/jobs/stripe_webhook_job.rb`. The background job will receive the ID of the saved `ActionHooks::WebhookRequest` record:

```ruby
# app/jobs/stripe_webhook_job.rb
class StripeWebhookJob < ApplicationJob
  queue_as :default

  def perform(webhook_request_id)
    webhook_request = ActionHooks::WebhookRequest.find(webhook_request_id)
    payload = webhook_request.payload

    case payload["type"]
    when "payment_intent.succeeded"
      # handle payment
    end

    webhook_request.processed!
  rescue => e
    webhook_request.failed!
    raise e
  end
end
```

### 3. Custom Controller (Optional)

If your webhook processing requires complex synchronous logic before placing the job into the queue, you can generate a custom controller using the `--controller` flag:

```bash
$ rails generate action_hooks:webhook stripe --controller
```

This generates:

- A job: `app/jobs/stripe_webhook_job.rb` (unless `--skip-job` is provided)
- A controller: `app/controllers/webhooks/stripe_controller.rb`
- A specific route mapping in `config/routes.rb`

Your custom controller will inherit from `ActionHooks::WebhookController`. The parent controller handles persistence, IP checks, and signature verification, while your controller can focus just on the business logic inside the `process_webhook` hook:

```ruby
# app/controllers/webhooks/stripe_controller.rb
class Webhooks::StripeController < ActionHooks::WebhookController
  private

  def webhook_source_name
    :stripe
  end

  def process_webhook(webhook_request)
    # Business logic here.
    # The default behavior inside `process_webhook` is to enqueue the configured background job.
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alec-c4/action_hooks.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
