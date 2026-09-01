# Upstream Starter Reference

## Authority And Derivation

This document defines the Admin9 UI Showroom bundled with the upstream Flutter
Starter. The Showroom is a usable Playground for finding UI capabilities,
configuring realistic mobile scenarios, observing interaction feedback,
inspecting and copying matching Dart usage, and resetting state. It is not a
downstream product contract. A derived project may remove the Examples Feature,
but must update its routes, tests, translations, and local acceptance claims
together.

The reference App targets Android and iOS. Its five persistent destinations are
Foundation, Forms, Content, Feedback, and Settings. The first four are owned by
one removable `lib/features/examples/` feature. Settings is an independent real
feature that demonstrates persisted brightness, complete Theme preset, five
[font-size preferences](ui.md#font-size-preference-contract), and radius
preference through Riverpod, a Repository, and a SharedPreferences Service.

Examples has one App Router integration point in
`lib/app/routing/examples_routes.dart`. It contributes four sibling Tab branches
so the five visible destinations retain independent in-process stacks. It does
not add an extra runtime shell.

| Destination | Root path | Owner | Runtime responsibility |
| --- | --- | --- | --- |
| Foundation | `/foundation` | Examples | Theme, icon, App shell, interaction, and AGrid Playgrounds |
| Forms | `/forms` | Examples | Action, input, selection, value, and scheduling Playgrounds |
| Content | `/content` | Examples | Overview, calendar, and list Playgrounds |
| Feedback | `/feedback` | Examples | Status, confirmation, and contextual-feedback Playgrounds |
| Settings | `/settings` | Settings | Persisted brightness, Theme preset, font size, and radius preference |

## Installation Identity

The upstream Starter uses `dev.admin9.starter` as its Android namespace and
application ID and as the iOS Runner bundle identifier. The iOS test bundle is
`dev.admin9.starter.RunnerTests`. The Apple development team, Automatic Signing,
certificate selection, and all other signing settings remain protected and
independent of this identity.

## Admin9 UI Extensions

`AGrid` is a formal Admin9 brand UI API. Its production source remains under
`lib/shared/ui/layout/grid/` when Examples is removed. The runnable grid page is
only a consumer and demonstration of that shared API. Its `columns` value is a
maximum: narrow constraints reduce the effective column count and cap the
effective aspect ratio so every cell preserves the Theme-owned minimum touch
size. Its `children` contract is `List<AGridItem>` so every accepted child
provides the content metadata needed for responsive height calculation.

The Grid Playground demonstrates three real scenarios: quick actions,
image/title/description content entry, and status panels with counts, badges,
dots, or selection. It configures columns, horizontal and vertical gaps, aspect
ratio, padding, layout direction, visual kind, badge, enabled, and selected
states through AGrid's real public API. It must preserve visual hierarchy,
pressed/selected/disabled/focused distinction, touch geometry, 320/390 widths,
large text, RTL, and light/dark behavior without adding Showroom-only parameters
to the production API. `AGridStyle.visualDecoration` and `visualPadding` define
the Theme-owned visual well without creating a parallel token system. At narrow
widths or large text scales, AGrid reduces effective columns, constrains aspect
ratio, compacts the visual well, and falls back from horizontal item layout when
needed to preserve content and touch geometry. Fresh screenshots are evidence
for human visual review, not an automated claim that the result is attractive.

| API | Production source | Example route | Automated evidence |
| --- | --- | --- | --- |
| AGrid | `lib/shared/ui/layout/grid/` | `/foundation/layout/grid` | `test/shared/ui/layout/grid/a_grid_test.dart`, `test/shared/ui/layout/grid/grid_page_test.dart`, and `test/app/theme_resolution_test.dart` |

The Starter does not define `ATabs`. The Tabs Playground uses Forui `FTabs`
directly. No `shared/ui/navigation/tabs/` directory, compatibility wrapper, or
experimental Tabs API belongs to the current implementation.

## Showroom Coverage Contract

The ledger is bound to the checked-in Forui 0.26.0 documentation snapshot. It
contains 4 Concepts, 7 Guides, 4 Reference entries, and 57 Widgets: 72 official
capabilities in total. Several capabilities may map to the same Playground;
page count is not a coverage metric.

`direct` requires a complete mobile scenario, configuration controls backed by
real public API parameters, a configuration-driven preview, executable
interaction with visible feedback, synchronized Dart usage or parameter summary,
copy feedback, reset behavior, Chinese copy, and focused responsive and
accessibility evidence. `indirect` requires a real higher-level consumer and
focused test. `documented` is a non-runtime source or command contract.
`excluded` records why the mobile Starter deliberately omits it.

The presence of an `F*` type in source is not coverage. Each direct Playground must
exercise the axes named below. A Forui version or snapshot hash change
invalidates this ledger and requires a full review.

### Current Playground Registry

The current implementation has 4 group roots and 17 complete Playgrounds. The
registry is the authoritative join between a Playground ID, source Page, typed
route, translation namespace, focused behavior test, and official capability
mapping. Multiple official capabilities intentionally share one complete page.

| Playground ID | Page source | Typed route | Translation prefix | Focused test | Capability mapping |
| --- | --- | --- | --- | --- | --- |
| `foundation.theme` | `concepts/themes/themes_page.dart` | `/foundation/concepts/themes` | `examples.foundation.concepts.themes` | `test/features/settings/theme_workbench_test.dart` | C01, G01, G03 |
| `foundation.icons` | `reference/icons/icons_page.dart` | `/foundation/reference/icons` | `examples.foundation.playgrounds.icons` | `test/features/examples/foundation_playgrounds_test.dart` | G04, R02 |
| `foundation.app_shell` | `foundation/playgrounds/app_shell_playground_page.dart` | `/foundation/playground/app-shell` | `examples.foundation.playgrounds.app_shell` | `test/features/examples/foundation_playgrounds_test.dart` | C03, C04, WL01, WL03, WN01, WN03 |
| `foundation.interaction` | `foundation/playgrounds/interaction_playground_page.dart` | `/foundation/playground/interaction` | `examples.foundation.playgrounds.interaction` | `test/features/examples/foundation_playgrounds_test.dart` | C02, WN06, WFD01, WFD02, WFD06 |
| `foundation.grid` | `layout/grid/grid_page.dart` | `/foundation/layout/grid` | `examples.foundation.layout.grid.playground` | `test/shared/ui/layout/grid/grid_page_test.dart` | Admin9 AGrid extension |
| `forms.buttons` | `form/buttons/buttons_playground_page.dart` | `/forms/playground/buttons` | `examples.forms.playgrounds.buttons` | `test/features/examples/forms_playgrounds_test.dart` | WF02 |
| `forms.text_input` | `form/text_input/text_input_playground_page.dart` | `/forms/playground/text-input` | `examples.forms.playgrounds.text_input` | `test/features/examples/forms_playgrounds_test.dart` | WF01, WF06, WF08, WF15, WF16 |
| `forms.selection_controls` | `form/selection_controls/selection_controls_playground_page.dart` | `/forms/playground/selection-controls` | `examples.forms.playgrounds.selection_controls` | `test/features/examples/forms_playgrounds_test.dart` | WF03, WF10, WF11, WF14 |
| `forms.selects` | `form/selects/selects_playground_page.dart` | `/forms/playground/selects` | `examples.forms.playgrounds.selects` | `test/features/examples/forms_playgrounds_test.dart` | WF07, WF12 |
| `forms.value_controls` | `form/value_controls/value_controls_playground_page.dart` | `/forms/playground/value-controls` | `examples.forms.playgrounds.value_controls` | `test/features/examples/forms_playgrounds_test.dart` | WF09, WF13 |
| `forms.scheduling` | `form/scheduling/scheduling_playground_page.dart` | `/forms/playground/scheduling` | `examples.forms.playgrounds.scheduling` | `test/features/examples/forms_playgrounds_test.dart` | WF04, WF05, WF17, WF18 |
| `content.overview` | `data/playgrounds/overview_playground_page.dart` | `/content/playground/overview` | `examples.content.playgrounds.overview` | `test/features/examples/content_playgrounds_test.dart` | WD01, WD02, WD03, WD05 |
| `content.calendar` | `data/playgrounds/calendar_playground_page.dart` | `/content/playground/calendar` | `examples.content.playgrounds.calendar` | `test/features/examples/content_playgrounds_test.dart` | WD04, WD08 |
| `content.lists` | `data/playgrounds/lists_playground_page.dart` | `/content/playground/lists` | `examples.content.playgrounds.lists` | `test/features/examples/content_playgrounds_test.dart` | WD06, WD07, WT01, WT02, WT03, WT04 |
| `feedback.status` | `feedback/playgrounds/async_status_playground_page.dart` | `/feedback/playground/status` | `examples.feedback.playgrounds.async` | `test/features/examples/feedback_playgrounds_test.dart` | WFB01, WFB02, WFB03, WFB04, WO07 |
| `feedback.confirmation` | `feedback/playgrounds/confirmation_playground_page.dart` | `/feedback/playground/confirmation` | `examples.feedback.playgrounds.confirmation` | `test/features/examples/feedback_playgrounds_test.dart` | WO02, WO03, WO06, WFD03 |
| `feedback.contextual` | `feedback/playgrounds/contextual_feedback_playground_page.dart` | `/feedback/playground/contextual` | `examples.feedback.playgrounds.contextual` | `test/features/examples/feedback_playgrounds_test.dart` | WO04, WO05, WO08, WFD05 |

The official capability ledger below joins to this registry through Playground
ID. Documented and excluded entries continue to name their authoritative source
or rationale directly. AGrid remains in the registry as an Admin9 extension and
is not counted as one of Forui's 72 official capabilities.

### Current Capability Ledger

<!-- forui-capability-ledger:start -->
| ID | Official capability | Required axes | Current page and route | Coverage | Evidence or mobile rationale |
| --- | --- | --- | --- | --- | --- |
| C01 | [Themes](https://forui.dev/docs/concepts/themes) | light/dark, touch, colors, typography, icons, style, variants, Material mapping | `foundation.theme` | direct | `test/features/settings/theme_workbench_test.dart` |
| C02 | [Controls](https://forui.dev/docs/concepts/controls) | lifted, managed internal/external, lifecycle and synchronization | `foundation.interaction` | direct | `test/features/examples/foundation_playgrounds_test.dart` |
| C03 | [Localization](https://forui.dev/docs/concepts/localization) | App/Forui ownership, Chinese delegate and component copy | `foundation.app_shell` | direct | `test/features/examples/foundation_playgrounds_test.dart` |
| C04 | [Responsive](https://forui.dev/docs/concepts/responsive) | Android/iOS touch variants, breakpoints and 320/390 integration; desktop runtime is outside this mobile Starter | `foundation.app_shell` | direct | `test/features/examples/foundation_playgrounds_test.dart` |
| G01 | [Adding Theme Properties](https://forui.dev/docs/guides/adding-theme-properties) | ThemeExtension registration, typed access, copyWith and lerp | `foundation.theme` | direct | `test/app/theme_resolution_test.dart`; `test/shared/ui/layout/grid/a_grid_style_test.dart` |
| G02 | [Customizing Themes](https://forui.dev/docs/guides/customizing-themes) | generated parts, light/dark ownership and regeneration boundary | `lib/theme/`; `docs/ui.md` | documented | Theme source review and the manual regeneration review boundary in `docs/ui.md` |
| G03 | [Customizing Widget Styles](https://forui.dev/docs/guides/customizing-widget-styles) | delta, full replacement and variant resolution | `foundation.theme` | direct | `test/features/settings/theme_workbench_test.dart` |
| G04 | [Customizing Icons](https://forui.dev/docs/guides/customizing-icons) | FIcons mapping and component propagation | `foundation.icons` | direct | `test/features/examples/foundation_playgrounds_test.dart` |
| G05 | [Creating Custom Deltas](https://forui.dev/docs/guides/creating-custom-deltas) | adoption trigger and public transformation contract | `docs/starter.md` | documented | No current transformation gap; do not create an empty delta API |
| G06 | [Creating Custom Controllers](https://forui.dev/docs/guides/creating-custom-controllers) | adoption trigger, lifecycle and ownership | `docs/starter.md` | documented | Standard managed/lifted controls satisfy current examples |
| G07 | [Using Forui A La Shadcn/ui](https://forui.dev/docs/guides/using-forui-a-la-shadcn-ui) | source ownership and upgrade cost | `docs/starter.md` | excluded | The Starter does not unpack or fork Forui source |
| R01 | [CLI](https://forui.dev/docs/reference/cli) | init, theme/style/snippet list/create, output and overwrite rules | `AGENTS.md`; `docs/ui.md` | documented | Project commands use locked `dart run forui_cli`; no runtime page |
| R02 | [Icons](https://forui.dev/docs/reference/icon-library) | Lucide browser, size/color/semantics and FIcons mapping | `foundation.icons` | direct | `test/features/examples/foundation_playgrounds_test.dart` |
| R03 | [Hooks](https://forui.dev/docs/reference/hooks) | adoption and controller lifecycle tradeoff | `docs/starter.md` | excluded | No `flutter_hooks` or `forui_hooks` dependency in the baseline |
| R04 | [LLMs](https://forui.dev/docs/reference/llms) | snapshot source, capture time, hashes and unversioned-site warning | `.agents/skills/admin9-flutter-app/references/0.26.0/source.json` | documented | Checked-in version-bound documentation evidence |
| WL01 | [Divider](https://forui.dev/docs/widgets/layout/divider) | visual and semantic separation, padding and direction | `foundation.app_shell` | direct | `test/features/examples/foundation_playgrounds_test.dart` |
| WL02 | [Resizable](https://forui.dev/docs/widgets/layout/resizable) | pointer drag and split layout | `docs/starter.md` | excluded | Desktop/pointer-first interaction |
| WL03 | [Scaffold](https://forui.dev/docs/widgets/layout/scaffold) | header/footer/content, safe area and scroll behavior | `foundation.app_shell` | direct | `test/features/examples/foundation_playgrounds_test.dart` |
| WF01 | [Autocomplete](https://forui.dev/docs/widgets/form/autocomplete) | filtering, suggestion selection, validation and errors | `forms.text_input` | direct | `test/features/examples/forms_playgrounds_test.dart` |
| WF02 | [Button](https://forui.dev/docs/widgets/form/button) | variants, xs/sm/md/lg, standard/icon/raw, states, prefix/suffix, progress, mainAxisSize, semantics | `forms.buttons` | direct | `test/features/examples/forms_playgrounds_test.dart` |
| WF03 | [Checkbox](https://forui.dev/docs/widgets/form/checkbox) | checked/unchecked, error, disabled and semantics; no indeterminate API in 0.26.0 | `forms.selection_controls` | direct | `test/features/examples/forms_playgrounds_test.dart` |
| WF04 | [Date Field](https://forui.dev/docs/widgets/form/date-field) | input/calendar, validation and mobile interaction | `forms.scheduling` | direct | `test/features/examples/forms_playgrounds_test.dart` |
| WF05 | [Date Time Picker](https://forui.dev/docs/widgets/form/date-time-picker) | date/time selection, interval and touch controls | `forms.scheduling` | direct | `test/features/examples/forms_playgrounds_test.dart` |
| WF06 | [Label](https://forui.dev/docs/widgets/form/label) | label, description, error and required semantics | `forms.text_input` | direct | `test/features/examples/forms_playgrounds_test.dart` |
| WF07 | [Multi Select](https://forui.dev/docs/widgets/form/multi-select) | search, multiple values, clear, loading/error and form behavior | `forms.selects` | direct | `test/features/examples/forms_playgrounds_test.dart` |
| WF08 | [OTP Field](https://forui.dev/docs/widgets/form/otp-field) | length, input, focus, validation and semantics | `forms.text_input` | direct | `test/features/examples/forms_playgrounds_test.dart` |
| WF09 | [Picker](https://forui.dev/docs/widgets/form/picker) | wheel, localized adjustable semantics and multi-value composition | `forms.value_controls` | direct | `test/features/examples/forms_playgrounds_test.dart` |
| WF10 | [Radio](https://forui.dev/docs/widgets/form/radio) | selected, disabled, group behavior and semantics | `forms.selection_controls` | direct | `test/features/examples/forms_playgrounds_test.dart` |
| WF11 | [Select Group](https://forui.dev/docs/widgets/form/select-group) | single/multiple, form state and disabled items | `forms.selection_controls` | direct | `test/features/examples/forms_playgrounds_test.dart` |
| WF12 | [Select](https://forui.dev/docs/widgets/form/select) | search, sections, clear, loading/error and formatting | `forms.selects` | direct | `test/features/examples/forms_playgrounds_test.dart` |
| WF13 | [Slider](https://forui.dev/docs/widgets/form/slider) | value/range, bounds, marks, drag/tap and semantic value forecasts; no adjustable SemanticsAction in 0.26.0 | `forms.value_controls` | direct | `test/features/examples/forms_playgrounds_test.dart` |
| WF14 | [Switch](https://forui.dev/docs/widgets/form/switch) | on/off, disabled, labels and semantics | `forms.selection_controls` | direct | `test/features/examples/forms_playgrounds_test.dart` |
| WF15 | [Text Field](https://forui.dev/docs/widgets/form/text-field) | input, password/email, multiline, selection and enabled states | `forms.text_input` | direct | `test/features/examples/forms_playgrounds_test.dart` |
| WF16 | [Text Form Field](https://forui.dev/docs/widgets/form/text-form-field) | validation, save/reset, errors and keyboard interaction | `forms.text_input` | direct | `test/features/examples/forms_playgrounds_test.dart` |
| WF17 | [Time Field](https://forui.dev/docs/widgets/form/time-field) | input/picker, 24-hour value, validation, popover and managed onChange; public onSubmit is not forwarded in 0.26.0 | `forms.scheduling` | direct | `test/features/examples/forms_playgrounds_test.dart` |
| WF18 | [Time Picker](https://forui.dev/docs/widgets/form/time-picker) | hour/minute, interval, 24-hour and touch semantics | `forms.scheduling` | direct | `test/features/examples/forms_playgrounds_test.dart` |
| WD01 | [Accordion](https://forui.dev/docs/widgets/data/accordion) | multiple sections, expand/collapse and semantics | `content.overview` | direct | `test/features/examples/content_playgrounds_test.dart` |
| WD02 | [Avatar](https://forui.dev/docs/widgets/data/avatar) | image, fallback, raw content and sizes | `content.overview` | direct | `test/features/examples/content_playgrounds_test.dart` |
| WD03 | [Badge](https://forui.dev/docs/widgets/data/badge) | variants, labels, counts and semantics | `content.overview` | direct | `test/features/examples/content_playgrounds_test.dart` |
| WD04 | [Calendar](https://forui.dev/docs/widgets/data/calendar) | single/multiple/range, disabled dates and navigation | `content.calendar` | direct | `test/features/examples/content_playgrounds_test.dart` |
| WD05 | [Card](https://forui.dev/docs/widgets/data/card) | title, subtitle, child and grouped actions | `content.overview` | direct | `test/features/examples/content_playgrounds_test.dart` |
| WD06 | [Item Group](https://forui.dev/docs/widgets/data/item-group) | divider, scrolling, grouping and disabled state | `content.lists` | direct | `test/features/examples/content_playgrounds_test.dart` |
| WD07 | [Item](https://forui.dev/docs/widgets/data/item) | prefix/suffix, subtitle/details, destructive and disabled | `content.lists` | direct | `test/features/examples/content_playgrounds_test.dart` |
| WD08 | [Line Calendar](https://forui.dev/docs/widgets/data/line-calendar) | horizontal selection, disabled dates and scrolling | `content.calendar` | direct | `test/features/examples/content_playgrounds_test.dart` |
| WT01 | [Select Menu Tile](https://forui.dev/docs/widgets/tile/select-menu-tile) | menu selection, labels, details and disabled state | `content.lists` | direct | `test/features/examples/content_playgrounds_test.dart` |
| WT02 | [Select Tile Group](https://forui.dev/docs/widgets/tile/select-tile-group) | radio/checkbox selection, form and disabled state | `content.lists` | direct | `test/features/examples/content_playgrounds_test.dart` |
| WT03 | [Tile Group](https://forui.dev/docs/widgets/tile/tile-group) | touch grouping, dividers and interaction | `content.lists` | direct | `test/features/examples/content_playgrounds_test.dart` |
| WT04 | [Tile](https://forui.dev/docs/widgets/tile/tile) | touch target, prefix/suffix, disabled and destructive | `content.lists` | direct | `test/features/examples/content_playgrounds_test.dart` |
| WN01 | [Bottom Navigation Bar](https://forui.dev/docs/widgets/navigation/bottom-navigation-bar) | five items, selected state, equal geometry, nested no-double-inset and App Shell safe area | `foundation.app_shell` | direct | `test/features/examples/foundation_playgrounds_test.dart`; `test/acceptance/mobile_starter_acceptance_test.dart` |
| WN02 | [Breadcrumb](https://forui.dev/docs/widgets/navigation/breadcrumb) | hierarchical pointer navigation | `docs/starter.md` | excluded | Desktop/large information architecture |
| WN03 | [Header](https://forui.dev/docs/widgets/navigation/header) | root/nested, prefix/suffix actions and semantics | `foundation.app_shell` | direct | `test/features/examples/foundation_playgrounds_test.dart` |
| WN04 | [Pagination](https://forui.dev/docs/widgets/navigation/pagination) | paged pointer navigation | `docs/starter.md` | excluded | Desktop/data-table interaction |
| WN05 | [Sidebar](https://forui.dev/docs/widgets/navigation/sidebar) | persistent side navigation | `docs/starter.md` | excluded | Desktop/large-screen navigation |
| WN06 | [Tabs](https://forui.dev/docs/widgets/navigation/tabs) | FTabs equal/scrollable, managed/lifted, indicator, content and swipe | `foundation.interaction` | direct | `test/features/examples/foundation_playgrounds_test.dart` |
| WFB01 | [Alert](https://forui.dev/docs/widgets/feedback/alert) | variants, title/message and static live-region policy | `feedback.status` | direct | `test/features/examples/feedback_playgrounds_test.dart` |
| WFB02 | [Circular Progress](https://forui.dev/docs/widgets/feedback/circular-progress) | indeterminate animation, sizing and semantics | `feedback.status` | direct | `test/features/examples/feedback_playgrounds_test.dart` |
| WFB03 | [Determinate Progress](https://forui.dev/docs/widgets/feedback/determinate-progress) | value, labels and semantics | `feedback.status` | direct | `test/features/examples/feedback_playgrounds_test.dart` |
| WFB04 | [Progress](https://forui.dev/docs/widgets/feedback/progress) | indeterminate animation and semantics | `feedback.status` | direct | `test/features/examples/feedback_playgrounds_test.dart` |
| WO01 | [Context Menu](https://forui.dev/docs/widgets/overlay/context-menu) | pointer and secondary-click menu | `docs/starter.md` | excluded | Pointer-first interaction |
| WO02 | [Dialog](https://forui.dev/docs/widgets/overlay/dialog) | adaptive layout, confirm/cancel, dismissal and focus restore | `feedback.confirmation` | direct | `test/features/examples/feedback_playgrounds_test.dart` |
| WO03 | [Persistent Sheet](https://forui.dev/docs/widgets/overlay/persistent-sheet) | lifecycle, toggle and interaction with underlying page | `feedback.confirmation` | direct | `test/features/examples/feedback_playgrounds_test.dart` |
| WO04 | [Popover Menu](https://forui.dev/docs/widgets/overlay/popover-menu) | menu selection, alignment and dismissal | `feedback.contextual` | direct | `test/features/examples/feedback_playgrounds_test.dart` |
| WO05 | [Popover](https://forui.dev/docs/widgets/overlay/popover) | alignment, flip/overflow, lifted state and dismissal | `feedback.contextual` | direct | `test/features/examples/feedback_playgrounds_test.dart` |
| WO06 | [Sheet](https://forui.dev/docs/widgets/overlay/sheet) | modal layout, dismissal, safe area and focus restore | `feedback.confirmation` | direct | `test/features/examples/feedback_playgrounds_test.dart` |
| WO07 | [Toast](https://forui.dev/docs/widgets/overlay/toast) | duration, alignment, variants, dismissal and focus behavior | `feedback.status` | direct | `test/features/examples/feedback_playgrounds_test.dart` |
| WO08 | [Tooltip](https://forui.dev/docs/widgets/overlay/tooltip) | group, tap/long-press, semantics and cleanup | `feedback.contextual` | direct | `test/features/examples/feedback_playgrounds_test.dart` |
| WFD01 | [Collapsible](https://forui.dev/docs/widgets/foundation/collapsible) | external value, vertical/horizontal axis, motion and hidden/disclosure semantics | `foundation.interaction` | direct | `test/features/examples/foundation_playgrounds_test.dart` |
| WFD02 | [Focused Outline](https://forui.dev/docs/widgets/foundation/focused-outline) | focus visibility without layout shift | `foundation.interaction` | indirect | `test/features/examples/foundation_playgrounds_test.dart` |
| WFD03 | [Overlay](https://forui.dev/docs/widgets/foundation/overlay) | barrier, composition, dismissal and focus | `feedback.confirmation` | indirect | `test/features/examples/feedback_playgrounds_test.dart` |
| WFD04 | [Point Portal](https://forui.dev/docs/widgets/foundation/point-portal) | point anchoring and viewport overflow | `docs/starter.md` | excluded | Forui 0.26.0 uses it for pointer-first Context Menu; no mobile higher-level consumer |
| WFD05 | [Portal](https://forui.dev/docs/widgets/foundation/portal) | edge anchoring, flip and overflow | `feedback.contextual` | indirect | `test/features/examples/feedback_playgrounds_test.dart` |
| WFD06 | [Tappable](https://forui.dev/docs/widgets/foundation/tappable) | gestures, disabled/selected/pressed/focus variants and semantics | `foundation.interaction` | direct | `test/features/examples/foundation_playgrounds_test.dart` |
<!-- forui-capability-ledger:end -->

## Examples Removal Contract

A derived project that removes Examples must remove
`lib/features/examples/`, its Playground-only widgets, the single
`examples_routes.dart` integration, the four Showroom destinations in the shell,
the `/foundation` fallback, Playground registry and capability ledger, Examples
tests, all `examples.*` translations, and current Showroom screenshots or
acceptance claims. It must regenerate AutoRoute output and verify that removed
Pages, generated routes, translation namespaces, and tests have no residual
consumer.

Do not remove AGrid with Examples. Retain Settings and every shared pattern it
still consumes. Re-evaluate any shared pattern that loses its final real
consumer instead of retaining an empty compatibility API.

## Acceptance Boundary

Automated tests establish deterministic Dart and Flutter behavior only. Android
and iOS builds, platform rendering, system and predictive back, iOS edge back,
real IME, text-selection handles, native persistence across relaunch, simulator
behavior, signing, installation, and physical-device acceptance remain
`Unknown` until separately authorized and executed against the current source.
