# Admin9 UI Phase 6 Acceptance Report

Status: Go - Phase 6 representative P0/P1 gates pass

Date: 2026-07-31

## Decision summary

Phase 0D through Phase 5 are complete and locally committed. Phase 6 automated,
release-build, Android API 30/API 34/API 36 application-state, API 36 light/dark
three-button system-icon, two-size iOS simulator, current-APK Xiaomi install/cold
launch and a representative Xiaomi TalkBack flow are substantially complete.
Acceptance now uses risk-tiered evidence: automation owns deterministic
component/state/Semantics/layout/business contracts, while humans sample only
actual reader output, system gestures, real IME behavior, safe areas and release
install/cold launch. P0/P1 remain hard gates; P2/P3 repetition is tracked backlog.

Phase 6 is **Go**. The Xiaomi privacy-announcement and real-IME P1 gates pass
through the approved composite evidence chain. API 34 and API 36 native-mouse
predictive-back runs pass start/progress/cancel/complete, and the API 36
representative gesture/three-button edge-to-edge, cutout, safe-area and
IME-resize review passes. The final candidate iPhone is signed, installed,
cold-launched and bound to its running executable. Its representative
VoiceOver flow, selected-state announcement, real Next/Done path, App Extra
Large safe-area endpoint and edge-back cancellation/completion all pass by
human observation. No P0/P1 remains open. The named P2/P3 items stay tracked
backlog and are not relabeled as passed.

Severity is fixed by Design System v1.0.2: P0 is a crash, privacy bypass or
wholly inoperable critical flow; P1 is an unfinishable core task, focus trap or
permanent focus loss, undiscoverable critical state, system-return failure or
installation failure; P2 is a state discoverable after one extra gesture or
refocus, a delayed non-critical announcement, or unsampled alternative
assistive technology; P3 is reader wording/pause/repetition polish. P0/P1 block
release. P2/P3 require owner, trigger and review stage but are not called Pass.

## Phase 4 and Phase 5 control-line completion

The supervision boundary introduced for Phase 4 remains satisfied:

- Phase 4 implemented only the frozen form/action contracts and migrated the
  privacy, authentication, account, legal, About, and Contact flows. It did not
  add a locale system, backend, fabricated session, or new product capability.
- The guest, authenticated test boundary, validation, password visibility,
  keyboard, dialog, destructive action, unavailable-service, legal, and back
  flows completed cross-page regression before commit. Phase 4 passed 127
  automated tests and was committed as
  `534c06e2fe218434603f2856dedebd7d9462042e`.
- Phase 5 was limited to remaining migration, legacy cleanup, Gallery/Golden,
  public-export, and import-boundary closure. It did not redesign pages. Its
  final A-L page matrix and full suite passed 160 tests, and it was committed as
  `a31227b014ac5d5564735552c4e30851eca8707e`.
- No Phase 4 or Phase 5 P0-P2 finding remains open. Low-value visual polish is
  not being used to delay the user-flow or delivery gates.

## Closed Phase 6 implementation defects

API 36 release inspection exposed a P1 defect: without an explicit root system
UI style, three-button navigation could show light navigation icons against the
App's light bottom surface. The App host now supplies theme-aware status and
navigation icon brightness, transparent edge-to-edge colors and divider, and
navigation-bar contrast enforcement. The host test locks all of those fields in
light and dark modes.

The first files named `*-release-fixed.png` were reviewed and rejected because
both still showed a gesture handle. They remain only as provenance. The valid
post-fix chain reads `navigation_mode=0` with only the three-button overlay
enabled and visibly shows Back, Home, and Overview in both themes. The light
capture has dark icons; the dark capture has light icons. Exact hashes and the
release APK identity are in the [Phase 6 evidence
index](evidence/admin9-ui-phase-6/README.md). This closes the observed defect on
the API 36 AVD, not the physical Android, cutout, IME, or human-operated
system-UI gates.

