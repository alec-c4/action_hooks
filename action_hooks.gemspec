# frozen_string_literal: true

require_relative "lib/action_hooks/version"

Gem::Specification.new do |spec|
  spec.name = "action_hooks"
  spec.version = ActionHooks::VERSION
  spec.authors = ["Alexey Poimtsev"]
  spec.email = ["alexey.poimtsev@gmail.com"]

  spec.summary = "A Ruby gem for handling incoming webhooks securely."
  spec.description = "Save all incoming webhooks to the database, dispatch them to background workers, and verify request signatures or IPs."
  spec.homepage = "https://github.com/alec-c4/action_hooks"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/alec-c4/action_hooks"
  spec.metadata["changelog_uri"] = "https://github.com/alec-c4/action_hooks/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(__dir__) do
    Dir["{lib,exe}/**/*", "LICENSE.txt", "README.md", "CHANGELOG.md"].reject { |f| File.directory?(f) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 7.0"

  spec.add_development_dependency "bundler", ">= 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "sqlite3"
end
