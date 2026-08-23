# Admin9 UI G3 Simulator Acceptance

Date: 2026-08-23
Checkout commit: `95e1ca8c316afd20e4f0d06fab24f4c398386020`
Reviewed implementation commit: `d6adb419dfa6935868b37621fc530e942fd13988`
Status: Blocked; iOS interactive evidence is partial Pass, Android Emulator did
not reach boot

Correction retry parent: `1cdb2c1cf3db804aba3cdc4a4adddcd70cb5855b`

## Gate decision

The dual-simulator prerequisite is not Go. An iOS Simulator run exercised the
normal Demo interactively, but Android did not boot and the current-source iOS
rebuild was not installed. Cross-platform same-product acceptance therefore
remains Unknown. Golden, Widget, build and former Phase 6 evidence are not used
to replace either missing fixed-source result.

The `1cdb2c1` conclusion was too broad: its isolated launcher, cloned AVD,
temporary data and injected shim attempts do not prove that the original AVDs
cannot run under Codex. Earlier Codex runs started both original AVDs, installed
the App and exercised them. The correction retry below used the original API 34
AVD and known host-GPU command; it was blocked by this task's restricted local
service permissions. No user-operated Android Studio launch is required after
those permissions are restored.

The three final supplemental G3 reviews have not been opened. They are allowed
only after one fixed source revision passes both simulator runs and any direct
P0/P1 regression loop.

## Build and install identity

| Item | Result | Boundary |
| --- | --- | --- |
| Source checkout | `95e1ca8c316afd20e4f0d06fab24f4c398386020`; tree `45acfd102e1e3e6f0e819ebe21950355a21d17fb` | Includes the already reviewed G3 implementation `d6adb41` and later handoff documentation |
| Existing iOS Simulator artifact | Bundle `com.admin9.app.foundation`, version `1.0.0 (1)`, minimum iOS 13; strict ad-hoc code-sign verification passed | Workspace and installed `App.framework/App` both hash to `4908328a047b49338694a96f028eb4ed3dc44a7351b45776deeca4841a4ce5b6` |
| Existing iOS install | Installed bundle was interactively launched, force-quit in the App switcher and cold-launched successfully | The workspace artifact timestamp is after the checkout commit, but it does not embed the Git SHA |
| Current-source iOS Dart rebuild | Direct Flutter assemble from the checkout passed; `App.framework/App` hashes to `6cac86cdd0404f86ec26eaefa9270694c566a994715022c97c7d1be24246bde3` | CoreSimulator and LaunchServices sandbox restrictions prevented installing this exact rebuilt bundle; exact current-source-to-installed binding is Unknown |
| Android build | Existing Release APK remains available from G3 | No APK install or App launch occurred because Android never booted |

This distinction is intentional: the iOS interaction results are valid for the
installed artifact whose hash is recorded above, but they are not promoted to
an exact current-source install result.

## Environments

| Field | Android | iOS |
| --- | --- | --- |
| Candidate | Pixel 7 AVD, API 34 preferred; API 36 also attempted | iPhone 17e, iOS 26.5, UDID `C10E0968-4695-4C02-BC55-8C322531239A` |
| Runtime | Android Emulator 36.6.11, arm64; installed API 34 and API 36 Google APIs arm64 images | CoreSimulator system runtime |
| Viewport | AVD configuration is 1080x2400 at density 420; runtime viewport Unknown because boot failed | 1170x2532 pixels at 3x, or 390x844 points; notch and home-indicator safe areas were visibly present |
| Navigation | Unknown; Emulator never reached Android system UI | Home indicator plus iOS edge-back gesture |
| Result | Blocked before boot/install | Interactive partial Pass |

## iOS interactive record

The run used `admin9.long.account@example.com` and a non-production test
password. No credential or business data was transmitted; the Demo reports
that account services are not connected.

| Scenario or state | Result | Observation |
| --- | --- | --- |
| Account and main navigation | Pass | Guest account, Home/Account destinations, selected destination, account/legal/application rows and Home empty state remained ordered and readable |
| Login | Pass | Long account input, secure password, validation, unavailable-service feedback and primary/secondary action order were usable |
| Registration | Pass with simulator limit | Required-field and short-password errors retained focus and layout; iOS strong-password UI appeared and could be cancelled. Real password-manager behavior remains a physical-device Unknown |
| Settings | Pass | Light/dark, standard/extra-large App text, grayscale, high contrast and reduce motion applied and persisted without overlap or unreachable actions |
| Keyboard and focus | Pass for simulator | Software keyboard was toggled on, the active login field and primary action remained visible, and focus/error state remained coherent |
| Edge back | Pass | A left-edge swipe popped exactly one auth route and returned to the unchanged Account state |
| Safe areas | Pass for observed portrait states | Titles, lists, controls, keyboard state and bottom navigation did not collide with the notch or home indicator |
| Empty and error/feedback | Pass | Home empty state, form validation and unavailable-service notice were visible and actionable in the normal Demo |
| Cold launch | Pass | App was force-quit through the iOS App switcher, showed the Admin9 launch surface and reached Home |
| Loading and disabled Gallery states | Unknown | They are registered only on the internal Gallery route and were not reachable from the installed normal Demo |
| App dialog and action menu | Unknown | Normal guest-state routes did not expose the Gallery confirmation or action menu in this installed run |
| Real autofill, VoiceOver delivery | Unknown | Simulator overlays and Flutter semantics do not replace physical-device password-manager or VoiceOver delivery |