Physical release launch then exposed a second P1: after an integration-test
build, Flutter 3.44.1 leaves an ignored `GeneratedPluginRegistrant.java` that
contains both `integration_test` and `shared_preferences_android`, while the
release classpath correctly excludes the dev plugin. Compiling that stale file
fails on `IntegrationTestPlugin`; merely excluding it builds an App with no
SharedPreferences registration. Release variants now exclude the stale Java
registrant and use a validated production-only registry. Debug/profile retain
Flutter automatic registration. The validator derives plugin name and class
from Flutter's generated registrant, filters dev plugins through
`.flutter-plugins-dependencies`, verifies the real import, declaration,
`plugins.add` helper, MainActivity branch and all `*ReleaseJavaWithJavac`
variants, and has negative self-tests for missing, wrong, duplicate and extra
registration. An API 34 run reproduced the integration-test pollution, then
rebuilt and cold-launched release with SharedPreferences available and no
`MissingPlugin` or `IntegrationTestPlugin` runtime entry.

The partial Xiaomi TalkBack walkthrough exposed a third P1 defect. Toggling
Grayscale off replaced the root focused subtree because `ColorFiltered` was
conditionally removed, so visual state changed while TalkBack focus moved to
Back without an immediate state announcement. The root `ColorFiltered` now
remains mounted; the off state uses the identity matrix and the on state uses
the grayscale matrix. Widget tests lock element identity and switch semantics.
The fix is implemented in the hash-bound Xiaomi APK described below. The
representative Settings switch traversal confirmed stable switch semantics;
repeating every switch transition is no longer a P0/P1 gate under the accepted
risk-tiered policy.

The current APK was subsequently installed on the upgraded API 30 Xiaomi and
its installed `base.apk` matched
`d6765958320a271272fe68437113e4db9e35537e348de884f3009d1f456f1326`.
Clear-data cold launch, privacy-gate traversal, Home/Mine navigation, a Settings
choice/switch sample, Register field order, password visibility state and empty
submit first-error focus were observed on that artifact. The detailed human
transcript records exact spoken output and explicitly records the one
`uiautomator`-caused TalkBack reset; no UI-hierarchy reader will be used again
during a physical reader session.

That clean run exposed a fourth P1: accepting privacy replaces the gate with
Home inside the same Flutter route, so TalkBack produced no transition speech;
the first exploratory swipe merely reached `Admin9`. `PrivacyGate` now emits one
supported post-frame `已进入首页` announcement only on the false-to-true
consent transition. Widget tests capture that event and prove an already-accepted
cold launch does not repeat it. The rebuilt 51,598,161-byte release APK and the
pulled Xiaomi `base.apk` both hash to
`fc43800cd9cd0553ef3b708a0b646f37b520e980b9bdfaba43c618e837b134aa`.
After clear-data cold launch, the human observer activated consent once and
TalkBack immediately spoke `已进入首页` without an exploratory swipe.
The P1 is closed on that hash-bound Android artifact and retained in the
approved composite chain for the additive live-region candidate.

Password visibility retained focus and changed its semantic label from
`显示密码` to `隐藏密码`, but activation itself produced only the
TalkBack click sound; the new label was spoken after refocus. This is P2 backlog:
the state remains discoverable and task completion was not blocked. It is not
claimed as an immediate-announcement pass.

## Automated and machine-readable gates

The following checks pass against the current Phase 6 working tree after the
system-UI, release-plugin and Grayscale focus fixes:

