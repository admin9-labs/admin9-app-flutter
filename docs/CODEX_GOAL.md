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

G1 revised candidate verified locally. The first fixed-commit review returned
three Revise results; the required reference-state, ownership, boundary,
accessibility, severity, resource, and stage-gate corrections are ready for a
new fixed-commit review.

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
- Completed the first independent G1 review: all three reviewers returned
  Revise, not Block, and agreed on the required corrections.
- Replaced static state-overclaiming with visible signed-in list, empty/error,
  focused field, long error, persistence failure, action menu,
  pressed/disabled/focused, determinate/indeterminate, dialog, and feedback
  reference states.
- Separated the current implementation control from first-party and
  third-party candidates; narrowed `App*` to visible UI while system
  capabilities remain in capability/service or navigation layers.
- Added a candidate boundary policy and analyzer-based gate with positive and
  negative fixtures for direct imports, exports, vendor types, callbacks,
  context extensions, wrapper/controller leakage, and root Theme imports.
- Added functional owners, P0/P1 definitions, candidate resource limits,
  fixed-reference rules, removal proof, and G1-G3 entry/exit gates.

## Verification evidence

- 2026-08-22: `flutter analyze` passed with no issues on Flutter 3.44.1 / Dart
  3.12.1.
- 2026-08-22: `flutter test --exclude-tags golden` passed 145 tests. This is an
  old-contract regression baseline, not proof of cross-platform brand unity.
- 2026-08-22: the explicitly tagged existing Flutter Golden suite passed 19
  tests. It protects v1 rendering only; no unified candidate rendering exists
  in G1.
- 2026-08-22: 16 generated SVG/PNG assets passed dimension, required-state,
  hash, and explicitly marked platform-difference structure checks; all eight
  boards were manually checked after auth spacing and Account reflow/state
  corrections.
- 2026-08-22: existing import/public API/Gallery gates passed. The new UI
  candidate boundary passed one positive and 18 exact negative fixtures plus
  the repository scan.
- 2026-08-22: CI now excludes only tests tagged `golden`, keeps the two ordinary
  layout/semantics stress tests in the default suite, and verifies the generated
  paired-reference assets and manifest.
- 2026-08-22: documentation links/structure, Dart formatting, and
  `git diff --check` passed.
- Current visible branching is present in `AppButton`, `AppTextField`,
  `AppPage`, `AppBottomNavigation`, `AppDialog`, `AppActionMenu`, `AppSwitch`,
  `AppListTile`, feedback, progress, icon mapping, and shell scaffolds.

## Provisional decisions

- The current Admin9 palette and restrained work-product character are a
  replaceable working reference, not approved final brand art direction.
- Brand-owned visible controls should converge before system-owned behavior is
  changed.
- Existing self-built `App*` components are the comparison baseline. A third
  party package is neither required nor excluded. The unchanged implementation
  is the control, not a candidate winner.
- A mixed implementation is allowed only when evidence shows a single
  implementation route has a material gap.
- One primary package and at most one evidence-triggered backup may enter POC;
  no candidate type or adapter may leak through the `App*` public surface.

## Blocking decisions

- Final Admin9 brand direction and final approval still belong to the user.
- Starter adoption is blocked until the user accepts the Demo on Android and
  iOS real devices.

These do not block reversible reference work, candidate research, isolated
POCs, or Demo implementation.

## Next

1. Commit the verified G1 correction snapshot without amending the first G1
   commit.
2. Run three independent read-only G1 reviews against that exact commit and
   revise until all return Go.
3. After G1 Go, screen one primary and at most one backup package, then build
   removable, `App*`-contained comparison POCs against the same reference SHA.
