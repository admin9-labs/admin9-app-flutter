# Admin9 G3 Repeatable Simulator Smoke Evidence

Date: 2026-08-23
Source commit: `72d6e60f925ea676dc9b0670c9a8ad7bb89bd73f`
Command:

```bash
tool/simulator_smoke.sh run --rounds 2 \
  --evidence-dir docs/design-system/evidence/admin9-ui-g3-simulator-smoke
```

Overall result: `Pass`

## Round summary

| Round | Android | iOS | Completed UTC |
| --- | --- | --- | --- |
| 1 | API 34 cold launch displayed; smoke Pass | iPhone 17e / iOS 26.5 cold launch; smoke Pass | 2026-08-23 13:21:50 |
| 2 | API 34 cold launch displayed; smoke Pass | iPhone 17e / iOS 26.5 cold launch; smoke Pass | 2026-08-23 13:26:13 |

Both rounds used package/bundle `com.admin9.app.foundation` version `1.0.0
(1)`. Android used gesture navigation (`navigation_mode=2`). The APK hash was
`f4da9119b1eb379d28b75f56e5594e2a86d75acc01fba91e56b9ecb6b82e360f`
in both rounds. The iOS Dart App binary hash was
`fb9f97f3b7aab44f0af7e05f0b5ddbfe8a28102f0bb36bd6827b461407efe44e`
in both rounds, and each installed iOS bundle matched its round's build.

## Evidence layout

The SHA-named directory contains the session preflight and overall result.
`round-1/` and `round-2/` each contain:

- `device-and-build.txt`: device, API, viewport, navigation, package and hash data;
- `android-launch.log`: exact `am start -W -S` output;
- `android-launch-complete.log`: cleared-buffer event proof for the cold launch;
- `ios-launch.log`: exact `simctl` launch result;
- `android-cold-launch.png` and `ios-cold-launch.png`: post-display screenshots;
- `android-smoke.log` and `ios-smoke.log`: metrics and shared smoke result;
- build, install, App, screenshot and per-round result logs;
- `evidence-sha256.txt`: screenshot and smoke-log checksums.

The screenshots and smoke logs pass their recorded SHA-256 checks. Raw Android
`am start -W` timed out before the Flutter first frame, while the new system
display events completed at 121,033 ms and 50,255 ms. The screenshots were
captured only after those events and show the App privacy screen rather than the
launch splash.

## Boundary

This evidence proves repeatable build/install/cold-launch and the bounded shared
navigation smoke on the fixed simulators. Real autofill, TalkBack, VoiceOver,
physical-device behavior and final brand approval remain `Unknown`.

## Hardened revalidation

Source `bc4d92d0c9c8adb87a356e6c4b18f8585937fbc6` completed another two-round
Pass at 14:31:46 and 14:36:03 UTC. The new archive is in the matching SHA-named
directory; the original `72d6e60` archive above is unchanged.

The revalidation additionally proves that each Android completion is one
`wm_activity_launch_time` line containing the exact Activity, and that each iOS
normal launch reached the launch-measurement completion marker for its current
Runner PID before screenshot capture. The Android display times were 217,698 ms
and 61,847 ms. Normal iOS PIDs were 69012 and 73630. Both rounds retained the
same APK and Dart App hashes recorded above; each generated and installed iOS
host binary also matched within its round. All four new screenshot/smoke
checksums pass, and visual review confirms the App privacy screen rather than a
launch splash.