| Gate | Result |
| --- | --- |
| Flutter / Dart baseline | Flutter 3.44.1, Dart 3.12.1 |
| Dart format | Pass for `lib`, `test`, `integration_test`, and `tool` |
| Foundation manifest | Pass; one valid fixture accepted and 12 invalid fixtures rejected |
| Contract and implementation probes | Pass |
| Stable rule links | Pass; 22 rules |
| Design System documentation | Pass; 16 in-scope Markdown files |
| Visual-reference sources | Pass; 12 assets |
| Phase 6 evidence manifest | Pass; `SHA256SUMS` verifies 177 evidence files |
| Brand, Gallery, and import boundaries | Pass |
| Android release plugin validator and mutation self-test | Pass; production `shared_preferences_android` maps once to `SharedPreferencesPlugin` |
| `flutter analyze` | Pass; no issues |
| `flutter test -r expanded` | Pass; 162 tests in the final serial non-device rerun |
| `git diff --check` before this report | Pass |

These checks prove the frozen contracts, code-level accessibility semantics,
responsive matrices, import boundaries, and application state assertions. They
do not prove real spoken output, switch scanning, hardware keyboard behavior,
password-manager behavior, or operating-system gesture progress.

## Release-build evidence

| Artifact | Result | SHA-256 |
| --- | --- | --- |
| Android release APK, 51,598,161 bytes | Final candidate; local/installed hash match and cold launch pass; earlier human reader/IME facts are reused only through the documented composite policy | `aa2deda938ead8b1e9644c1210cc5c7a9b3b0c8356ccff43825c7744a2767995` |
| iOS signed `Runner.app/Runner`, 281,632 bytes | Final selected-state candidate; signature, install, unlocked cold launch, process binding and representative human gates pass | `89fc6f98e42089afa592e3f3ba0515fe2935e5744de83dbdd475372bf03db209` |
| Android privacy-announcement artifact, 51,598,161 bytes | Local/installed hash match and immediate TalkBack `已进入首页` P1 retest passed before the additive authentication live-region fix | `fc43800cd9cd0553ef3b708a0b646f37b520e980b9bdfaba43c618e837b134aa` |
| Earlier final-source iOS `Runner.app/Runner`, 281,632 bytes | Signature, install, unlocked cold launch and matching process path passed before the authentication live-region fix | `38ba0d654385fd3056591e20b46f436a7d644fff9c86af556ba1d468615ef3a1` |
| Earlier signed iOS `Runner.app` executable, 281,632 bytes | Signature, install, unlocked cold launch, and matching process path passed before the Grayscale focus fix | `3722ce6dc8bbec49570e73b17c055115c2373b1810aba46c85264afb10b064e3` |

A physical-iPhone delivery build at Phase 5 HEAD was signed with Team
`J25XZRW743`. Its executable, Info.plist, CodeResources, CDHash, and exact
`devicectl` install input/output remain in the [Phase 6 evidence
index](evidence/admin9-ui-phase-6/README.md) as provenance. Its locked cold
launch attempts are failure records, and that older installation is not the
accepted Phase 6 artifact because it predates the system-UI source fix.

That earlier delivery lane was closed before the Grayscale focus fix. Its signed
installation URL
`683C7D96-1548-42EA-A669-161976FC662F/Runner.app/`, unlocked cold launch, and
running executable PID `24765` match. Exact artifact and record hashes are in
the evidence index. Two later physical Foundation attempts against the final
source did not pass: one failed to start the Xcode debug session and the retry
did not discover the Dart VM Service after 75 seconds. Those failure records
are superseded for delivery by the final signed build: strict signature
verification, install, unlocked cold launch and running-process binding all
pass at installation URL
`5F4DB1C7-61E8-4931-98C8-D8E3BBBEE674/Runner.app/`. Human accessibility,
gesture, input and visual-flow gates are closed by the separate human record.

## Executed runtime evidence

