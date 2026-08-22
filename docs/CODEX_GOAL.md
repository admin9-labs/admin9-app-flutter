# Admin9 Flutter UI Unification Goal

## Current objective

Deliver and verify a Demo-first cross-platform UI direction that follows one
product rule:

> 统一品牌外观、统一业务体验、保留系统交互差异。

Android and iOS must read as the same Admin9 product. Business information,
actions, copy, state, and feedback stay aligned. Back gestures, route
transitions, keyboards, autofill, permissions, system pickers, sharing, safe
areas, and accessibility keep their platform behavior.

## Current stage

G1 candidate ready: decision baseline, current-difference audit, ownership
matrix, and four paired visual references are awaiting fixed-commit review.

## Completed

- Rechecked repository instructions, Git state, design-system documents,
  `App*` exports, visible platform mappings, tests, and existing reference
  assets at `b28689a89c8b5ea3a07441f28748eb6dcec00493`.
- Created local branch `codex/ui-unification`; no remote operation was made.
- Confirmed the user's Android/iOS real-device observation is explained by
  deliberate visible Material/Cupertino branching, not a rendering failure.
- Preserved `App*`, the single route tree, and the `MaterialApp` host as current
  architectural boundaries.
- Added four generated Android/iOS reference pairs for login/registration,
  main navigation/list, settings form, and dialog/feedback.
- Added a verifier that rejects cross-platform visible structure drift outside
  explicitly allowed platform annotations.

## Verification evidence

- 2026-08-22: `flutter analyze` passed with no issues on Flutter 3.44.1 / Dart
  3.12.1.
- 2026-08-22: `flutter test --exclude-tags golden` passed 164 tests. This is an
  old-contract regression baseline, not proof of cross-platform brand unity.
- Current visible branching is present in `AppButton`, `AppTextField`,
  `AppPage`, `AppBottomNavigation`, `AppDialog`, `AppActionMenu`, `AppSwitch`,
  `AppListTile`, feedback, progress, icon mapping, and shell scaffolds.

## Provisional decisions

- The current Admin9 palette and restrained work-product character are a
  replaceable working reference, not approved final brand art direction.
- Brand-owned visible controls should converge before system-owned behavior is
  changed.
- Existing self-built `App*` components are the comparison baseline. A third
  party package is neither required nor excluded.
- A mixed implementation is allowed only when evidence shows a single
  implementation route has a material gap.

## Blocking decisions

- Final Admin9 brand direction and final approval still belong to the user.
- Starter adoption is blocked until the user accepts the Demo on Android and
  iOS real devices.

These do not block reversible reference work, candidate research, isolated
POCs, or Demo implementation.

## Next

1. Commit the verified G1 snapshot.
2. Run three independent read-only G1 reviews against the fixed commit and
   revise until Go.
3. Screen one primary and at most one backup package, then build removable,
   `App*`-contained comparison POCs.
