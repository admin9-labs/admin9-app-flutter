# Admin9 Cross-platform UI Decision Baseline

Status: working baseline for the Demo-first UI unification initiative
Last updated: 2026-08-23

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

| Comparison object | Role | Evidence required before recommendation |
| --- | --- | --- |
| Current `App*` implementation | Control only | Records old-contract behavior, implementation size, test baseline, and the visible Material/Cupertino split; it cannot win unchanged |
| First-party candidate behind `App*` | Candidate | Meets paired references and state matrix with acceptable implementation size, accessibility, performance, and maintenance cost |
| Third party adapted behind `App*` | Candidate | Clear delivery or quality advantage; compatible Flutter version; acceptable license/security/maintenance; full theming and testability; no leaked package types |
| Mixed | Conditional candidate | A named, measured gap in both single routes; explicit ownership per component; lower total cost than closing the gap in one route |

Evaluation order is the control, the first-party candidate, one primary package
candidate, and at most one backup package. The backup receives implementation
work only after the primary is eliminated or a material evidence gap requires a
second package. A third-party Theme, Controller, Router, state model, enum,
callback, style, or context extension must not cross `App*` into business code.
Removal must leave business APIs and the route tree intact.

G2 implemented Forui 0.25.0 as the primary package candidate and retained
`shadcn_ui` 0.56.1 as an evidence-only backup. The same-scenario comparison
recommends the first-party unified route: it met the fixed POC contract without
a named package-only capability gap, while Forui required substantial wrappers,
bundled font/license handling, semantics and typography compatibility work,
pressure-layout exceptions, and still lacked progress parity. Three bounded
closure reviewers returned Go on G2 commit
`06a398a747178e1aaed4933f96806ced3c498ad8`.

G3 therefore selects the first-party route for this Demo. Forui, its transitive
packages and the complete G2 POC are removed before production integration.
This is an evidence-based component implementation decision, not a general ban
on third-party packages, approval of final visual tokens, real-device Demo
acceptance, or authorization for Starter migration.

`App*` owns visible, business-neutral component presentation. It does not own
permissions, sharing, system pickers, keyboard services, autofill, or other
platform capabilities. Those remain in the existing capability/service or
navigation layer. A component may display the explanation and result of a
capability, but must not become the capability implementation.

Candidate imports and indirect public-type leakage are mechanically checked by
`tool/design_system/verify_ui_candidate_boundary.dart` using
`tool/design_system/ui_candidate_boundary.json`. Candidate package imports are
allowed only in the configured Design System adapter root and must use a
prefix. The gate rejects candidate exports, candidate types in adapter public
signatures, public adapter context extensions, adapter types in exported
`App*` signatures, and inferred public types in adapters or adapter-dependent
`App*` sources. Root Theme files cannot reach adapters; the App host can reach
them only through the public `admin9_ui.dart` barrel. Every direct non-SDK
dependency must be classified as either a checked baseline package or a named
candidate, and the policy is checked in both directions against `pubspec.yaml`.
G2 adds the chosen exact package names to the policy before candidate code is
accepted.

Golden tests protect each platform's approved rendering. Cross-platform unity
is evaluated with shared structure/token assertions, paired human review, and
Android/iOS real-device acceptance, not pixel equality between operating
systems.

## Accessibility unity contract

Brand and business semantics are shared: accessible name, role, value, reading
order, validation error, state meaning, recovery action, and destructive
meaning must match on Android and iOS.

For state announcements, the contract is the visible result message announced
once after the state becomes visible. Rebuilds, theme changes, layout changes,
and route restoration must not repeat it. An announcement must not move focus;
modal dismissal restores the prior valid focus target. Widget tests assert the
message, count, timing relative to the visible state, and focus result. Device
tests observe the actual TalkBack/VoiceOver delivery.

The OS may use different live-region scheduling, focus highlights, rotor or
accessibility actions, Switch Access/Control mechanics, and announcement
delivery. Those mechanism differences are allowed; different business content
or repeated/missing announcements are not.

## Stage protocol

Entry, exit, severity, ownership, resource limits, fixed-reference rules, and
elimination criteria are defined in
[admin9-ui-stage-gates.md](admin9-ui-stage-gates.md). A reference-source or
manifest change invalidates all candidate evidence from the previous round;
every comparison object must rerun against the same new reference commit.

## Undecided

- Final brand art direction and approver acceptance.
- Final font, type metrics, icon family, spacing, radii, and component geometry.
- Design System release/version naming.
- Starter migration scope and migration sequence.

## Change log

- 2026-08-23: closed G2 Go at `06a398a`, selected the first-party route for the
  Demo, and removed Forui from G3 production integration while retaining the
  package-neutral `App*` boundary.
- 2026-08-23: closed the G2 supervision P1 set with a fixed baseline/alternate
  scenario matrix, executable semantics, announcement timing/focus checks, 110
  Golden images, real pressed pixels, a regenerated CJK subset, pressure-layout
  fixes and a full-POC removal drill. Recorded Forui truncation/progress limits
  and non-gating performance evidence without expanding G2.
- 2026-08-23: recorded the G2 candidate identities and provisional first-party
  recommendation without treating it as final visual or Starter approval.
- 2026-08-23: closed the fixed-commit P1 review findings. Distinguished legal
  App-host/barrel encapsulation from root Theme leakage, added bidirectional
  dependency classification and explicit public-type gates, repaired pressed
  reference rendering, and bound calibration ratios to the generator palette.
- 2026-08-22: revised G1 after independent review. Separated the current
  implementation control from first-party and third-party candidates, narrowed
  `App*` to visible UI, added executable candidate leakage gates, froze the
  accessibility announcement contract, and added staged entry/exit rules.
- 2026-08-22: established the Demo-first baseline after real-device evidence
  showed the broad Material/Cupertino visible mapping does not meet product
  unity. Retained `App*`, system behavior adaptation, and the single route tree.
