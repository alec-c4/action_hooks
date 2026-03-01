# frozen_string_literal: true

require "rails/engine"

module ActionHooks
  class Engine < ::Rails::Engine
    isolate_namespace ActionHooks

    initializer "action_hooks.routes" do |app|
      app.routes.append do
        post "webhooks/:source",
          to: "action_hooks/webhooks#create",
          constraints: {source: /[a-z0-9_]+/}
      end
    end
  end
end
