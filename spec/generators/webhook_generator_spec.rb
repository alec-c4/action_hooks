# frozen_string_literal: true

require "spec_helper"
require "rails/generators"
require "rails/generators/testing/behavior"
require "rails/generators/testing/assertions"
require "generators/action_hooks/webhook/webhook_generator"

RSpec.describe ActionHooks::Generators::WebhookGenerator, type: :generator do
  include Rails::Generators::Testing::Behavior
  include Rails::Generators::Testing::Assertions
  include FileUtils

  tests described_class
  destination File.expand_path("../../tmp", __dir__)

  before { prepare_destination }

  describe "default (job only)" do
    before { run_generator ["stripe"] }

    it "creates app/jobs/stripe_webhook_job.rb" do
      assert_file "app/jobs/stripe_webhook_job.rb"
    end

    it "generates StripeWebhookJob < ApplicationJob" do
      assert_file "app/jobs/stripe_webhook_job.rb",
        /class StripeWebhookJob < ApplicationJob/
    end

    it "includes perform with webhook_request_id" do
      assert_file "app/jobs/stripe_webhook_job.rb",
        /def perform\(webhook_request_id\)/
    end

    it "does not create a controller" do
      assert_no_file "app/controllers/webhooks/stripe_controller.rb"
    end
  end

  describe "--skip-job flag" do
    before { run_generator ["stripe", "--skip-job"] }

    it "does not create a job" do
      assert_no_file "app/jobs/stripe_webhook_job.rb"
    end
  end

  describe "--controller flag" do
    before { run_generator ["stripe", "--controller"] }

    it "creates the job" do
      assert_file "app/jobs/stripe_webhook_job.rb"
    end

    it "creates app/controllers/webhooks/stripe_controller.rb" do
      assert_file "app/controllers/webhooks/stripe_controller.rb"
    end

    it "generates Webhooks::StripeController < ActionHooks::WebhookController" do
      assert_file "app/controllers/webhooks/stripe_controller.rb",
        /class Webhooks::StripeController < ActionHooks::WebhookController/
    end

    it "includes process_webhook hook" do
      assert_file "app/controllers/webhooks/stripe_controller.rb",
        /def process_webhook\(webhook_request\)/
    end

    it "does not generate base_controller.rb" do
      assert_no_file "app/controllers/webhooks/base_controller.rb"
    end
  end

  describe "--controller --skip-job flags" do
    before { run_generator ["stripe", "--controller", "--skip-job"] }

    it "creates controller but not job" do
      assert_file "app/controllers/webhooks/stripe_controller.rb"
      assert_no_file "app/jobs/stripe_webhook_job.rb"
    end
  end
end
