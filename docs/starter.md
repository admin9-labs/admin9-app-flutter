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

## Mobile Catalog

The upstream example targets Android and iOS and demonstrates Forui 0.26.0
capabilities relevant to mobile use. Its five persistent destinations are:

| Destination | Path | Direct coverage |
| --- | --- | --- |
| Foundation | `/foundation` | `FScaffold`, divider, header, bottom navigation, tabs, collapsible, tappable, Theme, Controls, Responsive, icons, and safe-area composition |
| Forms | `/forms` | buttons, labels, text/form fields, autocomplete, OTP, checkbox, radio, select groups, select/multi-select, slider, switch, generic/date/time fields and pickers |
| Content | `/content` | cards, avatars, badges, accordions, calendars, items, tiles, and selectable tile/menu groups |
| Feedback | `/feedback` | alerts, circular/linear progress, dialogs, modal/persistent sheets, popovers, popover menus, toasts, and tooltips |
| Settings | `/settings` | persisted system/light/dark Theme preference and the complete Riverpod/Repository/Service example |

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

## Reference Acceptance

Every directly covered capability has a runnable route and focused Widget test.
Catalog Pages use concise labels and live states; long tutorial text belongs in
documentation. Acceptance covers Chinese copy, light/dark/system Theme, narrow
screens, large text, long labels, SafeArea, keyboard and text selection where
applicable, focus restoration, and no overflow.

New-source automated evidence proves only this reference implementation. Android
and iOS builds, simulator behavior, gestures, signing, installation, and physical
device acceptance remain separate evidence and require explicit authorization.
