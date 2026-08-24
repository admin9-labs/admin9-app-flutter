# Historical Records

This is the only history index for Admin9 App Starter. Historical names, status
words, dates, commands, hashes, and findings describe their original snapshots;
they are not current specifications, current compatibility claims, or rules for
independent forks.

Current authority is limited to [Architecture](architecture/README.md),
[Design System](design-system/README.md), [Validation](validation/README.md),
and [Delivery](delivery/README.md). License and trademark terms remain in the
root `LICENSE` and `TRADEMARKS.md` files.

## Recorded decisions

The cleanup merges the former phase and gate documents without changing their
recorded outcomes:

| Historical record | Original result retained |
| --- | --- |
| Initial UI discovery | `Revise`; the initial API draft was insufficient |
| Product/audit baseline | `Go`, limited to the next design-calibration step |
| Non-visual contract boundary | `Go` |
| Foundation and theme implementation | `Go` |
| Platform shell and navigation | `Go` for its recorded next implementation step; device-only gates remained open |
| Settings and persistence | `Go` for its recorded next implementation step; device-only gates remained open |
| Forms and interactions | `Go` for its recorded next implementation step; physical-device gates remained open |
| Page migration and Goldens | `Go` for its recorded next implementation step; physical-device and human-accessibility gates remained open |
| Foundation delivery | `Go - representative P0/P1 gates pass`; explicitly not complete accessibility certification |
| Cross-platform decision/evidence gate | `Go` |
| Component candidate comparison | `Go`; first-party implementation selected and the package POC removed |
| Unified visible component implementation | `Go`; public `App*`, routes, business behavior, and platform responsibilities retained |
| Repeated Android/iOS simulator cold-launch smoke | `Pass` for two fixed-source rounds per platform |
| Full current physical-device and final brand acceptance | `Pending` / `Unknown`; never upgraded by this cleanup |

The immutable `design-system-v1.0.0` through `design-system-v1.0.3` tags and Git
history retain the exact source documents and raw artifacts when forensic detail
is needed. The `1.0.0` through `1.0.3` sections of
[the Design System changelog](design-system/CHANGELOG.md) remain the release
summary.

The deliberately retained raw subset and its complete integrity manifest are
indexed under [Historical Device Evidence](history/device-evidence/README.md).

## Failure facts retained

- The initial contract draft could not honestly express the required static
  command entry points and was `Revise`, not `Go`.
- An early Android three-button smoke was interrupted and was not a pass; a
  later clean run supplied the accepted result.
- A Switch Access root-scan attempt remained `Unknown`; enabled service state
  did not prove individual Flutter-control operation.
- Several captures labelled as fixed or final did not show the claimed
  navigation mode and were rejected; later explicitly bound evidence replaced
  them.
- An early Android simulator crash used a local shim and was rejected as proof
  about the normal AVD path. Later normal-path repeated smoke passed, but did
  not upgrade physical-device, reader, real-IME, or brand results.
- A signed IPA, release APK, Golden, or no-codesign build never counted as
  installation, interaction, assistive-technology, or human acceptance.

## Cleanup trace

| Removed or merged collection | Consumer finding | Long-term replacement |
| --- | --- | --- |
| Phase implementation plan and per-phase reports | no runtime or CI consumer; current modules already implement the result | current architecture, Design System, tests, changelog, immutable Git history |
| G1/G2/G3 decision, screening, verification, and stage documents | only cross-linked by the temporary goal and Design System index | current Design System rules, validation, delivery boundary, and this result matrix |
| Duplicate calibration wireframes and audit screenshots | superseded by generated visual references and production Goldens | `docs/design-system/evidence/visual-references/` and `test/goldens/` |
| Intermediate build/install logs and repeated screenshots | no executable consumer; later fixed-source or final evidence existed | retained bounded evidence summaries plus immutable Git history |
| Drifted `build/ios/iphoneos/Runner.app` references | mutable build output did not match the protected IPA | IPA hash and its own `Payload/Runner.app`, documented in Delivery |

Deleting these working-tree copies does not rewrite Git history or move any Tag.
No historical `Pass`, `Fail`, `Pending`, or `Unknown` is promoted by absence of a
raw file in the current tree.
