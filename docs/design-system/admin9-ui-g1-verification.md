# Admin9 UI Unification G1 Verification

Date: 2026-08-23
Gate: bounded closure of confirmed G1 P1 findings
Result before final bounded re-review: Ready for fixed-commit review

## Fixed inputs

- Confirmed principle: 统一品牌外观、统一业务体验、保留系统交互差异。
- User evidence: current Android/iOS Demo looks like two products on real
  devices.
- Repository baseline: `b28689a89c8b5ea3a07441f28748eb6dcec00493`.
- Initial G1 commit: `db1af3c`.
- Re-review input: the fixed commit containing this report; supervisors receive
  its exact SHA and do not inspect the changing working tree.
- Current architecture: one `MaterialApp`, one route tree, and `App*` as the
  business-to-implementation boundary.

## Delivered evidence

- [Decision baseline](admin9-ui-decision-baseline.md)
- [Ownership matrix](admin9-ui-ownership-matrix.md)
- [Paired-reference definition](admin9-ui-paired-references.md)
- [Stage gates](admin9-ui-stage-gates.md)
- Four Android/iOS generated pairs under `evidence/visual-references/`:
  login/registration, main navigation/list, settings form, dialog/feedback.
- Generated SVG source, PNG review assets, SHA-256 manifest, generator, and
  verifier.
- Candidate boundary policy, repository validator, one positive fixture, and
  22 exact negative fixtures.

## First-review revision closure

| Required correction | Closure evidence |
| --- | --- |
| Remove static-state overclaiming | Paired-reference matrix now says exactly which board shows each state and which runtime states remain unproved |
| Add missing menu, danger, disabled, focus, pressed, progress, empty/error, and save-error states | Generator, required per-scenario labels, regenerated assets, and current manifest |
| Treat old implementation as control | Decision baseline separates control, first-party candidate, third-party candidate, and conditional mixed route |
| Make `App*` leakage executable | Candidate policy and validator cover imports, exports, public vendor/callback/style types, context extensions, wrapper types, and root Theme imports |
| Keep capabilities outside `App*` | Decision baseline and ownership matrix assign permission/share/picker/keyboard/autofill/system accessibility to capability/service or navigation layers |
| Define staged POC/Demo/device gates | Stage-gate contract defines owners, P0/P1, resource limit, elimination, removal, entry, exit, and stop rules |
| Unify accessible content/count/timing/focus | Decision baseline freezes one visible message, once after visibility, no rebuild repeat, and no focus movement; OS delivery remains adaptive |
| Bind every candidate to one reference commit | Stage-gate and paired-reference protocols invalidate mixed-SHA evidence and require full-round reruns |
| Scope old test evidence correctly | Only tests that perform Golden comparisons carry the `golden` tag; this report separates 145 non-Golden old-contract tests from 19 existing v1 Golden tests, and neither proves a unified candidate |

## Fixed-commit review at `37b0899` revision closure

| Required correction | Closure evidence |
| --- | --- |
| Remove Auth large-text overlap | Regenerated Auth boards keep the long errors, action, secondary action, and unavailable-service notice visibly separated |
| Prove Account long Chinese and list recovery states | The third Account panel now shows large-text Chinese reflow and a wrapped value; the fourth shows both empty and recoverable-error states |
| Complete required-state labels and run the visual gate in CI | The verifier requires the full scenario label set; CI syntax-checks both scripts and validates all 16 committed assets |
| Limit platform-difference normalization | Only `<text data-platform-difference>` nodes are normalized; arbitrary Android/iOS text, glyphs, and copy remain comparison evidence |
| Follow the complete public export surface | The candidate gate traverses nested exports and associated parts from `lib/admin9_ui.dart` |
| Follow every relevant dependency edge | Import, export, part, and conditional URI edges participate in adapter and root Theme/app-host reachability checks |
| Cover public declaration shapes | Candidate signatures cover classes, enums, mixins, extension types, functions, extensions, typedefs, top-level variables, fields, methods, and constructors |
| Correct Golden classification and CI selection | Nineteen comparison tests are individually tagged; two ordinary layout/semantics stress tests remain in the 145-test default suite |

