# UI System

## Forui Is The UI Foundation

Forui is the application's selected UI design system and base component source.
It is not a candidate under evaluation. Project verification confirms that the
application integrates Forui correctly; it does not compare Forui with a custom
design language or reopen the selection decision.

Feature presentation uses Forui `F*` widgets directly. Do not create an `App*`
equivalent for each Forui primitive. Add a project-owned Widget only when there
is demonstrated repetition, stable business meaning, a confirmed Forui
capability gap, or a stable Starter-level App pattern backed by a current,
runnable example and tests. Ordinary business UI stays with its first Feature
until a second Feature needs the same responsibility.

See [Application Architecture](architecture.md) for ownership, dependency, and
navigation rules. The upstream component catalog and example Feature are
described separately in [Upstream Starter](starter.md); derived projects may
replace that example without redefining Forui's role.

## Theme And CLI Ownership

Use the Forui CLI default theme structure under `lib/theme/`. Keep the generated
configuration explicit:

```yaml
cli:
  snippet-output: lib
  style-output: lib/theme/styles
  theme-output: lib/theme/theme.dart
  fonts-output: assets/fonts
```

Use Forui's router initialization template for the AutoRoute App host:

```shell
dart run forui_cli init --template=router
```

Run initialization only after conflicting generated targets have been reviewed
and intentionally removed. Do not use `--force` as an initialization shortcut.
Treat generated theme files as project source after generation; review every
future regeneration before it replaces hand-edited theme code.

