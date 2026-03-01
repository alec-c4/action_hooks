# frozen_string_literal: true

require "rails/engine"

module ActionHooks
  class Engine < ::Rails::Engine
    isolate_namespace ActionHooks
  end
end