## Fixed-commit review at `6c30ac4` revision closure

| Confirmed P1 | Closure evidence |
| --- | --- |
| Legal host/barrel topology was rejected | App host and root Theme policies are distinct; the positive fixture now follows `MaterialApp host -> admin9_ui.dart -> App* -> private adapter`, while direct host and direct/indirect/re-exported root Theme paths remain negative |
| Unregistered dependencies were fail-open | Structured `pubspec.yaml` parsing classifies every direct non-SDK dependency in exactly one of `baselinePackages` or `candidatePackages`, checks policy entries back against the manifest, and includes an unregistered-package negative fixture |
| Inferred public API could evade source-signature checks | Public getters, methods, functions, variables, and fields in adapters and adapter-dependent exported `App*` libraries and parts require explicit source types; direct and `part` getter-based inferred-leak fixtures are rejected without relying on the disproved `dynamic` claim |
| Pressed reference PNG rendered pure black | The generator now emits `fill="#000000" fill-opacity="0.1"`; the verifier rejects the old 8-digit SVG fill, regenerated feedback PNGs show a darkened blue state layer, and all eight boards were visually rechecked |
| Visual calibration document was stale | Page-state descriptions now match the four current variants; the contrast table contains only actual generator foreground/background combinations and is mechanically recomputed from the exported generator palette |

## Checks

| Check | Result | Meaning |
| --- | --- | --- |
| `flutter analyze` | Pass, no issues on Flutter 3.44.1 / Dart 3.12.1 | Existing source plus the new validator is statically clean; negative candidate fixtures are parsed only by their dedicated gate |
| `flutter test --exclude-tags golden` | Pass, 145 tests | Existing non-Golden old-contract behavior is stable; does not prove visual unity |
| `flutter test --tags golden test/design_system_phase_5_golden_test.dart` | Pass, 19 tests | Existing v1 Flutter rendering remains stable; there is no G1 unified candidate rendering to prove |
| Generator syntax | Pass | Reference generator and verifier parse on local Node.js |
| Asset verification | Pass, 16 assets | SVG/PNG dimensions, required state labels, pressed-overlay syntax, recorded hashes, and generated contrast table match |
| Normalized paired structure | Pass, four scenarios | After removing only approved platform annotations, Android/iOS SVG sources are identical |
| 2400x1200 visual inspection | Pass, all eight regenerated boards | No observed crop, overlap, missing required state, platform color swap, or black pressed-state block |
| Existing import/public API/Gallery gates | Pass | Existing architecture gates remain intact |
| UI candidate boundary fixtures | Pass, one positive and 22 negative | Legal host/barrel encapsulation passes; imports/exports/parts, conditional URIs, inferred/explicit public types, unregistered dependencies, adapters, root Theme, and direct app-host leakage fail before POC |
| UI candidate repository scan | Pass with no configured candidate package | All current direct non-SDK dependencies match the baseline; G2 must classify exact candidate packages before code |
| Documentation verification | Pass, 63 Markdown files | Local links, anchors, tables, fences, and whitespace are valid |
| Dart formatting and `git diff --check` | Pass | Source formatting and whitespace integrity |

## What G1 proves

- The current broad Material/Cupertino visible mapping is not the only viable
  interpretation of platform adaptation.
- A common Admin9 visible hierarchy can be specified while separately keeping
  platform behavior gates.
- The next POC has a fixed comparison protocol and an executable mechanism that
  prevents configured candidate imports/types/adapters from crossing the
  approved boundary.

## What G1 does not prove

- Final brand approval or frozen visual Tokens.
- Self-built, third-party, or mixed implementation superiority.
- Unified-candidate Flutter runtime rendering, performance, focus behavior, keyboard/autofill,
  accessibility service behavior, system gestures, or safe-area behavior.
- Android/iOS real-device acceptance of the new direction.
- Starter migration readiness.

## G1 review rule

The final bounded review inspects only closure of the confirmed `6c30ac4` P1
items above and direct P0/P1 regressions introduced by that closure. P2 findings
are recorded for G2; reviewers do not reopen settled product direction, add new
G1 scenarios, or expand the G1 evidence matrix.
