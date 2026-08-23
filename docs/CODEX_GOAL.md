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
`06a398a747178e1aaed4933f96806ced3c498ad8`. The G3 implementation is closed Go
at `d6adb419dfa6935868b37621fc530e942fd13988` after the product/brand,
Flutter architecture and QA/accessibility reviewers independently found no
remaining direct P0/P1. The later delivery gate has been reopened because
interactive Android/iOS simulator acceptance was not previously performed.
The iOS run is a partial Pass, but Android Emulator boot is blocked by the
current Codex process environment. Physical-device handoff is not open.

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
- Closed all three G3 supervision findings in `d6adb41`: shared centered page
  titles, executable feedback semantics and complete large-field labels.
- Received final Go from the product/brand, Flutter architecture and
  QA/accessibility reviewers on the same G3 revision.
- Prepared the exact Android Release APK and a development-signed iOS IPA for
  physical-device acceptance, together with one shared, fillable checklist.
- Interactively exercised the installed normal Demo on iPhone 17e / iOS 26.5
  Simulator: login/registration, main navigation/account, settings, software
  keyboard/focus, unavailable feedback, edge-back, safe areas, dark/large text,
  contrast preferences and force-quit cold launch produced 13 labeled captures.
- Attempted the Pixel 7 API 34 and API 36 arm64 AVDs through graphical,
  headless, temporary-data and software-acceleration paths. QEMU consistently
  failed before Android boot with a sandbox-coalition `SIGILL`; no Android
  product result is claimed.

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
- 2026-08-23: the G3 supervision revision passed `flutter analyze`, all 146
  non-Golden regressions, 23 production Goldens in compare mode, all
  configuration/import/candidate/Gallery/visual/documentation gates, Android
  Release APK 51,005,113 bytes and iOS no-codesign Release app 17.1 MB.
- 2026-08-23: final Android/iOS asset scans contain no Forui, Inter or Lucide
  candidate artifacts. Manual review of all 23 production Goldens found no
  incoherent overlap or cross-platform component-family drift.
- 2026-08-23: the development-signed iOS export passed strict code-sign
  verification and IPA archive integrity. It targets
  `com.admin9.app.foundation`, contains the connected iPhone UDID in its
  provisioning profile and expires on 2027-06-05. This proves packaging and
  signing only, not installation or real-device acceptance.
- 2026-08-23: iOS Simulator interaction passed the normal Demo scenarios listed
  in `docs/design-system/admin9-ui-g3-simulator-acceptance.md`. The tested
  installed App binary matches the existing workspace simulator artifact, but
  installing the separately rebuilt current-source Dart bundle was blocked;
  exact source-to-installed binding remains Unknown.
- 2026-08-23: Android Emulator 36.6.11 failed before boot with
  `EXC_BAD_INSTRUCTION` / `SIGILL` at `init_cache_info` inside the
  `com.openai.codex` process coalition. This is a real environment Block and is
  not converted into a product Fail or Pass.

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
- Dual-simulator acceptance is blocked until an official Android Emulator can
  run outside the current Codex process sandbox and the exact current-source
  builds can be installed on both simulators.
- Starter adoption is blocked until the user accepts the Demo on Android and
  iOS real devices.

These do not block reversible reference work, candidate research, isolated
POCs, or Demo implementation.

## Next

1. Resume from the Block conditions in
   `docs/design-system/admin9-ui-g3-simulator-acceptance.md` and complete one
   fixed-SHA Android/iOS simulator comparison.
2. After any direct P0/P1 loop, run exactly three bounded supplemental G3
   reviews on the fixed simulator evidence and direct regressions.
3. Only after all three reviewers return Go, install the exact APK and
   development-signed IPA for user-operated physical-device acceptance.
4. Continue only after the user explicitly accepts or rejects the Admin9 brand
   direction and both real-device experiences. Do not migrate Starter, assign
   a Design System version, push, publish or release before that acceptance.
