# Contributing to Admin9 App Starter

This guide applies only to changes proposed for inclusion in the upstream
Admin9 App Starter repository. It does not govern independent forks.

By submitting a contribution for inclusion, you agree that it is licensed
under the [Apache License 2.0](LICENSE), as described in Section 5 of that
license.

## Boundaries

- Core owns tokens, public `App*` components, platform mapping, accessibility,
  and quality behavior. Core changes require focused tests and maintainer
  review.
- Default identity and Brand changes may use the optional App configuration
  tool. Do not change package/application/bundle identifiers incidentally.
- Business code stays in its feature or `lib/ui/shared/` and consumes public
  Core UI through `lib/admin9_ui.dart`.
- Do not add Repository, Service, Domain, or generic Core abstractions without
  a real data source or demonstrated reusable responsibility.
- Do not include customer data, credentials, production logs, proprietary
  assets, or unverifiable backend, user, session, success, or device claims.

Normative words in the [Design System](docs/design-system/README.md) and
[upstream contribution boundaries](docs/design-system/05-upstream-contribution-boundaries.md)
apply only to upstream implementations and contributions. There is no required
contribution flow for forks.

## Workflow

Use Flutter 3.44.1 and Dart 3.12.1. Keep changes scoped, add focused tests for
behavior changes, and use a Conventional Commit subject when a commit is
requested.

Run from the repository root:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test tool
flutter analyze
flutter test
dart run tool/design_system/validate_app_config.dart --fixtures
dart run tool/design_system/verify_public_api_parity.dart --self-test
dart run tool/design_system/verify_import_boundaries.dart --fixtures
dart run tool/design_system/verify_import_boundaries.dart --phase=final
dart run tool/design_system/verify_ui_candidate_boundary.dart --fixtures
dart run tool/design_system/verify_ui_candidate_boundary.dart
dart run tool/design_system/verify_gallery_boundary.dart
node --check docs/design-system/evidence/sources/generate_visual_references.mjs
node --check docs/design-system/evidence/sources/verify_visual_references.mjs
node docs/design-system/evidence/sources/verify_visual_references.mjs docs/design-system/evidence/visual-references
dart run tool/design_system/verify_app_config.dart
dart run tool/design_system/verify_app_config.dart --fixtures
dart run tool/design_system/verify_rule_links.dart
dart run tool/design_system/verify_upstream_ownership.dart
node tool/design_system/verify_documentation.mjs
git diff --check
```

Run `flutter build apk --release` and
`flutter build ios --release --no-codesign` when changing platform files,
dependencies, generation, Core behavior, or release configuration. An unsigned
iOS build does not prove signing, installation, cold launch, or device behavior.
Record unexecuted device and assistive-technology checks as `Unknown`.
