# Admin9 UI Unification G1 Verification

Date: 2026-08-22
Gate: paired references and ownership matrix
Result before independent review: Ready for review

## Fixed inputs

- Confirmed principle: 统一品牌外观、统一业务体验、保留系统交互差异。
- User evidence: current Android/iOS Demo looks like two products on real
  devices.
- Repository baseline: `b28689a89c8b5ea3a07441f28748eb6dcec00493`.
- Current architecture: one `MaterialApp`, one route tree, and `App*` as the
  business-to-implementation boundary.

## Delivered evidence

- [Decision baseline](admin9-ui-decision-baseline.md)
- [Ownership matrix](admin9-ui-ownership-matrix.md)
- [Paired-reference definition](admin9-ui-paired-references.md)
- Four Android/iOS generated pairs under `evidence/visual-references/`:
  login/registration, main navigation/list, settings form, dialog/feedback.
- Generated SVG source, PNG review assets, SHA-256 manifest, generator, and
  verifier.

## Checks

| Check | Result | Meaning |
| --- | --- | --- |
| `flutter analyze` | Pass, no issues | Existing code baseline is statically clean |
| `flutter test --exclude-tags golden` | Pass, 164 tests | Existing behavior is stable; does not prove visual unity |
| Generator syntax | Pass | Reference generator and verifier parse on local Node.js |
| Asset verification | Pass, 16 assets | SVG/PNG dimensions, required labels, and recorded hashes match |
| Normalized paired structure | Pass, four scenarios | After removing only approved platform annotations, Android/iOS SVG sources are identical |
| 2400x1200 visual inspection | Pass, eight boards | No observed crop, overlap, missing control, or platform color swap |
| `git diff --check` | Pass on the staged G1 scope | Whitespace integrity |

## What G1 proves

- The current broad Material/Cupertino visible mapping is not the only viable
  interpretation of platform adaptation.
- A common Admin9 visible hierarchy can be specified while separately keeping
  platform behavior gates.
- The next POC can compare implementations against the same four scenarios and
  state matrix without exposing implementation types to business code.

## What G1 does not prove

- Final brand approval or frozen visual Tokens.
- Self-built, third-party, or mixed implementation superiority.
- Flutter runtime rendering, performance, focus behavior, keyboard/autofill,
  accessibility service behavior, system gestures, or safe-area behavior.
- Android/iOS real-device acceptance of the new direction.
- Starter migration readiness.

## G1 review rule

Independent reviewers inspect only the fixed commit containing this report,
the target/decision documents, generated reference assets, stage diff, and the
checks above. Each returns Go, Revise, or Block with evidence locations and
required work before POC selection.
