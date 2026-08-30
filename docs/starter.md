# Upstream Starter Reference

## Authority And Derivation

This document defines only the runnable reference App bundled with the upstream
Admin9 Flutter Starter. It demonstrates one coherent use of the generic
architecture and UI rules; it is not a product contract for derived projects.

A derived project may remove or replace any example Feature, route, shared UI
pattern, platform exclusion, or acceptance case in this document. It must then
update or replace its local Starter reference document, tests, localization, and
acceptance claims. Upstream example behavior and evidence do not remain binding
after that change.

## Installation Identity

The upstream Starter uses `dev.admin9.starter` as its Android namespace and
application ID and as the iOS Runner bundle identifier. The iOS test bundle is
`dev.admin9.starter.RunnerTests`. The Apple development team, Automatic Signing,
certificate selection, and other signing configuration remain separate protected
settings.

This identifier replaces the previous Starter identity as a new App
installation. It does not overwrite, migrate, or delete an App installed under
another identifier. Derived products may adopt their own reviewed identity, but
must update Android packages, iOS targets, signing, delivery configuration,
tests, and their local authority together.

## Mobile Catalog

The upstream example targets Android and iOS and demonstrates Forui 0.26.0
capabilities relevant to mobile use. Its five persistent destinations are:

| Destination | Paths | Runnable surface | Focused automated evidence |
| --- | --- | --- | --- |
| Foundation | `/foundation`, `layout`, `navigation`, `interaction` | `FScaffold`, divider, header, bottom navigation, tabs, collapsible, tappable, Theme, Controls, Responsive, icons, and safe areas | Typed layout navigation, tab switching, collapsible value, and tappable state in `test/features/foundation/foundation_pages_test.dart` |
| Forms | `/forms`, `buttons-labels`, `text-input`, `toggles-groups`, `select-range`, `date-time` | Mobile form fields, validation, selection controls, sliders, switches, and touch pickers | Typed text-input navigation, validation, keyboard input, programmatic text selection, toggle/select interaction, slider presence, and date/time rendering in `test/features/forms/forms_pages_test.dart` |
| Content | `/content`, `basics`, `accordion`, `calendar`, `line-calendar`, `items-tiles`, `selectable-tiles` | Cards, avatars, badges, accordions, calendars, items, tiles, and selectable tile/menu groups | Representative rendering, calendar configuration, item/tile actions, and selectable menu behavior in `test/features/content/content_pages_test.dart` |
| Feedback | `/feedback`, `alerts-progress`, `dialogs`, `sheets`, `popovers`, `toasts-tooltips` | Alerts, progress, dialogs, modal/persistent sheets, popovers, menus, toasts, and tooltips | Representative rendering, open/dismiss flows, selection, toast lifecycle, and tooltip interaction in `test/features/feedback/feedback_pages_test.dart` |
| Settings | `/settings` | Persisted system/light/dark Theme preference and Riverpod/Repository/Service boundaries | Repository and Notifier success/failure behavior in `test/features/settings/`; App theme mapping in `test/acceptance/mobile_starter_acceptance_test.dart` |

Each destination is a concise catalog whose entries open runnable typed detail
Pages. It is not an oversized component dump or a claim that a derived product
needs these routes.

## Example Boundaries

- One nested AutoRoute Tab Router retains the five branch stacks in process.
- The example has no Guard, Observer, platform deep-link mapping, custom scheme,
  media route, or process-restoration claim.
- Settings persists only the Starter Theme preference through Riverpod, a
  Repository, and a SharedPreferences Service. It does not authorize privacy,
  authentication, accounts, or other product behavior.
- Shared UI is limited to stable patterns with current catalog consumers, such
  as responsive page bodies, example sections, and explicit loading, error, or
  empty states. It does not rename Forui primitives.

Exclude desktop- or pointer-first `Resizable`, Sidebar, Breadcrumb, Pagination,
and Context Menu. Do not add `forui_hooks`. Low-level Overlay, Portal,
PointPortal, and FocusedOutline are covered indirectly through popover, tooltip,
focus, and overlay tests rather than ordinary catalog Pages. CLI, style/snippet,
delta, controller, and icon-generation guidance remains in generic documentation
and source checks.

The route tests assert the absence of Guards and speculative media paths. The
desktop-component and package exclusions above remain implementation scope and
source-review constraints; they are not represented as a comprehensive runtime
test. The localization test verifies that every statically discoverable App key
has a non-empty Simplified Chinese translation.

## Reference Acceptance

Every directly covered capability has a runnable route. Focused Widget tests are
representative and are listed separately from the wider runnable surface above;
the presence of a component in a Page is not treated as proof of every state or
interaction it supports. Catalog Pages use concise labels and live states; long
tutorial text belongs in documentation.

The deterministic flutter-tester acceptance gate is:

```shell
flutter test test/acceptance/mobile_starter_acceptance_test.dart
```

| Evidence area | Automated coverage | Evidence boundary |
| --- | --- | --- |
| Theme mapping | Explicit light and dark preferences plus system preference against controlled light/dark platform brightness | Verifies Material and Forui theme selection, not physical-device contrast or font rendering |
| Root navigation and layout | All five persistent destinations at 320, 360, and 390 logical pixels; 2x text at 320; representative long Chinese copy; non-zero view padding and view insets; responsive `SafeArea`; equal-width bottom-navigation items, aligned icons and labels, distinct selected state, single safe-area contribution, and no Flutter layout exception | Covers representative root Pages in the real Tab Shell, not every detail Page at every matrix combination |
| Overlay focus | Dialog and modal Sheet restore focus to their trigger; Toast does not steal trigger focus | Flutter focus-tree evidence only; not screen-reader or physical keyboard acceptance |
| Forms | Focused tests cover validation, test keyboard input, programmatic selection, choice controls, and representative date/time picker presentation | Does not prove a real Android/iOS IME, native text handles, locale keyboard, or system picker |
| Localization | Static App translation keys exist and have non-empty Simplified Chinese values | Dynamic key construction, font fallback appearance, and another locale are not claimed |
| Persistence flow | Unit tests cover Repository and Notifier behavior; `integration_test/starter_flow_test.dart` covers an in-process UI flow with an in-memory preferences platform | Does not prove the Android/iOS SharedPreferences plugin, process death, or relaunch persistence |

The acceptance command's current exit status is the source of truth. Do not copy
an earlier passing result after source, dependency, Flutter, or test changes.

The following items remain `Unknown` until separately authorized and executed on
the named target: Android and iOS rendering, system/predictive back, iOS edge
back, real IME and text-selection handles, native picker behavior, platform
SharedPreferences persistence across relaunch, simulator behavior, signing,
installation, and physical-device acceptance.

New-source automated evidence proves only this reference implementation. Android
and iOS builds, simulator behavior, gestures, signing, installation, and physical
device acceptance remain separate evidence and require explicit authorization.
