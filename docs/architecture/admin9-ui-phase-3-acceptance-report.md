# Admin9 UI Phase 3 Acceptance Report

> **Historical record:** This report preserves its Foundation-era findings. It
> is not a current Starter specification or certification of any fork.

Status: Go for Phase 3 implementation; Phase 6 device gates remain open

Date: 2026-07-30

## Scope

Phase 3 implements `AppListTile`, `AppSection`, `AppSwitch`, and `AppSingleChoiceList<T>`, then migrates Settings as the first end-to-end Design System pilot. Theme and App font scale use dedicated single-choice pages; boolean preferences update immediately. All values continue through the existing local `AppearanceController` and `SharedPreferences`; no backend, session, navigation destination, or business result changed.

## Implemented contracts

- Android: `ListTile`, unframed section, `SwitchListTile`, and `RadioGroup<T> + RadioListTile<T>`.
- iOS: `CupertinoListTile`, `CupertinoListSection.insetGrouped`, `CupertinoSwitch`, and checkmark single-choice rows.
- Core owns disclosure, platform-correct checked/selected/toggled semantics, controlled values, minimum row hit bounds, and pressure reflow.
- The canonical A-L matrix is represented exactly, including App 1.24 with synthetic system 2.0/3.0 stress.
- Preference writes are serialized with per-key generations, preserve last-write-wins order, expose failures, and keep a persistent recovery action on the parent Settings page after a choice route is closed.
- The frozen `MaterialPageRoute` plus default `PageTransitionsTheme` route contract remains unchanged.
- iOS pressure rows retain Cupertino controls and feedback while replacing the
  native tile's forced single-line title with content-driven wrapping.

## Review closure

| Severity | Finding | Resolution |
| --- | --- | --- |
| P1 | route factory selected route classes by platform | restored the frozen `MaterialPageRoute` contract |
| P1 | Settings violated the AST show-list and retained stale baseline debt | explicit non-interactive imports and exact baseline update; validator passes |
| P1 | iOS choice/list selected state lacked Semantics | explicit selected/enabled state on both platforms plus Widget assertions |
| P1 | A-L rows diverged from the canonical matrix | replaced all row parameters and added component geometry/choice coverage |
| P1 | host reconstruction was mislabeled as process restart | renamed the automated claim and added normal-App Android force-stop/restart evidence |
| P2 | rapid writes and failed persistence were undefined | serialized writes, observable failure state, persistent retry feedback, and tests |
| P2 | const constructor could not evaluate its list-length assertion | retained the const constructor and moved the defensive assertion to build time |
| P2 | existing foundation smoke used retired Settings controls | migrated the smoke flow; Android API 36 passes |
| P1 | iOS maximum system text plus App 1.24 ellipsized primary labels | pressure rows now wrap labels/current values; focused Widget assertions and iOS 26.5 runtime screenshots pass |
| P1 | Android single-choice rows exposed generic selected state instead of radio checked state | Android rows now expose one checked, mutually exclusive Semantics node; iOS retains selected state; A-L assertions distinguish both contracts |
| P2 | a failed persistence retry dismissed its only recovery action | repeated failure republishes the persistent retry feedback; Widget coverage proves failure-failure-success lifecycle |
| P2 | process-restart hierarchy hashes lacked repository inputs | both raw before/after XML hierarchy files are indexed with matching SHA-256 |
| P1 | an old retry closure could overwrite a newer selection | per-key write generations invalidate stale failures and retries; the race is covered directly |
| P2 | a choice-page failure could complete after that route was closed | the parent Settings page owns a generic, persistent “重试保存设置” action; delayed-failure route-pop coverage passes |
| P2 | A-L single-choice fixtures used only short labels | every A-L row now includes a long Chinese selected option and asserts content growth, bounds, platform state semantics, and reachability |

## Automated and device evidence

Final command results are recorded after the closing mechanical run. Current focused evidence:

- Phase 3 Widget suite: pass.
- `flutter analyze`: pass.
- Phase 0D AST import boundary: pass.
- Android API 36 Phase 3 integration task: pass.
- iOS 26.5 simulator Phase 3 integration task: pass, including the Cupertino theme-transition regression.
- Android API 36 normal debug App force-stop/restart persistence: pass; see [evidence](evidence/admin9-ui-phase-3/android-process-restart-persistence.md).
- Android API 36 TalkBack plus external-keyboard focus/navigation: pass for the
  available Settings task and hierarchy exposure.
- iOS 26.5 simulator maximum content size plus Increase Contrast and App 1.24:
  pass for scrolling, reachability, wrapping, and checked/current-value state.

Closing mechanical results:

| Command | Result |
| --- | --- |
| `flutter analyze` | Pass, no issues |
| `flutter test -r expanded` | Pass, 81 tests |
| `flutter test integration_test/phase_3_settings_test.dart -d emulator-5554 -r expanded` | Pass, Android API 36 |
| `flutter test integration_test/phase_3_settings_test.dart -d C10E0968-4695-4C02-BC55-8C322531239A -r expanded` | Pass, iOS 26.5 simulator |
| `flutter test integration_test/foundation_smoke_test.dart -d emulator-5554 -r expanded` | Pass |
| contract and implementation probe analysis | Pass |
| manifest fixtures | Pass, 1 valid and 12 rejected |
| import-boundary fixtures and repository gate | Pass, 3 positive and 19 negative |
| Brand, Gallery, rule-link, and documentation validators | Pass |
| `git diff --check` | Pass |

See the [device evidence index](evidence/admin9-ui-phase-3/README.md) for exact
claims, hashes, and rejected evidence.

## Device gates

The execution authorization for this Goal explicitly allows all non-device work
to continue and requires unavailable physical-device gates to block only final
Phase 6 acceptance. Accordingly, this report may authorize the Phase 3 code
commit after independent review and mechanical gates pass, but it does not mark
the following hard evidence as complete:

- Android physical device, Switch Access individual-control scanning, 200%
  system text, and exact TalkBack spoken-output uniqueness.
- iPhone physical device, VoiceOver, Switch Control, Bold Text, Reduce Motion,
  maximum Dynamic Type, and spoken-output uniqueness.

These are carried unchanged into Phase 6 and must pass before the final tag.

## Final decision

Independent Flutter architecture, Android Material 3, iOS HIG, and
accessibility reviews were iterated until every Phase 3 P0-P2 finding was
closed. The final post-fix architecture re-review returned `Go`; the complete
mechanical gate above is green. Phase 3 may be committed and Phase 4 may begin.
