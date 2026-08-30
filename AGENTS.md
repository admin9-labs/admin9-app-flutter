# Repository Working Agreements

These rules apply to the entire repository and derived projects until a derived
project replaces them with explicit local authority. Detailed architecture and
UI rules live in [Architecture](docs/architecture.md) and [UI](docs/ui.md). The
bundled upstream example is described separately in
[Upstream Starter](docs/starter.md). These repository-local documents remain
authoritative.

## Scope And Authority

- Change only the scope requested by the user. Do not add speculative product
  features, dependencies, compatibility APIs, empty layers, or generated assets.
- Do not automatically commit, push, publish, create tags or releases, change
  signing or installation identities, or operate simulators or physical devices.
- Protect `LICENSE`, security and trademark policies, required third-party
  notices, Android application IDs, iOS bundle IDs, signing configuration, and
  native capabilities that still have a current consumer.
- Old code, tests, Goldens, tools, and documents with no current runtime, CI,
  legal, or delivery consumer are deleted directly when deletion is authorized.
  Do not create archive, legacy, or deprecated copies.

## Implementation Rules

- The target baseline is Flutter 3.47.2, Dart 3.13.2, and
  `forui: ^0.26.0`, with `flutter_riverpod: ^3.4.2` as the default state and
  dependency-wiring library, `easy_localization: ^3.0.8` for App-owned copy, and
  `auto_route: ^11.1.0` for typed routing. Commit `pubspec.lock` for the
  application and enforce it in CI.
- Forui is the selected UI design system and base component source. Feature
  presentation uses Forui widgets directly; do not create parallel `App*`
  wrappers for Forui primitives.
- This repository is a Starter. It may establish `shared/ui/` and one approved
  example Feature early when they demonstrate a stable App-wide pattern through
  real, runnable code, a current consumer, documentation, and tests. Ordinary
  business code usually moves to shared ownership after a second real consumer.
- Use `snake_case` for directories and files. Pages use `*_page.dart` and
  `*Page`; feature Riverpod declarations use specific `*_provider.dart` names.
  Do not create vague files such as `utils.dart`, `helpers.dart`, or
  `common.dart`. Keep one primary public responsibility per file.
- Every created layer needs a clear responsibility, a real consumer, and tests.
  Do not pre-create empty directories, placeholder interfaces, or pass-through
  Use Cases merely to complete a folder tree. An example Feature and its
  dependencies must still be approved in the Starter's feature list.
- Use Forui's router initialization template and AutoRoute from the first App
  baseline. Route pages use `@RoutePage`, and App navigation uses generated typed
  Route objects. Add nested Tab Routers, Guards, Observers, or deep-link paths
  only for an approved consumer or a runnable, tested Starter example. Treat
  generated router files as committed tool output and never hand-edit them. Do
  not add `go_router`, `go_router_builder`, or a second routing system.
- Keep feature presentation state and dependency wiring in feature-owned
  `providers/`. Do not collect unrelated providers in one root directory or
  create a Provider for trivial Widget-local state.
- Riverpod Notifiers must not depend on Forui, AutoRoute, or `BuildContext`.
  Models, Preferences, Repositories, Services, and Domain code must additionally
  remain independent of Riverpod and AutoRoute. AutoRoute imports are limited to
  `app/routing/`, route Pages, and generated router files; reusable leaf Widgets
  use semantic callbacks.
- AutoRoute route generation is part of the baseline. Add hooks, Riverpod code
  generation, or other generators only after a demonstrated requirement and
  explicit approval. Use `auto_route_generator: ^10.6.0` and
  `build_runner: ^2.16.0`, and keep their resolved transitive dependencies locked.
  During replacement, do not carry forward the old direct `analyzer: 10.1.0`;
  declare Analyzer directly only when current source imports its API.
- Keep `forui_cli: ^0.26.0` as a locked development dependency and invoke it
  with `dart run forui_cli ...`. The `dart run forui ...` installation wrapper
  is not the reproducible project CLI entry.
- Generate an API client only when an approved Feature needs a backend API and
  an authoritative OpenAPI contract exists for that API. Keep generated code
  behind Repositories and do not hand-edit it. Add secure storage only for real
  secrets, and add offline storage, background work, realtime transport, or
  model generation only when the approved Feature needs that capability.
- The candidate technology map in `docs/architecture.md` records preferred
  options, not implementation authority. A candidate still requires an approved
  Feature, its documented trigger, and a fresh review of version compatibility,
  maintenance, licensing, and platform behavior before adoption.
- Use an existing maintained Flutter plugin for native capabilities first. Use
  Pigeon only when an approved capability requires project-owned Kotlin/Swift
  interop; generate both sides with one pinned Pigeon version and keep the bridge
  internal.
- Chinese is the initial supported product locale. Use `easy_localization` for
  App-owned copy. Use EasyLocalization's delegates and append exactly one
  `FLocalizations.delegate` for Forui component copy; do not merge the complete
  `FLocalizations.localizationsDelegates` list. Add another locale only with
  approved, complete translations and acceptance coverage.
- Keep Forui-generated themes under `lib/theme/`. Generate snippets directly
  into their owning feature with an explicit output path. Do not keep a generic
  snippets directory, run `style create --all` without a demonstrated need, or
  use `--force` to overwrite hand-edited files without explicit approval.
- The upstream may bundle documented example Features, routes, and shared UI.
  Derived projects may remove or replace them, but must update their local
  Starter reference document, tests, localization, and acceptance claims. Upstream
  examples are not downstream product requirements.

## Verification

- Validate the new implementation from its own source. Never inherit pass
  claims from superseded Goldens, screenshots, logs, builds, or device runs.
- Once the new application is initialized, the default source gates are
  `flutter pub get --enforce-lockfile`,
  `dart format --output=none --set-exit-if-changed lib test`,
  `flutter analyze`, `flutter test`, and `git diff --check`, plus focused tests
  for changed behavior.
- On a clean CI checkout, run `dart run build_runner build`, then
  `git diff --exit-code` and
  `test -z "$(git status --porcelain --untracked-files=all)"` to detect stale,
  changed, or newly untracked generated router output.
- Android/iOS builds, simulator checks, signing, installation, and device
  acceptance require explicit scope.