| Target | Result proved | Evidence boundary |
| --- | --- | --- |
| Android emulator `emulator-5556`, Android 14 / API 34 | Foundation integration smoke passed before and after the system-UI fix with host GPU and gesture navigation | Historical supplementary lane |
| AVD `Admin9_API_34`, Android 14 / API 34 | Native macOS mouse predictive-back start/progress/cancel/complete passed; cancel preserved Theme and completion popped exactly once | Emulator evidence; Android 14+ physical hardware remains Unknown |
| AVD `Admin9_API_36`, Android 16 / API 36 | Current-source smoke, release light/dark three-button contrast, native-mouse predictive-back four stages, gesture/three-button system bars, cutout/safe-area and visible-IME form resize passed | Emulator evidence; rejected low-frame-rate videos are explicitly not used as four-stage proof |
| Xiaomi `M2007J22C`, Android 10 / API 29 | Current-worktree Foundation smoke passed; matching release APK installed and cold-launched; light, exact system 2.0 plus App Standard, real Sogou/MIUI security IME, Dark persistence with a raw force-stop/cold-start/process chain, and clean privacy-gate checks passed | Not current-version Android; no TalkBack/Switch Access, autofill/password manager, external keyboard, physical touch-target, complete human-flow, or predictive-back claim |
| Xiaomi `M2007J22C`, upgraded Android 11 / API 30 | Foundation smoke passed; final APK SHA matched installed `base.apk`; clear-data cold launch, Light/Dark, large-text plus App Extra Large, persistence, representative TalkBack navigation/settings/auth traversal, immediate `已进入首页` consent announcement, and real-IME Next/Done truthful-submit flow recorded | Android 14+ hardware stays separately Unknown; alternative IMEs, autofill/password managers and external keyboards remain P2 backlog |
| iPhone 17e simulator `C10E0968-4695-4C02-BC55-8C322531239A`, iOS 26.5, 390x844 logical | Post-system-UI-fix Foundation integration smoke passed with a preserved transcript | No human VoiceOver/Switch Control, visual system-bar, or physical edge-back claim |
| iPhone 17 Pro simulator `0E2E19C6-FD8F-484A-9712-584A1B233A55`, iOS 26.5, 402x874 logical | Post-system-UI-fix Foundation integration smoke passed with a preserved transcript | No human VoiceOver/Switch Control, visual system-bar, or physical edge-back claim |
| Qiyue iPhone `00008150-000268290C44401C`, iPhone 17 Pro Max, iOS 26.5.2 | Final signed build, install, unlocked cold launch, matching process, VoiceOver representative flow, real IME, App Extra Large safe area and human edge-back all pass | Representative minimum baseline only; Switch Control, external keyboard and exhaustive combinations remain P2 backlog |

The local device inventory includes dedicated API 34 and API 36 Android AVDs,
the Xiaomi's preserved API 29 evidence and API 30 device with its preceding
release installation, the physical iPhone, and current-runtime iOS simulators.
The API 29 phone evidence
provides older-device compatibility and is not rewritten after the OS upgrade.
The API 30 phone is the acceptance target for physical Android lanes that are
not explicitly API 34/API 36. Its hash-bound installation, smoke, cold launch,
selected visual/persistence states, representative TalkBack traversal and one
real-IME Next/Done flow are complete. Android 14+ physical hardware
remains a separate non-blocking `Unknown`; API-specific gesture and edge-to-edge
gates use API 34/API 36 emulators. Exact screenshots and raw records are indexed
in the evidence README. The wireless iPad is unavailable because Developer Mode
is not enabled.

## Hard-gate closure

### Android

No Android P0/P1 representative gate remains open. Native-mouse API 34/API 36
predictive back and API 36 gesture/three-button system-boundary review pass.
Android 14+ physical-device evidence remains separately `Unknown`; the approved
API 34/API 36 emulator lanes do not manufacture hardware proof.

### iOS and cross-platform input

No iOS P0/P1 representative gate remains open. The hash-bound signed candidate
passes the selected single-choice announcement, representative VoiceOver flow,
real iOS Next/Done behavior, App Extra Large safe-area endpoint and human
edge-back cancellation/completion. The detailed record is
`evidence/admin9-ui-phase-6/physical-iphone-v102-human-acceptance.md`.

### P2/P3 backlog (non-blocking, not passed)

