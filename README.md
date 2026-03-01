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

Configure your webhook sources in the generated initializer (`config/initializers/action_hooks.rb`). Each source represents a third-party service sending webhooks to your application.

```ruby
# config/initializers/action_hooks.rb
ActionHooks.configure do |config|
  config.add_source(:stripe) do |source|
    # The ActiveJob worker class that will process the webhook
    source.worker = "StripeWebhookWorker"
    
    # Lambda to verify the signature of the incoming request
    source.verify_signature = ->(request) do
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      # Example using Stripe's library:
      # Stripe::Webhook::Signature.verify_header(payload, sig_header, ENV['STRIPE_WEBHOOK_SECRET'])
      true
    end
    
    # Optional: Restrict incoming requests to specific IP addresses
    # source.allowed_ips = ["127.0.0.1", "10.0.0.1"]
  end
end
```

### 2. Generating a Webhook Controller

To create an endpoint for a configured source, use the webhook generator. Pass the name of the source as an argument:

```bash
$ rails generate action_hooks:webhook stripe
```

This will:
1. Create a controller at `app/controllers/stripe_webhooks_controller.rb`.
2. Add a route to `config/routes.rb` (e.g., `post "webhooks/stripe", to: "stripe_webhooks#create"`).

The generated controller includes `ActionHooks::WebhookControllerBehavior`, which handles everything from skipping CSRF verification, verifying the IP and signature, saving the request to the database, and enqueueing your worker.

### 3. Processing the Webhook

Create the worker class that you specified in your configuration. The worker will receive the ID of the `ActionHooks::WebhookRequest` record.

```ruby
# app/jobs/stripe_webhook_worker.rb
class StripeWebhookWorker < ApplicationJob
  queue_as :default

  def perform(webhook_request_id)
    webhook_request = ActionHooks::WebhookRequest.find(webhook_request_id)
    
    # Access the parsed JSON payload
    payload = webhook_request.payload
    
    # Process the payload...
    if payload['type'] == 'payment_intent.succeeded'
      # Do something
    end
    
    # Update the state of the webhook request when done
    webhook_request.processed!
  rescue => e
    # Mark as failed if something goes wrong
    webhook_request.failed!
    raise e
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
