# Admin9 UI G3 Simulator Smoke Infrastructure

This entry owns only repeatable Android/iOS simulator validation. It does not
change product UI, migrate Starter, wipe an AVD, clear App data, publish, push or
tag.

## Fixed targets

| Platform | Target | Runtime |
| --- | --- | --- |
| Android | Original `Admin9_API_34` AVD | Google APIs arm64, Android 14 / API 34, official Emulator with host GPU |
| iOS | iPhone 17e, UDID `C10E0968-4695-4C02-BC55-8C322531239A` | Existing iOS 26.5 Simulator runtime |

Android API 36 remains a regression target only when API 34 passes and a
version-specific check is necessary. The script does not select API 36 by
default.

## Entry points

Run the fast preflight before changing either device:

```bash
tool/simulator_smoke.sh preflight
```

The preflight does not boot, install, launch, wipe, clone or change a device. It
reads the fixed device state and uses short host-cache write probes that are
removed immediately. Those probes are necessary because filesystem mode bits
alone did not detect the earlier Codex sandbox denial.

Run the complete path once, writing generated evidence under ignored `build/`:

```bash
tool/simulator_smoke.sh run --rounds 1
```

For a reviewable repeated run, provide a deliberate evidence directory:

```bash
tool/simulator_smoke.sh run --rounds 2 \
  --evidence-dir docs/design-system/evidence/admin9-ui-g3-simulator-smoke
```

The run holds a per-user lock, starts only the fixed targets when needed, builds
the current clean tracked Git SHA, installs the normal App, force-stops and cold
launches it, captures native screenshots and App logs, then runs the same small
navigation/state integration smoke on both devices. It records the source SHA
artifact hashes, installed identities, device/API details, Android
navigation mode, iOS viewport/safe-area metrics, commands and result per round.

Android's `am start -W` can return `Status: timeout` before a slow Flutter first
frame while still exiting zero. The entry clears the Android events buffer
before each launch and requires a new `wm_activity_launch_time` for the fixed
package/activity before it captures evidence. Absence of that event after 90
polls is `App Fail`; raw `am start` output remains archived.

## Result contract

| Result | Meaning |
| --- | --- |
| `Pass` | Preflight and every requested round completed on both fixed targets |
| `App Fail` | Current-source build, launch process or shared App smoke failed |
| `Infrastructure Block` | Required tool, permission, service, boot, install or capture path failed |
| `Unknown` | The working tree cannot be bound to `HEAD`, arguments are invalid, or provenance cannot be established |

Every failure result includes `stage`, `failure_call` and `failure_log`. The
script does not guess that a tool failure is a product regression, and it does
not turn a simulator result into physical-device acceptance. Real autofill,
TalkBack, VoiceOver and user brand acceptance remain `Unknown` until separately
delivered on the required hardware.

## Verified baseline

Commit `72d6e60f925ea676dc9b0670c9a8ad7bb89bd73f` completed two consecutive
rounds on 2026-08-23. Both Android API 34 and iOS 26.5 smoke runs passed in each
round. The reviewable logs, screenshots, device identities and hashes are under
[`evidence/admin9-ui-g3-simulator-smoke/`](evidence/admin9-ui-g3-simulator-smoke/).
