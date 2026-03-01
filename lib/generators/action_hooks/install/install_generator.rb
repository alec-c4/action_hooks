require "rails/generators"
require "rails/generators/active_record"

module ActionHooks
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      include ::Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      desc "Installs ActionHooks migration and initializer"

      def self.next_migration_number(dirname)
        ::ActiveRecord::Generators::Base.next_migration_number(dirname)
      end

      def create_migration_file
        migration_template "create_webhook_requests.rb.erb", "db/migrate/create_webhook_requests.rb"
      end

      def create_initializer_file
        template "action_hooks.rb", "config/initializers/action_hooks.rb"
      end
    end
  end
end
