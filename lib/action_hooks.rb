# frozen_string_literal: true

require_relative "action_hooks/version"
require_relative "action_hooks/configuration"

module ActionHooks
  class Error < StandardError; end
end
require "action_hooks/engine"
require "action_hooks/webhook_controller_behavior"
require "action_hooks/webhook_controller"
