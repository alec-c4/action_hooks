# frozen_string_literal: true

require "rails/generators"

module ActionHooks
  module Generators
    class WebhookGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)
      desc "Creates a webhook job (and optionally a controller) for a given source."

      class_option :controller, type: :boolean, default: false,
        desc: "Also generate a custom controller for business logic"
      class_option :skip_job, type: :boolean, default: false,
        desc: "Skip job generation"

      def create_job_file
        return if options[:skip_job]
        template "job.rb.erb", "app/jobs/#{file_name}_webhook_job.rb"
      end

      def create_controller_file
        return unless options[:controller]
        template "controller.rb.erb", "app/controllers/webhooks/#{file_name}_controller.rb"
      end

      def add_route
        return unless options[:controller]
        route %(post "webhooks/#{file_name}", to: "webhooks/#{file_name}#create")
      end
    end
  end
end