- Android Switch Access and iOS Switch Control repetition.
- Password-manager save/autofill observations and external-keyboard sampling.
- Every-page reader traversal, every accessibility-setting Cartesian product,
  and repeated Dialog/Notice/AppFeedback variants under device readers.
- Password-visibility immediate state announcement; current state is correctly
  exposed on refocus and focus is retained.

These items become blockers if a representative flow, real business consumer
or user report exposes task failure. Their automated component contracts remain
mandatory and passing.

Each result must record the exact device, OS/API, navigation mode where
applicable, system text/accessibility settings, expected and actual outcome,
and screenshot or recording identifier. A code assertion or ordinary
application-back event cannot close a system-gesture or human-accessibility
gate. The single execution checklist is the [Phase 6 manual device acceptance
checklist](evidence/admin9-ui-phase-6/manual-device-acceptance-checklist.md).

## Independent review

The Android Material review now returns `Go` with no P0-P2. Its first review correctly
rejected a mislabeled supposed three-button screenshot because it showed the
gesture handle; the evidence was replaced with matching light/dark three-button
captures and a raw environment record. The API 36 simulator evidence still
does not replace Android 14+ hardware, which remains an explicit non-blocking
`Unknown`. Native-mouse predictive-back four-stage runs now pass on API 34 and
API 36; Switch Access repetition remains P2 backlog.

The earlier accessibility/test review returned `Blocked` under the exhaustive
matrix then in force. After the risk-tiered policy, composite-evidence boundary,
authentication-result live region and final-candidate provenance were revised,
a second independent review found no new P0-P2 and confirmed that Xiaomi does
not need a repeated walkthrough. Actual reader, gesture, IME, safe-area and
release facts remain representative P0/P1 gates; switch scanning,
password-manager, external-keyboard and repeated-page sampling remain explicit
P2 backlog. A final review still runs after the iPhone observations; the earlier
blocked decision is not reused as that final `Go`.

The earlier iOS HIG and accessibility reviews independently returned `Blocked`
while the physical-iPhone evidence was absent. The final hash-bound candidate
now passes signed delivery, selected-state Semantics, VoiceOver representative
flow, real IME, App Extra Large safe area and edge-back cancellation/completion.
A fresh independent review runs against this completed record; the earlier
blocked decision is retained only as history.

## Git and delivery boundary

- Current committed implementation HEAD before the Phase 6 working tree:
  `a31227b014ac5d5564735552c4e30851eca8707e`.
- Final Phase 6 implementation commit:
  `54d139c70d6e4b873d7bc97b445e10b0264d450d`.
- Phase 0D through Phase 5 commits are local and have not been pushed.
- The system-UI fix, tests, tools, evidence and Go report are frozen in that
  focused implementation commit.
- The repository-wide `*.log` ignore rule also matches Phase 6 evidence logs.
  The eventual focused Phase 6 commit MUST force-add the exact reviewed log
  files and verify them with `git ls-files`; ordinary directory staging is not
  sufficient.
- A separate provenance commit records this exact implementation SHA in the
  v1.0.2 machine compatibility contract; the annotated final tag points to that
  provenance commit so no commit attempts to name itself.
- Phase 6 runtime changes are limited to the App-host system-UI overlay, the
  release-only production plugin registry, stable root Grayscale filtering,
  the one-time privacy transition announcement, and the authentication
  unavailable-result live region.
  No route, product theme, dependency, page flow, or business behavior changed.

## Final judgment

**Go.** Deterministic contracts and all representative Android/iOS P0/P1 gates
pass. P2/P3 repetition is explicit backlog and is neither used to delay
delivery nor mislabeled as passed. Android 14+ physical hardware remains a
separate non-blocking `Unknown`; its API-specific requirements passed on the
named API 34/API 36 emulator lanes.

Any eventual `Go` states only that the representative Android and iOS flows
meet Admin9's minimum usable accessibility baseline. It is not a WCAG
conformance claim or complete assistive-technology certification.
