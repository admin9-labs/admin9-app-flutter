# Admin9 UI G3 Simulator Acceptance

Date: 2026-08-23
Smoke source commit: `bc4d92d0c9c8adb87a356e6c4b18f8585937fbc6`
Status: Pass for repeatable dual-simulator cold launch and minimal shared smoke

## Gate decision

The earlier local-service permission Block is closed for this task profile.
The fast preflight passed the host CPU feature queries, ADB port 5037, the
original Android AVD, CoreSimulator, the fixed iOS device and all required
Flutter/Xcode cache write probes.

The same clean source commit completed two consecutive Android/iOS rounds. Each
round rebuilt, installed and cold-launched the normal App before running the
shared navigation/state smoke. No shim, cloned AVD, custom data directory,
read-only mode, headless mode, wrapper, wipe or old App bundle was used.

This Pass closes only the repeatable simulator infrastructure and minimal smoke
gate. It is not full interactive G3 acceptance, physical-device acceptance,
supplemental reviewer approval, Starter migration or final brand approval.

## Fixed environments

| Field | Android | iOS |
| --- | --- | --- |
| Target | Original `Admin9_API_34`, serial `emulator-5554` | iPhone 17e, UDID `C10E0968-4695-4C02-BC55-8C322531239A` |
| Runtime | Android 14 / API 34 Google APIs arm64, Emulator 36.6.11, host GPU | iOS 26.5 CoreSimulator, model `iPhone18,5` |
| Physical viewport | 1080x2400 | 1170x2532 at 3x |
| Flutter viewport | 411.43x890.29 at DPR 2.625 | 390x844 at DPR 3 |
| Insets | Top 51.8, bottom 0 | Top 47, bottom 34 |
| Navigation | `navigation_mode=2`, gesture navigation | Home-indicator safe area |

API 36 was not needed because the primary API 34 target passed both rounds.

## Build and install identity

Both platforms installed bundle/package `com.admin9.app.foundation`, version
`1.0.0 (1)`. Android reported target SDK 36.

| Artifact | Round 1 | Round 2 | Result |
| --- | --- | --- | --- |
| Android release APK | `f4da9119b1eb379d28b75f56e5594e2a86d75acc01fba91e56b9ecb6b82e360f` | Same | Pass |
| iOS `App.framework/App` | `fb9f97f3b7aab44f0af7e05f0b5ddbfe8a28102f0bb36bd6827b461407efe44e` | Same | Pass |
| iOS `Runner` | `0e8e65c2b05e92d2a8937bcee3a19069b9cdfc06f695b3ce53986d6e26c413ab` | `e2e8f2909d56e9cea1394dc8876c0db5735fe3944c4664078d350bb116ae1507` | Built and installed copies match within each round |

The generated iOS host executable is not byte-reproducible across separate
Xcode builds. The Dart App binary is stable, and each installed host/App pair
matches the bundle produced in its own round.

## Cold launch record

Android was force-stopped with `am start -W -S`. On this AVD, Android's short
`am start -W` window returned `Status: timeout` before Flutter drew its first
frame. The entry therefore clears the events buffer before launch and requires
a new `wm_activity_launch_time` line containing the exact package/activity
before capture. The two system-reported display times were 217,698 ms and
61,847 ms. Both post-display screenshots show the privacy screen, not the
launch splash.

iOS used `simctl launch --terminate-running-process` after installing the
current round's `Runner.app`. Before capture, each normal launch required the
launch-completion marker for its returned Runner PID (`69012`, then `73630`)
within 30 seconds. Both screenshots show the same privacy screen. No crash,
ANR, uncaught exception or failed assertion was found in the archived App logs.
The long Android simulator display time is environment performance evidence;
this task does not claim it represents a physical device.

## Minimal shared smoke

The 55-line integration smoke intentionally covers only:

- shared shell and empty Home state;
- bottom navigation to Account and navigation into Settings;
- one back navigation returning to Account;
- Android/iOS viewport, DPR, safe-area and bottom-navigation metrics;
- absence of an uncaught Flutter test exception.

All four runs passed. No product P0/P1 was observed within this bounded scope.

## Evidence

The reviewable archive is indexed at
[`evidence/admin9-ui-g3-simulator-smoke/README.md`](evidence/admin9-ui-g3-simulator-smoke/README.md).
Each round contains build/install/launch logs, Android launch-completion events,
App logs, device and installed-identity data, artifact hashes, smoke logs,
screenshots and evidence checksums.

## Unknown and pending

- Real autofill/password-manager delivery remains `Unknown`.
- TalkBack and VoiceOver delivery remains `Unknown`.
- Real keyboard, Android predictive-back and iOS edge-back delivery remains
  `Unknown` beyond the bounded programmatic back check.
- Full login/registration, Gallery, dialogs, feedback, appearance and
  accessibility interaction were not expanded in this infrastructure task.
- Physical-device performance, safe areas, perceived brand unity and final
  user approval remain `Unknown`.
- Supplemental G3 reviews and physical-device handoff remain separate stages.
