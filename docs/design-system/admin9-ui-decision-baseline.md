# Admin9 Cross-platform UI Decision Baseline

Status: working baseline for the Demo-first UI unification initiative
Last updated: 2026-08-22

When this document conflicts with the v1 Material/Cupertino visible-component
mapping, this document controls the current initiative. Older phase documents
remain historical evidence of the implemented baseline.

## Confirmed product principle

> 统一品牌外观、统一业务体验、保留系统交互差异。

This separates three concerns:

- **UI unity:** both platforms use the same Admin9 visual identity, hierarchy,
  component states, icon language, density intent, and content composition.
- **UX unity:** the same task has the same information order, action priority,
  copy, validation, state transitions, feedback meaning, and recovery path.
- **Platform adaptation:** system gestures and capabilities behave as users of
  that platform expect; this is not permission to replace every visible
  control with a platform-branded widget.

Examples: the registration field order, button hierarchy, error placement, and
unavailable result are UI/UX-owned and align. iOS edge-back, Android predictive
back, IME action behavior, autofill, safe-area handling, and accessibility
services remain platform-owned.

## Current facts

1. The user has compared the current Demo on Android and iOS real devices and
   reports that they look like two products. This is valid product evidence.
2. Current source deliberately switches many visible components between
   Material and Cupertino. The affected surface includes page bars, buttons,
   fields, lists, sections, bottom navigation, dialogs, action sheets,
   feedback, progress indicators, switches, and icon glyphs.
3. Existing tests verify those platform mappings and their behavioral
   contracts. Passing them cannot prove a shared Admin9 visual identity.
4. `App*` already prevents business pages from choosing low-level platform
   widgets. It is therefore a useful replacement boundary and is retained.
5. `MaterialApp` provides host infrastructure and one route tree. It does not
   require Material visual treatment on iOS.

## Decision hierarchy

1. Product truth and the confirmed principle.
2. This decision baseline and the ownership matrix.
3. Approved paired references and their state coverage.
4. Component/API implementation and tests.
5. Historical v1 mapping and old Golden images.

An old test or document must be revised when it conflicts with a newly approved
brand-owned result. System behavior coverage must not be discarded during that
revision.

## Ownership boundary

The detailed matrix is in
[admin9-ui-ownership-matrix.md](admin9-ui-ownership-matrix.md).

- **Brand-owned:** visible palette roles, semantic type hierarchy, spacing and
  shape rhythm, icon style, buttons, fields, list language, cards/surfaces,
  loading/empty/error states, and business feedback.
- **System-owned:** back gestures, route-transition mechanics, keyboards,
  autofill/password managers, permissions, share UI, system pickers, safe
  areas, and operating-system accessibility behavior.
- **Mixed:** top and bottom navigation, switches, menus, business dialogs, and
  date/time selection. Each gets one explicit visible and behavioral contract;
  none is automatically platform-swapped.

## Allowed platform differences

Allowed differences must be behaviorally necessary and recorded in the matrix:

- Android predictive-back versus iOS interactive edge-back and their native
  transition mechanics.
- Android 48dp versus iOS 44pt minimum hit-region gates.
- Keyboard layout, IME action presentation, autofill/password-manager UI, and
  system text rendering.
- Safe-area, status/navigation bar, permission, sharing, and system-picker UI.
- Accessibility focus highlights, announcements, rotor/actions, and switch
  access mechanics supplied by the OS.

Allowed does not mean required. Small rasterization or system-font differences
are acceptable; different information hierarchy or visibly unrelated control
families are not.

## Working visual direction

The paired references use the repository's current semantic palette and a
restrained, work-focused character as a reversible comparison fixture. They
align visible page bars, fields, buttons, rows, navigation, states, and feedback
across platforms while annotating system-owned behavior separately.

The references do **not** approve a font family, exact sizes, icon pack, spacing,
corner radii, Design System version, or Starter migration. Values in generated
assets are calibration inputs that candidate implementations must reproduce or
improve; they are not frozen tokens.

## Component implementation selection

Three routes remain eligible:

| Route | Evidence required before recommendation |
| --- | --- |
| Existing/self-built `App*` | Meets paired references and state matrix with acceptable implementation size, accessibility, performance, and maintenance cost |
| Third party inside `App*` | Clear delivery or quality advantage; compatible Flutter version; acceptable license/security/maintenance; full theming and testability; no leaked package types |
| Mixed | A named, measured gap in either single route; explicit ownership per component; lower total cost than closing the gap in one route |

Evaluation order is current `App*` baseline, one primary package candidate, and
at most one backup. A third-party Theme, Controller, Router, state model, or
enum must not cross `App*` into business code. Removal must leave business APIs
and the route tree intact.

Golden tests protect each platform's approved rendering. Cross-platform unity
is evaluated with shared structure/token assertions, paired human review, and
Android/iOS real-device acceptance, not pixel equality between operating
systems.

## Undecided

- Final brand art direction and approver acceptance.
- Self-built, third-party, or mixed implementation.
- Third-party candidates and exact versions.
- Final font, type metrics, icon family, spacing, radii, and component geometry.
- Design System release/version naming.
- Starter migration scope and migration sequence.

## Change log

- 2026-08-22: established the Demo-first baseline after real-device evidence
  showed the broad Material/Cupertino visible mapping does not meet product
  unity. Retained `App*`, system behavior adaptation, and the single route tree.
