require "rails/generators"

module ActionHooks
  module Generators
    class WebhookGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)
      desc "Creates a webhook controller for a given source and adds its route."

      def create_controller_file
        template "controller.rb.erb", "app/controllers/#{file_name}_webhooks_controller.rb"
      end

      def add_route
        route %(post "webhooks/#{file_name}", to: "#{file_name}_webhooks#create")
      end
    end
  end
end
