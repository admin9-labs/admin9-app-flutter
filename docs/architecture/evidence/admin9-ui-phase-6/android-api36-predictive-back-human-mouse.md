# Android API 36 predictive-back human-mouse record

- Date: 2026-07-31 (Asia/Shanghai)
- AVD: `Admin9_API_36`
- Serial: `emulator-5554`
- OS: Android 16 / API 36
- Navigation mode: gesture (`navigation_mode=2`)
- Predictive-back animation: enabled (`enable_back_animation=1`)
- App artifact SHA-256:
  `fc43800cd9cd0553ef3b708a0b646f37b520e980b9bdfaba43c618e837b134aa`
- Input boundary: genuine macOS mouse drags performed through Computer Use on
  the Android Emulator native window. ADB was used only to install/launch the
  reviewed artifact, navigate to the Theme setup page and attempt device-screen
  recording. No ADB `input swipe`, application Back action or test API
  performed the accepted gestures.

## Observation

The starting page was Settings -> Theme. A short drag from the left system edge
showed predictive-back progress and, after release, left Theme active with its
selected value unchanged. A longer drag from the same edge showed progress and
completed exactly one route pop to Settings. No duplicate pop or tab change was
observed.

Result: **Pass** for gesture start, visible progress, cancellation, completion,
single-pop destination and route-local state preservation on the API 36 AVD.
This is emulator evidence; Android 14+ physical hardware remains separately
Unknown.

## Evidence boundary

| Asset | Meaning |
| --- | --- |
| `android-api36-predictive-back-human-cancel.jpeg` | Native-emulator window after the short cancelled drag; Theme remains active |
| `android-api36-predictive-back-human-complete.jpeg` | Native-emulator window after the completed drag on Settings |
| `android-api36-predictive-back-human-complete-final.png` | Fresh native-window capture binding the final Settings destination |
| `android-api36-predictive-back-human-mouse.mp4` | Rejected low-frame-rate recording attempt; it does not show the completed transition |
| `android-api36-predictive-back-human-complete.mp4` | Rejected low-frame-rate completion attempt; it does not show the transition |

The two videos are retained as provenance of the recording limitation, not as
four-stage proof. Android Emulator's device recorder encoded static content at
about one frame per second and missed the compositor transition. The accepted
hard-gate evidence is the contemporaneous human observation with native-window
before/after captures; this limitation is not presented as a video pass.
