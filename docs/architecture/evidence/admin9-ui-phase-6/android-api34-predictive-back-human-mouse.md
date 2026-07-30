# Android API 34 predictive-back human-mouse record

- Date: 2026-07-31 (Asia/Shanghai)
- AVD: `Admin9_API_34`
- Serial: `emulator-5554`
- OS: Android 14 / API 34
- Navigation mode: gesture (`navigation_mode=2`)
- Predictive-back animation: enabled (`enable_back_animation=1`)
- App artifact SHA-256:
  `fc43800cd9cd0553ef3b708a0b646f37b520e980b9bdfaba43c618e837b134aa`
- Input boundary: genuine macOS mouse drags performed through Computer Use on
  the Android Emulator native window. ADB was used only to install/launch the
  reviewed artifact, navigate to the Theme setup page and record the device
  screen. No ADB `input swipe`, application Back action or test API performed
  the accepted gestures.

## Observation

The starting page was Settings -> Theme with Dark selected. A very short drag
from the left system edge displayed Android's predictive-back progress and,
after release, left the Theme page and selected value intact. A second, longer
drag from the same edge displayed progress and completed exactly one route pop
to Settings, where Theme still showed Dark. No duplicate pop or tab change was
observed.

Result: **Pass** for gesture start, visible progress, cancellation, completion,
single-pop destination and route-local state preservation on the API 34 AVD.
This is emulator evidence; Android 14+ physical hardware remains separately
Unknown.

## Assets

| Asset | Meaning |
| --- | --- |
| `android-api34-predictive-back-human-mouse.mp4` | Device screen recording containing the accepted mouse-operated gesture sequence |
| `android-api34-predictive-back-human-cancel.jpeg` | Native-emulator window immediately after the short cancelled drag; Theme and Dark remain selected with the edge progress indicator visible |
| `android-api34-predictive-back-human-progress.png` | Device recording frame showing predictive-back progress on Theme |
| `android-api34-predictive-back-human-complete.jpeg` | Native-emulator window after completion on Settings |
| `android-api34-predictive-back-human-complete-device.png` | Device recording frame after the single completed pop to Settings |

The first exploratory native-window recording that began at `x=2` resized the
macOS window border and was rejected. Only the calibrated in-content edge
gestures described above are accepted.
