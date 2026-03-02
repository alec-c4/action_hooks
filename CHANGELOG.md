## [Unreleased]

## [0.2.3] - 2026-03-02

- Fixed `ActionHooks::WebhookRequest` being unavailable in host applications. Moved from `app/models/` to `lib/action_hooks/webhook_request.rb` with explicit require.
- Fixed `ActionHooks::WebhookController` being unavailable for inheritance in host applications. Moved from `app/controllers/` to `lib/action_hooks/webhook_controller.rb` with explicit require.

## [0.2.1] - 2026-03-02

- Fixed migration template to detect primary key type from Rails generators configuration instead of hardcoded PostgreSQL UUID check
- Fixed JSON column type detection to use `t.respond_to?(:jsonb)` instead of checking adapter name directly

## [0.2.0] - 2026-03-02

- Refactored ActionHooks to operate purely as middleware. It now automatically mounts `POST /webhooks/:source` without needing any generated configuration route handling.
- Re-designed `rails g action_hooks:webhook` generator to create only Jobs by default. A new `--controller` flag is available for customized business logic needs.

## [0.1.0] - 2026-03-01

- Initial release
