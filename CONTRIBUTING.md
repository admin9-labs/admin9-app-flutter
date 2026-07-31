# Contributing to Admin9 App Foundation

Admin9 App Foundation accepts focused contributions that preserve its Android/iOS
scope and the separation between Core, Brand, Business, and the App Host.

By submitting a contribution for inclusion, you agree that it is licensed under
the [Apache License 2.0](LICENSE), as described in Section 5 of that license.

## Boundaries

- Core owns tokens, public `App*` components, platform mapping, accessibility,
  and quality contracts. Core changes require machine evidence and maintainer
  review.
- Brand changes go through `admin9-foundation.yaml` and the generator. Do not
  hand-edit generated Dart or native identity assets.
- Business code stays in its feature or `lib/ui/shared/`. It consumes Core UI
  only through `lib/admin9_ui.dart`, with read-only access to
  `app_identity.dart` and `app_route_names.dart` where allowed.
- Do not add Repository, Service, Domain, or generic Core abstractions without
  a real data source or demonstrated reusable rule.
- Do not include customer data, credentials, production logs, proprietary
  assets, or unverifiable backend, user, session, success, or device claims.

The normative rules live in the [Design System](docs/design-system/README.md)
and [derived-project contract](docs/design-system/05-derived-project-contract.md).

## Workflow

Use Flutter 3.44.1 and Dart 3.12.1. Keep changes scoped, add focused tests for
behavior changes, and use a Conventional Commit subject.

Run from the repository root:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test tool
flutter analyze
flutter test
dart run tool/design_system/validate_foundation_manifest.dart --fixtures
dart run tool/design_system/verify_public_api_parity.dart --self-test
dart run tool/design_system/verify_import_boundaries.dart --fixtures
dart run tool/design_system/verify_import_boundaries.dart --phase=final
dart run tool/design_system/verify_gallery_boundary.dart
dart run tool/design_system/verify_brand_contract.dart
dart run tool/design_system/verify_brand_contract.dart --fixtures
dart run tool/design_system/verify_rule_links.dart
node tool/design_system/verify_documentation.mjs
git diff --check
```

Run `flutter build apk --release` and
`flutter build ios --release --no-codesign` when changing platform files,
dependencies, generation, Core behavior, or release configuration. An unsigned
iOS build does not prove signing, installation, cold launch, or device behavior.
Record unexecuted device and assistive-technology checks as `Unknown`.
