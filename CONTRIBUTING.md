# Contributing to Admin9 App Starter

This guide applies to changes proposed for the upstream Android/iOS Starter. By
submitting a contribution, you agree that it is licensed under the
[Apache License 2.0](LICENSE), as described in Section 5 of that license.

Read [Repository Working Agreements](AGENTS.md),
[Application Architecture](docs/architecture.md), [UI System](docs/ui.md), and
the [Admin9 Flutter App Skill](.agents/skills/admin9-flutter-app/SKILL.md) before
starting. Those sources define the current implementation; superseded APIs,
tests, and tools do not.

## Contribution Boundaries

- Keep changes scoped to a real Starter or approved Feature responsibility. Do
  not add empty layers, placeholder interfaces, speculative product behavior,
  or pass-through Use Cases.
- Use Forui widgets directly in presentation. Do not build renamed wrappers or
  a parallel base component library.
- Keep feature state and dependency wiring in feature-owned Riverpod providers.
  Keep Notifiers independent of Forui, AutoRoute, and `BuildContext`; keep
  Models, Preferences, Repositories, Services, and Domain code independent of
  Riverpod as well.
- Use generated typed AutoRoute objects for navigation. Never edit generated
  router source or add a second routing system.
- Use `snake_case`, `*_page.dart`/`*Page`, specific `*_provider.dart` names,
  and one primary public responsibility per file. Avoid vague utility
  collections.
- Protect legal notices, package/application/bundle identifiers, signing
  configuration, and still-used native capabilities.
- Do not include credentials, customer data, production logs, proprietary
  assets, or unverifiable build, simulator, signing, installation, or device
  claims.

## Workflow

Use Flutter 3.47.2 and Dart 3.13.2. Commit dependency and generated route
changes when the contribution requires them, but do not regenerate unrelated
sources. Before opening a change, run:

```bash
flutter pub get --enforce-lockfile
dart run build_runner build
git diff --exit-code
test -z "$(git status --porcelain --untracked-files=all)"
dart format --output=none --set-exit-if-changed lib test integration_test tool
dart run tool/check_markdown_links.dart
flutter analyze
flutter test
git diff --check
```

Run generation drift checks from a clean checkout. Add focused unit or Widget
tests for changed behavior. Android/iOS builds, simulator checks, signing,
installation, and physical-device acceptance are separate scopes; report
anything not actually executed as `Unknown`.

Release tags use bare semantic versions such as `v1.0.0`. Do not add project or
component prefixes to tag names.

Use a Conventional Commit subject only when a commit is explicitly requested.
