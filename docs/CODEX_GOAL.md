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

G1 is closed Go at `cf68a24844e45c16d983d29fb4878ad2f14bfd41` and must not
be reopened or expanded. G2 is closed Go at
`06a398a747178e1aaed4933f96806ced3c498ad8`. G3 implements the selected
first-party route in the Demo: the Forui candidate and complete G2 POC are
removed, while the existing `App*` API, one route tree, App host and
system-owned behavior remain intact. Local verification is complete and the
implementation is ready for one fixed-SHA, three-reviewer G3 supervision pass.

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
- Closed the `6c30ac4` P1 set without changing production UI: legal
  host/barrel encapsulation, bidirectional dependency classification, explicit
  adapter-dependent public types, compatible pressed-state SVG opacity, and
  generator-bound visual calibration.
- Screened Forui 0.25.0 as the primary package and `shadcn_ui` 0.56.1 as an
  evidence-only backup; recorded exact artifacts, licenses, activity,
  advisories, dependency surfaces and exit risks before package code.
- Built one shared four-scenario harness for the current control, a new
  first-party unified candidate and an isolated Forui adapter without changing
  business pages, routes, the App host, root Theme or public `App*`.
- Passed 21 focused Widget tests and 110 G2 Golden tests covering the fixed
  baseline/alternate business states, executable semantics, announcements,
  dark/1.24x/3x-high-contrast/pressed evidence and nested system-font mapping.
- Regenerated the test-only Noto CJK subset from current `lib/` and `test/`
  glyphs after visual review found real missing business characters.
- Completed an isolated full-POC removal drill: all three Forui packages, G2
  sources/tests and 110 candidate images were removed while analyze, 145
  original non-Golden tests and boundary gates passed with zero `lib/app`,
  `lib/ui` or root Theme differences.
- Closed G2 after three independent bounded reviewers returned Go on
  `06a398a747178e1aaed4933f96806ced3c498ad8`.
- Removed Forui, its transitive packages, the G2 adapters/harness/tests and all
  110 candidate-only Goldens from the production tree.
- Reimplemented the visible `App*` families as one first-party Admin9 control
  language for Android and iOS, including page/shell structure, navigation,
  buttons, fields, settings rows, switches, dialogs, menus, feedback, notices,
  progress and icon mapping.
- Preserved the public `App*` contract, route tree, keyboard/autofill/focus,
  safe-area, back dispatch, accessibility services and capability ownership.
- Added paired Android/iOS production component Goldens and corrected the
  production notice semantics so one shared tone/title/message node does not
  consume the independent action.

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
- 2026-08-23: candidate fixtures passed one legal topology and 22 focused
  negative cases; repository dependency/boundary scanning and all 16 visual
  assets passed, and all eight 2400x1200 boards were visually rechecked.
- 2026-08-23: the fixed G2 candidate tree passed `flutter analyze`, 164
  non-Golden tests, 43 tagged Golden tests (24 G2 plus 19 existing), both
  Design System probes, all configuration/import/candidate/Gallery gates, and
  documentation verification across 65 Markdown files.
- 2026-08-23: Android Release APK and iOS no-codesign Release app builds passed.
  Both asset trees contained the three Forui font assets (2,627,296 bytes),
  confirming the package footprint is present even though the POC is unrouted.
- 2026-08-23: G2 supervision revision passed 21 focused Widget tests, 110 G2
  Goldens in update and compare modes, visual review of all three contact
  sheets, and a removal drill retaining all 145 original non-Golden tests.
- 2026-08-23: the full supervision revision passed `flutter analyze`, 169
  non-Golden tests, 129 tagged Goldens (110 G2 plus 19 existing), every CI
  Design System/documentation gate, Android Release APK 52.9 MB and iOS
  no-codesign Release app 19.7 MB.
- 2026-08-23: the G3 production tree passed `flutter analyze`, all 145 original
  non-Golden regressions, 21 production Goldens in compare mode, all
  configuration/import/candidate/Gallery/visual/documentation gates, Android
  Release APK 51,005,113 bytes and iOS no-codesign Release app 17.1 MB.
- 2026-08-23: final Android/iOS asset scans contain no Forui, Inter or Lucide
  candidate artifacts. Manual review of all 21 production Goldens found no
  incoherent overlap or cross-platform component-family drift.

## Provisional decisions

- The current Admin9 palette and restrained work-product character are a
  replaceable working reference, not approved final brand art direction.
- Brand-owned visible controls should converge before system-owned behavior is
  changed.
- G2 selected the first-party route for this Demo on evidence, not on a blanket
  ban against third-party UI packages. Future package adoption still requires a
  named capability or maintenance advantage and the same removable `App*`
  boundary.
- A mixed implementation is allowed only when evidence shows a single
  implementation route has a material gap.
- One primary package and at most one evidence-triggered backup may enter POC;
  no candidate type or adapter may leak through the `App*` public surface.
- Forui 0.25.0 was the implemented package candidate and `shadcn_ui` 0.56.1
  remained the evidence-only backup. Neither is a G3 production dependency.

## Blocking decisions

- Final Admin9 brand direction and final approval still belong to the user.
- Starter adoption is blocked until the user accepts the Demo on Android and
  iOS real devices.

These do not block reversible reference work, candidate research, isolated
POCs, or Demo implementation.

## Next

1. Commit one fixed G3 SHA with the implementation and local evidence.
2. Run exactly three independent G3 reviews for product/brand, Flutter
   architecture and QA/accessibility. Fix only direct P0/P1 regressions.
3. After all three return Go, hand the Android/iOS builds and shared checklist
   to the user for real-device acceptance.
4. Stop before Starter migration, versioning, release, push or publication.
