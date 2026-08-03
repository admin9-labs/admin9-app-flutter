# Admin9 Design System v1.0 Acceptance Report

> **Historical record:** This report preserves its Foundation-era findings. It
> is not a current Starter specification or certification of any fork.

> Decision: Go
> Date: 2026-07-29
> Scope: specification, evidence, downstream plan, and non-runtime validators only

## 1. Accepted baseline

Admin9 Design System v1.0.0 is the single normative source for Admin9 Core, Brand Theme, and Business Layer. The carrying commit and annotated local tag `design-system-v1.0.0` identify this release; Design System, Foundation, App, and customer-business versions remain independent. The downstream implementation plan is v1.2 and cannot override this directory.

The baseline freezes semantic color/type/spacing/shape/motion roles, Android Material 3 and iOS Cupertino mappings, consumer API shapes, controller result semantics, page patterns, the A-L automated matrix, derived-project provenance, accessibility gates, deviation governance, and device Unknown handling. It does not claim a runtime implementation.

## 2. Closed P0-P2

No P0 or No-Go remained. Independent review findings were closed as follows:

- the manifest now has a complete schema, approved compatibility registry, App identity, ownership/paths, canonical Brand evidence, asset hashes, deviations, and provenance;
- one valid and eleven focused invalid fixtures prove missing source, version/path, asset traversal, unauthorized override, unknown field, unapproved compatibility, Brand drift, expired/invalid/reversed dates, invalid UTC provenance, and unknown rule rejection;
- every invalid fixture declares its expected error evidence, and the runner fails if any intended rejection reason disappears;
- `AppActionMenu`, `AppProgressIndicator`, `AppSingleChoiceList`, selected navigation icon roles, `AppPageNavigationMode`, `AppTone`, complete semantic token facade, and controller result contracts are present in specification, probe, plan, Gallery/test requirements, and rule associations;
- the declaration probe is correctly scoped as a non-instantiable consumer-shape proof; the public export matrix makes Dialog/ActionMenu/Feedback presentation Widgets Core-internal and exposes one controller entry;
- `AppSelect` commits only a non-null value, Dialog variants enforce action-count invariants, and modal dismissal restores focus;
- AppFeedback persistence is exactly action-present or `MediaQuery.accessibleNavigationOf(context)`; `semanticsEnabled` is not used as a reader proxy;
- every implemented Core component and reference fixture runs the same A-L matrix;
- iOS edge-back and Android predictive-back system phases are manual device hard gates, while integration tests prove only application state;
- the six boards use one visual direction, same light/dark baseline state, exact `1.24` semantic sizing including bottom navigation, 6/8 radii, platform-specific navigation/selection/switch behavior, and honest design-reference labels;
- Core business route composition moves to the App host in Phase 0D and is guarded by future analyzer-AST tests.
- all 22 stable rule IDs, including Android/iOS accessibility rules, resolve to one exact normative anchor and machine/test association.

## 3. Executable evidence

Run from repository root:

```bash
dart format --output=none --set-exit-if-changed tool
dart run tool/design_system/validate_foundation_manifest.dart --fixtures
flutter analyze tool/design_system/design_system_contract_probe.dart
dart run tool/design_system/verify_rule_links.dart
node tool/design_system/verify_documentation.mjs
node docs/design-system/evidence/sources/verify_visual_references.mjs docs/design-system/evidence/visual-references
flutter analyze
flutter test -r expanded
git diff --check
```

Results on 2026-07-29: Flutter 3.44.1 and Dart 3.12.1 confirmed; formatter clean; manifest contract Pass with one valid/eleven reason-specific rejected invalid cases; declaration probe Pass; 22 stable rule links Pass; documentation links/anchors/fences/tables/whitespace Pass; 12 visual assets Pass at 2400x1200 with recorded SHA-256; repository analyze Pass; all 5 Flutter tests Pass; diff check Pass.

The visual source and reproduction command are in [Visual calibration](evidence/admin9-design-system-v1-visual-calibration.md). The `1.24` board proves standard system text multiplied exactly by `1.24` and content-driven field/button/list/navigation growth. It does not substitute for nonlinear maximum-size runtime layout or device rendering.

## 4. Scope and integrity

This release changes only `docs/design-system/**`, the downstream implementation plan, and `tool/design_system/**`. It does not change `lib/`, `test/`, `integration_test/`, `pubspec*`, `android/`, or `ios/`; it does not implement UI, themes, navigation, business behavior, Gallery runtime code, or migrate a page. No App package was built or installed. The release is committed and tagged locally only; this repository has no configured remote and nothing is pushed.

## 5. Remaining Unknowns

The following are deliberately deferred to Phase 0D, Phase 1, or device acceptance: concrete Widget instantiation and lookup; AST import enforcement; runtime token resolution and Brand font rendering; actual bounds, Semantics, focus, IME/autofill, Gallery release exclusion, Goldens, and nonlinear maximum text; Android edge-to-edge and predictive-back phases; iOS edge-back; TalkBack, VoiceOver, Switch Access/Control, hardware keyboard, high contrast, grayscale, Bold Text, and reduced-motion device behavior. Each is already assigned a fixed gate and does not reopen the v1.0 product decision.

The current implementation estimate is 31-47 person-days across Phase 0D through Phase 6, including validators/probes, Gallery, component implementation, migration, automated coverage, and dual-platform device acceptance. Device availability and the first real Brand override remain schedule risks rather than specification blockers.

## 6. Final judgment

**Go**: v1.0 is internally consistent and executable as a specification baseline for the current Foundation and future derived apps. This judgment authorizes the local specification commit and tag only. Runtime implementation still requires the separately scoped Phase 0D/Phase 1 authorization and gates.
