# frozen_string_literal: true

require "bundler/setup"
require "rails"
require "active_record/railtie"
require "action_controller/railtie"
require "active_job/railtie"
require "rspec/rails"
require "action_hooks"

module DummyApp
  class Application < Rails::Application
    config.load_defaults 7.0
    config.eager_load = false
    config.logger = Logger.new(nil)
    config.secret_key_base = "secret"
  end
end
ENV["DATABASE_URL"] = "sqlite3::memory:"
DummyApp::Application.initialize!

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :webhook_requests, id: :string do |t|
    t.json :payload, default: "{}", null: false
    t.string :source, null: false
    t.integer :state, null: false, default: 0

    t.timestamps
  end
end

require "action_hooks/webhook_request"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
