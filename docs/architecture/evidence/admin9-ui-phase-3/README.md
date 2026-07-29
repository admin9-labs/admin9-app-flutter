# Admin9 UI Phase 3 device evidence

Date: 2026-07-30

These files are runtime evidence from the normal debug App. They are not design
references and do not claim physical-device coverage.

## Android API 36 emulator

Device: `sdk_gphone64_arm64`, API 36, 1080x2400 physical pixels at density 420.

- `talkback-keyboard-settings-focus.png` shows TalkBack enabled while an external
  keyboard focus reaches the Settings entry from the My tab.
- `talkback-settings.png`, `talkback-settings.xml`, and
  `talkback-settings-controls.xml` show the Settings hierarchy, current theme and
  App font values, and boolean checked state exposed to Android accessibility.
- `process-restart-before-stop.xml` and `process-restart-after-settings.xml` are
  the raw hierarchy inputs used by the process-restart persistence evidence.
- `switch-access-root-scan-blocked.png` and
  `switch-access-root-scan-blocked.xml` record a rejected Switch Access gate:
  the service was installed, enabled, and bound, but its green scan outline
  remained on the Flutter root group. Assigned Space/Enter actions did not move
  into individual controls. This is `Unknown`, not a pass.

The TalkBack service was disabled after capture. TalkBack speech uniqueness was
not recorded, so the evidence proves focus/navigation and hierarchy exposure,
not exact spoken output.

## iOS 26.5 simulator

Device: iPhone 17e simulator, runtime
`com.apple.CoreSimulator.SimRuntime.iOS-26-5`, logical width 390pt.

- `settings-max-text-top.png` and `settings-max-text-bottom.png` show the normal
  App with system content size `accessibility-extra-extra-extra-large`, Increase
  Contrast enabled, and App font preference `1.24` (`特大`).
- The page remains scrollable, all five settings remain reachable, current
  values move below their labels, and labels wrap without ellipsis after the
  pressure-layout correction.
- VoiceOver, Switch Control, Bold Text, Reduce Motion, and a physical iPhone
  walkthrough remain `Unknown`. Simulator content size and Increase Contrast
  were restored to defaults after capture.

## SHA-256

| File | SHA-256 |
| --- | --- |
| `android-api36/switch-access-root-scan-blocked.png` | `77722bc19e8470b5f4ae078ec5d4b8d4f94faa2dfc24c98454cbad63b23a087c` |
| `android-api36/switch-access-root-scan-blocked.xml` | `f8583cc34b00f12e37f77b160b709d87abc9ede959898db1bf90852ae39e26a4` |
| `android-api36/process-restart-after-settings.xml` | `4e2f193f9c12ab9a99ac683fac7c399484a30c1dcc3364a3bca1fc39141af8f3` |
| `android-api36/process-restart-before-stop.xml` | `719cd171ad290c9a6d350e8c5aeadff6510b121c23b4a41d4ef2bc4eff402c76` |
| `android-api36/talkback-keyboard-settings-focus.png` | `c7d6844c90da5934b57fb422b3ff3a6e34c144a95542ed2826efb6dc89820e12` |
| `android-api36/talkback-settings-controls.xml` | `128b622a296079fd1fbdcc638b577f087e3af27e587e291e26b900ae7c5e45df` |
| `android-api36/talkback-settings.png` | `080033ec7994a963462fcc96b11cae49e024ebc681f9e38d985cf7117b896867` |
| `android-api36/talkback-settings.xml` | `9670ce6a1e43938bf0a3634deeeb34a3cb612581917f478cb55ccbea17e5e350` |
| `ios-26.5/settings-max-text-bottom.png` | `d7f3dcdf07c28da905cec5e7e4f5d6a41cc15010ea878db4a074887bb9aecaf0` |
| `ios-26.5/settings-max-text-top.png` | `1f7a5a7f2176c0b5c4830fbbef8a6ac57e52ec5d8849861ce5b091841dd0a7fb` |

The Android force-stop/restart procedure and result are recorded in
[`android-process-restart-persistence.md`](android-process-restart-persistence.md).
