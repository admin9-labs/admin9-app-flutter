# Repository Working Agreements

These rules apply to the entire repository and derived projects until a derived
project replaces them with explicit local authority. Detailed rules live in
[Architecture](docs/architecture.md) and [UI](docs/ui.md); the bundled runnable
example and its removal contract live in [Upstream Starter](docs/starter.md).

## Scope And Authority

- Change only the requested scope. Do not add speculative Features,
  dependencies, compatibility APIs, empty layers, placeholder files, or
  generated assets.
- Do not automatically commit, push, publish, tag, release, change signing or
  installation identities, or operate simulators or physical devices.
- Protect legal and security policies, required third-party notices,
  `dev.admin9.starter`, signing configuration, and native capabilities with a
  current consumer.
- When deletion is authorized, delete obsolete code, tests, Goldens, tools, and
  documents only after confirming that they have no runtime, CI, legal, or
  current delivery consumer. Do not create archive, legacy, or deprecated copies.

## Implementation Rules

- Use Flutter 3.47.2, Dart 3.13.2, `forui: ^0.26.0`,
  `flutter_riverpod: ^3.4.2`, `easy_localization: ^3.0.8`, and
  `auto_route: ^11.1.0`. Commit and enforce `pubspec.lock`.
- Keep the top-level source structure at `lib/main.dart`, `lib/app/`,
  `lib/theme/`, `lib/shared/ui/`, and `lib/features/<feature>/`. Do not add
  top-level `lib/examples/` or `lib/widgets/` directories.
- The upstream Admin9 UI Showroom has one owner: `lib/features/examples/`.
  Foundation, Forms, Content, and Feedback belong to that Feature; Settings
  remains an independent real Feature. Multiple official capabilities may share
  one complete Playground; do not create one shallow page per capability. The
  removable upstream Showroom is not a downstream product requirement.
- Forui is the UI foundation. Use an `F*` widget directly when it already meets
  the requirement. An Admin9 `A*` API is allowed only for a stable, observable
  brand visual, interaction, behavior, or API difference; it may wrap, extend,
  or independently implement a Forui gap. Mechanical renaming is prohibited.
- Keep reusable Admin9 UI in a specifically named `shared/ui/<category>/`
  location. It must follow the Forui Theme, typography, icons, variants,
  interaction, focus, accessibility, directionality, and light/dark contracts.
  Do not create a parallel Theme or token system.
- App copy uses semantic tokens from the active Forui Typography. Feature and
  Shared UI must not arbitrarily hardcode font sizes; preserve system text
  scaling and Theme-owned minimum touch sizes. See the
  [Font Size Preference Contract](docs/ui.md#font-size-preference-contract).
- Feature-only UI stays in that Feature. Every shared API or optional layer
  needs a clear responsibility, a real consumer, documentation, and tests. Do
  not create empty directories, vague `utils.dart`, `helpers.dart`, or
  `common.dart` files, placeholder interfaces, or pass-through Use Cases.
- Playground-only preview, configuration, and reset UI stays in Examples. A
  `direct` capability claim requires a realistic scenario,
  configuration-driven preview, observable interaction feedback, reset
  behavior, responsive/accessibility coverage, and focused tests; rendering an
  `F*` type is not coverage.
- Use `snake_case`; route pages use `*_page.dart` and `*Page`; feature Riverpod
  declarations use specific `*_provider.dart` names. Keep one primary public
  responsibility per file.
- Use AutoRoute generated typed routes. AutoRoute imports are limited to
  `app/routing/`, route Pages, and generated files. Shared UI and reusable leaf
  Widgets receive semantic callbacks; Riverpod Notifiers, Models, Preferences,
  Repositories, Services, and Domain code do not depend on AutoRoute, Forui, or
  `BuildContext` as specified in the architecture document.
- Keep the official `FTabs` in the Examples Showroom. Do not create `ATabs`, a
  tabs feasibility experiment, or `shared/ui/navigation/tabs/` in this scope.
- Keep Forui-generated themes under `lib/theme/`. Invoke the locked CLI with
  `dart run forui_cli ...`; generate snippets into their owner with explicit
  `--output`. Do not keep a generic snippets directory, run
  `style create --all` without a demonstrated need, or use `--force` to replace
  hand-edited files without explicit approval.
- Keep generated AutoRoute source committed and never hand-edit it. Add hooks,
  Riverpod generation, model generation, data stores, API clients, native
  bridges, Guards, Observers, or deep links only for an approved consumer.
- Chinese is the initial App locale. Use EasyLocalization for App copy and
  append exactly one `FLocalizations.delegate` after Flutter's localization
  delegates for Forui-owned copy.

## Verification

- Validate only from the current source. Do not inherit pass claims from
  superseded tests, Goldens, screenshots, logs, builds, or device runs.
- Run focused tests plus `flutter pub get --enforce-lockfile`,
  `dart format --output=none --set-exit-if-changed lib test integration_test tool`,
  `flutter analyze`, `flutter test`, Markdown local-link validation, and
  `git diff --check`.
- On a clean checkout, run `dart run build_runner build`, then require both
  `git diff --exit-code` and an empty
  `git status --porcelain --untracked-files=all` result.
- Android/iOS builds, simulator checks, signing, installation, and physical
  device acceptance require explicit scope. Unexecuted evidence stays `Unknown`.
