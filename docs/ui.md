# UI System

## Forui Is The UI Foundation

Forui is the application's selected UI design system and base component source.
It is not a candidate under evaluation. Project verification confirms that the
application integrates Forui correctly; it does not compare Forui with a custom
design language or reopen the selection decision.

Forui remains the visual and semantic foundation even when the Starter exposes
an Admin9-owned brand API. Admin9 UI must not create a parallel Theme, token,
typography, icon, interaction, focus, or accessibility system.

See [Application Architecture](architecture.md) for ownership, dependency, and
navigation rules. The upstream Admin9 UI Showroom and Examples Feature are
described separately in [Upstream Starter](starter.md); derived projects may
replace that example without redefining Forui's role.

## UI Ownership Model

Choose the narrowest owner that expresses an observable requirement:

1. Use a Forui `F*` widget directly when its visual, interaction, behavior, and
   public API already satisfy the requirement.
2. Create an Admin9 `A*` API only for a stable brand visual, interaction,
   behavior, or public API difference. It may wrap or extend an `F*` widget, or
   independently implement a confirmed Forui capability gap. Its public API
   must not reveal which internal strategy it uses.
3. Keep a Widget inside its Feature when the responsibility is specific to that
   Feature. Ordinary business UI usually stays with its first Feature until a
   second real Feature needs the same responsibility.

Mechanical `F*` renaming is prohibited: an `A*` API needs a documented,
testable difference, not merely a new class name. Every `A*` implementation must
continue to use the active Forui Theme, typography, icons, variants, tappable and
focused-outline behavior, accessibility semantics, directionality, and
light/dark states. Flutter layout and platform primitives remain available where
Forui does not own the capability.

Reusable `A*` APIs live in a responsibility-specific `shared/ui/<category>/`
location, have a real consumer, documentation, and tests, and receive semantic
callbacks rather than importing AutoRoute. A Theme-backed default is a typed
extension of the existing Forui Theme or widget-style contract, not an `ATheme`
or parallel token source. Do not create an empty style extension before a real
Theme contract exists.

The current Examples Showroom demonstrates the official `FTabs` directly. This
scope does not create `ATabs`, a tabs feasibility experiment, or a shared tabs
directory. The approved Admin9 brand component in this iteration is AGrid; its
current implementation and coverage belong in [Upstream Starter](starter.md).

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

### Theme Workbench

The Showroom Theme Playground is the control surface for the App's global Theme,
not a swatch gallery. It provides at least three visually distinct,
contrast-checked presets, each with complete light and dark Forui themes, plus
system/light/dark mode selection and five global font-size preferences. Font
sizes scale the complete Forui typography before widget styles and Material
mapping are built. Any radius, control-scale, or other global option must be
supported coherently by the real Forui Theme/style contract; do not expose a
partial setting or arbitrary color picker.

Changes apply immediately across the App through one state source and persist
through the Settings persistence boundary. The Playground previews buttons,
input, card, tile, status color, dialog, and AGrid together, provides a default
reset, and shows read or write failures visibly. It does not create `ATheme` or a
second token system.

### Font Size Preference Contract

This section is the complete authority for the font-size preference. The global
preference controls the App's reading scale, not per-page typography.
`AppThemeCatalog` resolves the selected preference,
`buildForuiTheme` scales the complete active `FTypography`, and the scaled
typography is then used to build Forui Widget Styles and the approximate
Material Theme. Global scaling changes the reading size without changing the
visual relationship between semantic levels.

- Pages and components select semantic tokens such as `body.sm`, `body.md`, or
  `display.lg`. They do not read the font-size preference or introduce local
  scale factors. The App Theme composition and the Settings and Theme Workbench
  control surfaces may read or write the preference; control surfaces must not
  use it to derive local text styles.
- Readable App copy follows the active typography. This includes page titles,
  body copy, buttons, menus, forms, lists, dialogs, Toasts, and equivalent
  labels or messages.
- Logo images, icons, decorative symbols, purely visual graphics, and non-text
  geometry are outside the font-size preference.
- `lib/features/` and `lib/shared/ui/` must not directly hardcode `fontSize`.
  Theme token definitions and special non-copy elements with a stable visual
  reason are allowed. Every special exception needs a specific owner, a stated
  reason, and responsive and accessibility tests; it must not create a second
  typography system.
- The system `TextScaler` or Dynamic Type remains additive. The App must not
  replace, clamp, cap, or otherwise suppress the system accessibility scale.
- Smaller App text must not reduce the Theme-owned minimum touch area. Larger
  text is handled through wrapping, scrolling, and responsive layout rather
  than compressed or clipped text.

## Shared UI APIs And Patterns

The Starter may provide `shared/ui/<category>/` before a second Feature exists
so adopters can see the recommended extension path immediately. It may contain
a stable Admin9 brand UI API or App-wide pattern such as a branded layout,
specifically named empty state, error state, loading state, or responsive page
body. Each early API or pattern must have a current runnable consumer and tests
and documentation.

Shared UI follows the ownership model above; it does not replace Forui as the UI
foundation. Mechanical primitive wrappers, empty architecture, placeholder
interfaces, `common_card.dart`, and generic utility collections are prohibited.
Existing root-level shared UI files are not moved merely to normalize the tree;
new code uses a clear category and responsibility.

## Showroom Playground Contract

Examples is an Admin9 UI Showroom, not a static component gallery or a test
fixture rendered as an App. Each direct Playground provides one coherent mobile
scenario with all of the following:

- a configuration area whose controls correspond to real Forui or approved
  Admin9 API parameters;
- a live preview that changes from those controls and exposes applicable
  enabled, selected, loading, error, confirmation, and content states;
- executable interaction with visible, accessible feedback;
- a reset command that restores the documented defaults; and
- Chinese long-copy, narrow-screen, large-text, light/dark, directionality,
  focus, semantics, and no-overflow evidence appropriate to that capability.

Do not invent a universal `size`, color, variant, or state option when the
component API does not provide it. Theme, Delta, Controller, composition, and
Admin9 API behavior are configured only through their real public contracts;
private Forui APIs and a generic dynamic component renderer are prohibited.

Several official capabilities may share one Playground when they form a
complete scenario. Coverage is retained by recording each capability's axes and
focused evidence in the version-bound ledger, not by creating a page for every
type. Merely rendering an `F*` widget is not direct coverage.

Preview frames, configuration sections, interaction feedback, and reset
controls are Examples-owned UI under
`features/examples/presentation/widgets/`. They do not enter `shared/ui/` unless
they independently become a stable App-wide or Admin9 brand responsibility with
a non-Showroom consumer.

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
An Admin9 `A*` API expresses a specific brand difference within that foundation;
it is not permission to build a second base component or token system. Brand
changes belong in the Forui Theme or a typed Forui Theme/widget-style extension
and require confirmed inputs. A lack of design input is not permission to create
a new visual language.

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
| Showroom closure | configuration changes the preview, interactions produce visible feedback, and reset restores documented defaults |
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

Automated geometry and behavior do not prove visual quality. Save current-source
screenshots for the Theme and AGrid Playgrounds at representative light/dark and
narrow-screen states, bind them to the tested source, and leave visual hierarchy,
spacing, balance, and comfort for explicit human review. Superseded screenshots
never satisfy this review.

Cold-start deep-link reconstruction and in-process Tab stack retention do not
prove process state restoration. Process restoration enters this matrix only
after its separate scope and persistence contract are approved.
