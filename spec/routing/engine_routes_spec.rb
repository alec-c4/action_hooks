# frozen_string_literal: true

require "spec_helper"

RSpec.describe "ActionHooks engine routes", type: :routing do
  it "routes POST /webhooks/:source to action_hooks/webhooks#create" do
    expect(post: "/webhooks/stripe").to route_to(
      controller: "action_hooks/webhooks",
      action: "create",
      source: "stripe"
    )
  end

  it "does not route sources with invalid characters" do
    expect(post: "/webhooks/stripe/extra").not_to be_routable
  end
end
