## [Unreleased]

## [0.2.0] - 2026-03-02

- Refactored ActionHooks to operate purely as middleware. It now automatically mounts `POST /webhooks/:source` without needing any generated configuration route handling.
- Re-designed `rails g action_hooks:webhook` generator to create only Jobs by default. A new `--controller` flag is available for customized business logic needs.

## [0.1.0] - 2026-03-01

- Initial release
