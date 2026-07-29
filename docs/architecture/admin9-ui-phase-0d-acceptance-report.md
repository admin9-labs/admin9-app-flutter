# Admin9 UI Phase 0D Acceptance Report

> Date: 2026-07-29
> Design System: v1.0.1
> Input baseline: `design-system-v1.0.0` / `67c3b12a71fbb0bbed9621e4cd5c7a0a3775cff0`
> Implementation commit: `1c91f21eaee511f081d5addbe765151f27a53fb9`
> Decision: Go

## 1. Accepted Boundary

Phase 0D implements only honest non-visual contracts and repository mechanisms. It does not implement component appearance, platform presenters, page migration, theme resolution, Gallery pages, or device behavior. Concrete `App*` Widgets are instantiated, tested, and exported in their assigned Phase 1-4. This v1.0.1 clarification changes no frozen token, consumer constructor, platform mapping, or product decision.

## 2. Delivered

- `lib/admin9_ui.dart` is a non-empty public barrel for real enums, immutable value objects, controller interfaces, and lookup scopes.
- `AppDesignScope`, `AppFeedbackHost`, and `AppInteractionHost` are real `InheritedWidget` mechanisms. Missing host configuration fails with a named `FlutterError`; no presenter is faked.
- Brand ownership is under `lib/app/brand/`. Its Dart input exposes only manifest-tracked primary/secondary light-dark values, font, radius, and assets; Core will derive semantic foregrounds in Phase 1.
- Business route names are isolated in `lib/app/app_route_names.dart`; only `lib/app/app_routes.dart` imports and assembles feature pages. Core no longer imports Business.
- The analyzer-AST boundary tool has exact positive/negative fixtures, an exact legacy-debt baseline, a non-interactive declaration allowlist, and separate `phase0d` and `final` enforcement modes.
- The Gallery registry is guarded by `kReleaseMode`, stays out of the public barrel, and has no page implementation in this phase.
- Manifest schema, fixtures, compatibility tuple, README, Changelog, component contract, derived-project contract, quality rules, and implementation plan use v1.0.1 consistently.

## 3. Review Closure

| Finding | Severity | Resolution |
| --- | --- | --- |
| Core assembled Business routes | P1 | moved assembler to App host; deleted Core route file; AST gate proves the boundary |
| feature imported route assembler and formed a cycle | P1 | split route-name contract; negative fixture rejects feature-to-assembler imports |
| controller interfaces had no lookup mechanism | P1 | added separate non-visual feedback and interaction hosts plus lookup tests/probe |
| Brand runtime fields exceeded manifest hash | P1 | removed untracked inputs; added validated manifest-to-Dart generator plus exact Brand/App-identity AST comparison and extra-field/value-drift fixtures |
| AST gate was only a URI blacklist | P1 | added exact debt baseline, full Business (`features` plus `shared`) coverage, App allowlist, bare-export-only public barrel, declaration `show` allowlist, private-source/re-export/Core/route/cross-feature checks and 19 exact negative fixtures |
| v1.0.1 chain was partial | P1 | synchronized schema, fixtures, README, Changelog and downstream plan; the compatibility tuple is finalized with the real implementation SHA in a separate provenance commit because a commit cannot contain its own SHA |
| full analyzer reported stale import/deprecation issues | P2 | removed redundant import, updated analyzer API use, and kept invalid fixtures analyzer-clean |

No P0-P2 remains open for the Phase 0D scope.

## 4. Mechanical Evidence

| Command | Result |
| --- | --- |
| `flutter analyze` | Pass |
| `flutter test -r expanded` | Pass; 10 tests |
| `flutter analyze tool/design_system/design_system_contract_probe.dart tool/design_system/design_system_implementation_probe.dart` | Pass |
| `dart run tool/design_system/validate_foundation_manifest.dart --fixtures` | Pass; 1 valid and 11 rejected fixtures |
| `dart run tool/design_system/verify_import_boundaries.dart --fixtures` | Pass; 3 positive and 19 exact negative fixtures |
| `dart run tool/design_system/verify_import_boundaries.dart --phase=0d` | Pass |
| `dart run tool/design_system/verify_brand_contract.dart` | Pass |
| `dart run tool/design_system/verify_brand_contract.dart --fixtures` | Pass; exact valid output, extra field and value drift |
| `dart run tool/design_system/generate_brand_entry.dart docs/design-system/fixtures/foundation-manifest/valid.yaml <temporary-app-dir>` followed by the three-path Brand verifier | Pass; output regenerated from the validated manifest and matched exactly |
| `dart run tool/design_system/verify_gallery_boundary.dart` | Pass |
| `flutter test --dart-define=dart.vm.product=true test/design_system_phase_0d_test.dart -r expanded` | Pass; 5 focused tests including the product-mode registry branch |
| `dart run tool/design_system/verify_rule_links.dart` | Pass; 22 stable rules |
| `node tool/design_system/verify_documentation.mjs` | Pass |
| `git diff --check` | Pass |

The `--phase=final` import gate is intentionally not a Phase 0D gate: its exact legacy Material/Core baseline must reach zero during migration and becomes mandatory in Phase 5.

## 5. Unknown Assigned Forward

- Theme/token rendering, Cupertino/Material component mapping, bounds, Semantics, focus, localization, system preference merging, and actual Gallery reachability start in Phase 1.
- Dialog, action-menu, feedback, and other visual presenters remain unimplemented until their assigned phases.
- Android/iOS device visuals, readers, switch access/control, IME/autofill, edge-to-edge, predictive back, iOS edge back, release install, and system accessibility behavior remain Unknown and are not claimed by Phase 0D.
- The compatibility registry records specification compatibility with the source baseline. Runtime compatibility cannot be declared before visual implementation and the required device gates.

## 6. Boundary Check

No page was visually migrated. Theme, navigation results, privacy behavior, authentication validation, settings persistence, session truth, platform projects, and runtime dependencies are unchanged. The only added package is the development-only `analyzer` used by executable repository gates. No remote exists and nothing was pushed.

**Go**: Phase 0D is complete. The implementation commit is created first; the compatibility registry and this report then record that immutable SHA in a provenance commit, and `design-system-v1.0.1` points to the provenance commit. Phase 1 begins only after those two focused local commits and the local tag exist.
