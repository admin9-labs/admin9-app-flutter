# Admin9 App Starter

Admin9 App Starter is an Android/iOS Flutter skeleton built on Forui. It is a
runnable reference for application structure, mobile UI capabilities, typed
routing, localized copy, and a small persisted-settings feature. It is not a
finished product, backend, or compatibility layer for superseded APIs.

## Current Release

The current release is
[Admin9 App Starter v1.1.0](https://github.com/admin9-labs/admin9-app-flutter/releases/tag/v1.1.0).
The Git history contains the superseded `App*` architecture as historical
context, not a compatibility contract for this Forui Starter. The App Starter
release is source-only. Its GitHub CI results verify the release source; no App
binary, screenshot, or UI evidence ZIP is distributed with the release.

## Included

- Flutter 3.47.2 and Dart 3.13.2.
- Forui 0.26.0 as the visible UI design system and base component source.
- Five persistent capability destinations: Foundation, Forms, Content,
  Feedback, and Settings.
- AutoRoute typed routes with independent nested Tab stacks.
- Riverpod presentation state and dependency wiring.
- Simplified Chinese App copy through EasyLocalization, plus Forui's own
  localization delegate.
- A Settings example that persists brightness, Theme preset, five font-size
  preferences, and radius through a Repository and SharedPreferences Service.
- Reusable App-level page patterns under `lib/shared/ui/`, each backed by real
  consumers and tests.
- `dev.admin9.starter` as the Android application ID/namespace and iOS Runner
  bundle identifier.

The catalog covers Forui 0.26.0 capabilities relevant to Android and iOS. It
does not claim desktop or complete package coverage. Pointer-first or
desktop-oriented examples such as Sidebar, Breadcrumb, Pagination, Resizable,
and Context Menu are intentionally excluded.

## Structure

```text
lib/
|-- main.dart                  # starts the application
|-- app/                       # bootstrap, App host, and typed routing
|-- theme/                     # Forui CLI theme output
|-- shared/ui/                 # tested App-wide page patterns
`-- features/                  # capability catalogs and Settings example
```

Feature Pages use Forui `F*` widgets directly. The Starter does not rename
Forui primitives behind parallel `App*` wrappers. Services, Repositories,
preferences, and models stay independent of Forui, AutoRoute, Riverpod, and
`BuildContext`; feature-owned providers connect those layers to presentation.

See [Application Architecture](docs/architecture.md) and
[UI System](docs/ui.md) for the authoritative ownership, routing, generation,
and generic UI rules. See [Upstream Starter](docs/starter.md) for this
repository's five catalog destinations, exclusions, and acceptance matrix.

## Getting Started

Install Flutter 3.47.2, then resolve the committed dependency graph and run the
application:

```bash
flutter pub get --enforce-lockfile
flutter run
```

The source checks used by CI are:

```bash
flutter pub get --enforce-lockfile
git diff --check
dart run build_runner build
git diff --exit-code
test -z "$(git status --porcelain --untracked-files=all)"
dart format --output=none --set-exit-if-changed lib test integration_test tool
dart run tool/check_markdown_links.dart
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
```

The generation checks must run from a clean checkout. Generated AutoRoute
source is committed and must not be edited by hand.

## Using The Starter

Add Features only when they have an approved consumer. A Feature may add its
own presentation, data, or domain paths when each layer has a concrete
responsibility and tests; do not create empty architecture for symmetry.

Forui themes remain under `lib/theme/`. Generate snippets with an explicit
output path into the owning Feature or a justified shared pattern. Do not keep
a generic snippets directory, run `style create --all` without a demonstrated
need, or use `--force` to overwrite hand-edited files.

Android application IDs, iOS bundle IDs, signing configuration, and native
capabilities are installation identity, not casual customization points. Change
them only as an explicitly reviewed task. The bundled Starter uses
`dev.admin9.starter`; replacing an older identifier installs a separate App and
does not overwrite or migrate that App's data.

## Contributing And License

Read [Repository Working Agreements](AGENTS.md),
[Contributing](CONTRIBUTING.md), and the
[Admin9 Flutter App Skill](.agents/skills/admin9-flutter-app/SKILL.md) before
changing the Starter.

The project is licensed under the [Apache License 2.0](LICENSE). The license
does not grant permission to imply Admin9 endorsement or unrestricted use of
Admin9 trademarks; see [Trademark Notice](TRADEMARKS.md). Dependencies, fonts,
images, and other third-party materials remain subject to their own notices.