The generated `MaterialApp.router` entry is an official host skeleton, not a
finished route tree. Replace its router TODO with the App-owned AutoRoute
configuration described in [Application Architecture](architecture.md#routing-architecture).

Generate only a style that a current screen needs:

```shell
dart run forui_cli style create <style>
```

Do not run `style create --all` without a demonstrated requirement. Generate a
snippet directly into its owning feature or specifically justified shared UI
location:

```shell
dart run forui_cli snippet create <snippet> --output <owning_path>
```

Generated snippets are ordinary project source. Do not keep a permanent generic
`snippets/` repository. Put a snippet in its owning Feature, or in `shared/ui/`
when it implements an approved Starter pattern with real use, a runnable example,
documentation, and tests. Give every generated source file a specific name.

## Shared UI Patterns

The Starter may provide `shared/ui/` before a second Feature exists so adopters
can see the recommended extension path immediately. It is reserved for stable
App-wide page patterns such as a specifically named empty state, error state,
loading state, or responsive page body. Each early pattern must be used by a
current runnable example and covered by tests and documentation.

`shared/ui/` composes Forui; it does not replace it. Continue using `FButton`,
`FTextField`, `FDialog`, and other Forui primitives directly. Renamed primitive
wrappers, empty architecture, placeholder interfaces, `common_card.dart`, and
generic utility collections are prohibited.

## Presentation State

Feature Pages and Widgets render Forui components from feature-owned Riverpod
state. Use `ref.watch` to rebuild from state and `ref.read` for user commands;
keep the Provider or Notifier independent of Forui, routing, and `BuildContext`.

Asynchronous providers expose loading, data, and error states that the Page maps
to the approved Forui loading, content, empty, or error presentation. Provider
tests override Repository or Service dependencies; Widget tests verify the
resulting Forui UI and interactions.

Do not turn every local interaction into a Provider. Text editing, focus,
scrolling, animation, and temporary Widget-only state remain with their owning
Widget. Hooks and Riverpod code generation are not part of the initial baseline.

## Navigation Presentation

AutoRoute owns route matching, typed arguments, nested Tab Routers, Guards, and
deep-link route construction. AutoRoute and Flutter own Route transitions and
navigation-stack behavior. Forui owns the visible navigation controls, including
headers, bottom navigation, and tabs; it does not own the Route stack.

Typed route generation and adaptive Route behavior are baseline. Create a Tab
Router, Guard, Observer, or deep-link mapping only when an approved consumer or a
runnable, documented, and tested Starter example needs it.

Route Pages use `@RoutePage` and may navigate with generated typed Route objects.
Reusable leaf Widgets receive semantic callbacks rather than importing the App
router. Navigation state must not be stored in Riverpod merely to mirror the
AutoRoute stack.

## Brand And Platform Boundaries

Use Forui's existing design language, Theme, components, and interaction states.
Do not invent a parallel token or component system. Brand changes belong in the
Forui Theme and require confirmed product inputs; a lack of design input is not
permission to create a new visual language.

Forui owns visible product UI. Flutter and Android/iOS own platform behavior and
native capabilities. Use system keyboards, permissions, sharing, text selection,
safe areas, and native pickers rather than rebuilding them as branded controls.
An ordinary business page has one Forui implementation, not separate Android and
iOS versions.

Use an existing maintained Flutter plugin for system capabilities before adding
project-owned Kotlin or Swift. When no suitable plugin can expose an approved
native capability, follow the Pigeon boundary in
[Application Architecture](architecture.md#native-interop-with-pigeon); Pigeon
generates the typed bridge but does not implement the native behavior or visible
Forui UI.

Installation identity is not a visual-theme concern. The upstream Android/iOS
identifier and its new-App installation behavior are defined in
[Upstream Starter](starter.md#installation-identity); UI or brand customization
must not silently change that identity or signing configuration.

## Language And Localization

Use `easy_localization: ^3.0.8` for App-owned product copy. Chinese is the initial
supported and fallback locale. Keep translation assets under one documented App
path and obtain `locale`, `supportedLocales`, and the App localization delegates
from the root `EasyLocalization` scope. Configure `saveLocale: false` while
Chinese is the only supported locale; persist locale selection only after a real
language switcher is approved.

Forui separately owns localization for its component labels and messages.
Flutter 3.47's `material_ui.MaterialApp` also requires the external
`material_ui`/`cupertino_ui` delegates, which EasyLocalization 3.0.8 does not
replace. The root App therefore combines `context.localizationDelegates`,
`GlobalMaterialLocalizations.delegates`, and exactly one
`FLocalizations.delegate`, in that order. Do not also merge
`FLocalizations.localizationsDelegates`. Use the App's approved supported-locale
list rather than `FLocalizations.supportedLocales`, which represents every
locale Forui can technically render.

EasyLocalization does not translate Forui internals, and `FLocalizations` does
not translate App copy. Do not create duplicate keys for Forui-owned messages.
Do not add another locale until its translations, Android/iOS declarations,
large-text layout, directionality, and UI acceptance are complete. Localization
key/code generation is not part of the initial baseline.

## New-Source Acceptance

All UI acceptance is rerun against the new source. Superseded Goldens, screenshots,
logs, builds, simulator runs, and device observations do not provide a passing
result for the new application. An approved runnable example Feature may drive
this acceptance matrix without turning its scenario into an approved product
requirement.

| Area | Required coverage |
| --- | --- |
| Theme and language | Chinese App translations, Forui component translations, missing-key behavior, font fallback, light and dark themes, readable contrast, and states |
| Responsive layout | narrow supported screens, large system text, long Chinese labels, safe content growth, and no overflow |
| Navigation | typed AutoRoute generation, adaptive Route behavior, basic stack/back behavior, Forui navigation controls, and each actually implemented Tab stack, Guard, Observer, or deep-link reconstruction path |
| Forms | labels, validation, focus order, disabled/loading/error states, password/input behavior, and system keyboard interaction |
| Overlays | representative Forui Dialog, Sheet, and Toast integration, including dismissal, focus restoration, and safe areas |
| Android | current Android rendering, system back, keyboard/IME, text selection, permissions or pickers used by the product, and insets |
| iOS | current iOS rendering, edge-back behavior where navigation exists, keyboard, text selection, safe areas, and native capability handoff |

Automated tests prove deterministic application behavior. Simulator or physical
device checks prove only the exact source, build, platform, and interaction that
were actually exercised. Any unexecuted platform, gesture, keyboard, signing,
installation, or device item remains `Unknown` until explicitly authorized and
performed on the new implementation.

Cold-start deep-link reconstruction and in-process Tab stack retention do not
prove process state restoration. Process restoration enters this matrix only
after its separate scope and persistence contract are approved.