The iOS UI was internally recognizable as the current Admin9 Demo across these
states. Whether Android and iOS read as the same product cannot be judged until
the matching Android scenarios are operated.

## iOS simulator evidence

All files below are Simulator window captures, not physical-device screenshots.
The filenames explicitly retain the `ios_simulator` evidence level.

- `evidence/admin9-ui-g3-simulators/ios/ios_simulator_01_account_light.png`
- `evidence/admin9-ui-g3-simulators/ios/ios_simulator_02_login_keyboard_focus.png`
- `evidence/admin9-ui-g3-simulators/ios/ios_simulator_03_login_unavailable_feedback.png`
- `evidence/admin9-ui-g3-simulators/ios/ios_simulator_04_edge_back_result.png`
- `evidence/admin9-ui-g3-simulators/ios/ios_simulator_05_register_validation_password_prompt.png`
- `evidence/admin9-ui-g3-simulators/ios/ios_simulator_06_home_empty_state.png`
- `evidence/admin9-ui-g3-simulators/ios/ios_simulator_07_settings_dark.png`
- `evidence/admin9-ui-g3-simulators/ios/ios_simulator_08_settings_dark_extra_large.png`
- `evidence/admin9-ui-g3-simulators/ios/ios_simulator_09_settings_dark_extra_large_layout.png`
- `evidence/admin9-ui-g3-simulators/ios/ios_simulator_10_settings_high_contrast_reduce_motion.png`
- `evidence/admin9-ui-g3-simulators/ios/ios_simulator_11_settings_grayscale.png`
- `evidence/admin9-ui-g3-simulators/ios/ios_simulator_12_cold_launch.png`
- `evidence/admin9-ui-g3-simulators/ios/ios_simulator_13_cold_launch_complete.png`

Each capture is 452x950 pixels and includes Simulator chrome identifying the
device. Cursor highlights are automation evidence, not App rendering.

## Android blocker

Both original AVDs remain Pixel 7 arm64 images at 1080x2400 / 420 dpi. Their
configuration and user-data timestamps predate this G3 retry. The saved launch
parameters for both AVDs are the official Emulator plus `-avd <name>`,
`-gpu host`, `-no-snapshot-load` and `-no-boot-anim`, matching the prior
successful route.

The correction retry used:

```text
/Users/fengqiyue/Library/Android/sdk/emulator/emulator \
  -avd Admin9_API_34 -no-snapshot-load -no-boot-anim -gpu host
```

It used the original `Admin9_API_34`, an ordinary graphical window and no wipe.
It did not use an injected library, copied Emulator, custom App wrapper, cloned
AVD, read-only mode, independent data directory, headless mode or software GPU.
The AVD did not reach a point where wiping data could affect the result, so its
state was left intact.

The current task process could not read `hw.optional.neon` or
`hw.optional.arm.FEAT_AES` through `sysctl`, and ADB could not bind its normal
localhost port 5037 (`Operation not permitted`). The official Emulator then
aborted in Qt's `qDetectCpuFeatures` before Android boot. The new macOS reports
record `EXC_CRASH` / `SIGABRT`, not the shim-path `SIGILL`, and their loaded
images contain no shim or temporary experiment path.

CoreSimulator CLI access failed independently because the same task profile
could not connect to CoreSimulatorService or open its log. That prevents
installing and hash-binding the current-source iOS rebuild in this retry. These
are permission-profile observations, not App, AVD, rendering or host-capability
results. They also do not support the former claim that all Codex-launched
Emulators require an external user process.

## Resume conditions

1. Resume in a Codex task that can read the normal host CPU features, bind ADB's
   localhost server and connect to CoreSimulatorService. Codex then launches the
   original Pixel 7 API 34 AVD itself with the known host-GPU command and records
   gesture or three-button navigation; no user manual startup is required.
2. Build and install from the same fixed source SHA on both simulators. Replace
   the iOS installed-artifact Unknown with a hash-bound current-source install.
3. Execute the same four scenarios and state inputs on Android and iOS,
   including the internal Gallery states, Android system/predictive back and
   iOS edge-back.
4. Fix any direct P0/P1, rerun both simulators plus the directly affected local
   gates, and commit a new fixed SHA.
5. Only then open exactly three read-only supplemental G3 reviews for
   product/brand, Flutter architecture/App* boundaries and QA/accessibility.

Until all five conditions are met, physical-device handoff, Starter migration,
push, release, tag and publication remain blocked.
