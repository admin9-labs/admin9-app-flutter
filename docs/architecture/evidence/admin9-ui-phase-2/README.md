# Phase 2 device evidence

> **Historical evidence:** This file preserves phase- and date-bound evidence.
> It is not a current Admin9 App Starter specification, compatibility promise,
> or rule for independent forks.

This directory contains device observations for the Phase 2 platform shell. Files are evidence, not Design System reference art.

## Android API 36

| Field | Value |
| --- | --- |
| Device | Android SDK emulator `sdk_gphone64_arm64` |
| API | 36 |
| Display | 1080x2400 px at 420 dpi |
| Navigation mode | `2` (gesture navigation) |
| App artifact | arm64 debug APK, SHA-256 `547e9dbe45d91d7b6f1bf9072851b6e60416cad3195ebd5f8ad306c2fdd5a547` |
| Source state | Phase 2 worktree based on `0ae90266f07da437cdec7207cc9ee60b049cf0cf` |

`android-api36-predictive-complete.mp4` is a continuous screen recording. It starts on Settings, shows system predictive-back progress, and ends on My. Its SHA-256 is `f287384c21e7aedd35858bc6c19bcab18e3655fc90a2ead9ce8ab424d485223d`. The final frame confirms exactly one application-level pop.

The four PNG files and two UI Automator XML files are static observations from the same emulator family. They support page identity and individual visual states, but do not prove continuity. They MUST NOT be cited as a replacement for a continuous cancel recording.

The attempted ADB `motionevent CANCEL` recording produced no valid encoded gesture frames and was deleted. Android API 34 and a valid continuous cancel recording remain Phase 6 manual hard gates.

## iOS simulator

| Field | Value |
| --- | --- |
| Device | iPhone 17e simulator |
| Runtime | iOS 26.5 |
| Logical canvas | 390x844 pt |

The existing MOV/PNG files are retained as attempted observations. Frame review did not show a valid edge-swipe start/progress/cancel or a completed edge pop. They are rejected as acceptance evidence and remain Phase 6 manual hard gates. Ordinary application pop state is covered by `integration_test/phase_2_navigation_test.dart`; that test does not claim system-gesture evidence.

## Evidence boundary

- Widget tests own 320/360/390/600 logical windows, landscape, semantics, hit bounds, and A-L content-growth checks.
- Integration tests own application state before and after ordinary back.
- Device recordings own system gesture, system bars, cutout, reader, and switch-access observations.
- TalkBack, VoiceOver, Switch Access/Control, Android three-button navigation, cutout, system-bar contrast, Android API 34 cancel/complete, and iOS edge-swipe cancel/complete remain Phase 6 device gates.
