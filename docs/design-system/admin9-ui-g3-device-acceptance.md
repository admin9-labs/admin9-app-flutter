# Admin9 UI G3 Physical-device Acceptance

Date prepared: 2026-08-23
Reviewed implementation commit: `d6adb419dfa6935868b37621fc530e942fd13988`
Implementation tree: `7ad5e22ad62d29fd1c4eda2b520b156f54acff47`
Status: packages and checklist ready; Android/iOS physical-device result Unknown

## Acceptance authority

Only the user/product approver can close this gate after using both builds.
Local builds, simulators, Goldens and Flutter semantics tests remain supporting
evidence. They do not establish real-device brand unity, native gesture quality,
real keyboard behavior or TalkBack/VoiceOver delivery.

Pass means both devices are immediately recognizable as the same Admin9 product,
the same tasks retain the same information and recovery, and the operating
system interactions still feel natural. Cross-platform pixel equality is not
required.

## Bound artifacts

| Platform | Artifact | Identity | Integrity | Boundary |
| --- | --- | --- | --- | --- |
| Android | `build/app/outputs/flutter-apk/app-release.apk` | Release APK, 51,005,113 bytes | SHA-256 `033da5010261a37bc0d62c188e7596a2fb82cdf7a8a6cfb8bfea7c65a26b5bc8` | Built locally; physical installation and launch are not yet recorded |
| iOS | `build/ios/ipa/Admin9 App Starter.ipa` | Development-signed arm64 IPA, 7,211,488 bytes; bundle `com.admin9.app.foundation`; version `1.0.0 (1)`; minimum iOS 13.0 | SHA-256 `4280712752943f402ce23d5e23cbdefc4f4ed1b719dae244b713db71d1f8ddf3` | Installable only on devices included by the development profile; not App Store or Ad Hoc distribution |

The corresponding signed `build/ios/iphoneos/Runner.app` is 16,824 KiB. Its
sorted relative-path per-file SHA-256 manifest digest is
`682ec8b1b36112ae5556dac0de1bcd4abc0088d69c5d1e936104ea4d7a7701b5`.

The iOS export uses Apple Development team `J25XZRW743`. Strict code-sign
verification and IPA archive integrity passed. The profile contains the current
`Qiyue iPhone` UDID `00008150-000268290C44401C` and expires on
2027-06-05 18:16:28 UTC. The exported IPA uses Flutter/Xcode's `debugging`
export method, which is the development-device export corresponding to the
requested Flutter `development` method.

Before installing, re-run the following integrity checks. A mismatch invalidates
this checklist and requires a rebuild plus new hashes.

```bash
shasum -a 256 build/app/outputs/flutter-apk/app-release.apk
shasum -a 256 "build/ios/ipa/Admin9 App Starter.ipa"
unzip -t "build/ios/ipa/Admin9 App Starter.ipa"
codesign --verify --deep --strict --verbose=2 \
  build/ios/iphoneos/Runner.app
```

Suggested local installation commands are intentionally separate from package
preparation. Run them only for the exact chosen devices:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
xcrun devicectl device install app --device 00008150-000268290C44401C \
  build/ios/iphoneos/Runner.app
```

The signed `Runner.app` is the app bundle used alongside the IPA export. Do not
substitute the earlier no-codesign bundle documented during G3 compile checks.

## Device record

Complete this before judging the UI. Use `Unknown`, not Pass, for anything not
actually exercised.

| Field | Android | iOS |
| --- | --- | --- |
| Tester and date | Pending | Pending |
| Device model | Pending | Qiyue iPhone; confirm model on device |
| OS version / API | Pending | iOS 26.6 (23G71); confirm at test time |
| Installed artifact hash matched | Unknown | Unknown |
| Install and cold launch | Unknown | Unknown |
| Navigation mode / safe-area form | Pending | Home indicator; confirm on device |
| Text size / contrast / reader settings | Record each run | Record each run |

## Shared product and business pass

Run the same data and state on both platforms. Record `Pass`, `Fail` or
`Unknown`, plus a short observation and screenshot identifier when useful.

| Scenario | Required observations | Android | iOS |
| --- | --- | --- | --- |
| Login and registration | Same field order, labels, validation, long errors, primary action and unavailable-service notice; real Next/Done, selection and password manager remain usable | Unknown | Unknown |
| Main navigation and account list | Same Home/Account destinations, title hierarchy, selected destination, account/legal/support rows, empty/error meaning and retry path | Unknown | Unknown |
| Settings form | Same theme/text-size sections, row hierarchy, selected values, switch meaning, persistence error and retry; system preferences still take effect naturally | Unknown | Unknown |
| Dialog and feedback | Same menu order, disabled/destructive/cancel meaning, confirmation actions, loading/empty/error hierarchy, feedback recovery and close behavior | Unknown | Unknown |

Brand unity fails if platform alone changes title placement, component family,
icon language, density, action priority, error meaning or recovery path enough
that the two builds read as different products.

## Platform-behavior pass

| Check | Android | iOS | Pass condition |
| --- | --- | --- | --- |
| Back navigation | Unknown | Unknown | Android system/predictive back and iOS edge-back cancel/complete feel native, pop one intended route and preserve state |
| Keyboard and focus | Unknown | Unknown | Real keyboard does not cover the active field/action; Next/Done, selection, dismissal and focus movement work |
| Autofill/password manager | Unknown | Unknown | Native overlay can appear and complete without breaking field state or layout |
| Safe areas/system bars | Unknown | Unknown | No content or action is hidden by cutout, navigation area, home indicator or keyboard transition |
| Permissions/share/pickers | Unknown | Unknown | When exposed, system UI may differ while surrounding Admin9 explanation and result stay consistent |
| TalkBack/VoiceOver | Unknown | Unknown | Same names, roles, values, order, disabled/toggled meaning, validation and recovery; state error is announced once and focus is restored after a modal |
| Large text/high contrast | Unknown | Unknown | Representative screens remain ordered, readable, scrollable and actionable without truncation or overlap |

Run light and dark appearance on both devices. On Android include the available
large-text/high-contrast setting and both system navigation modes when the
device supports them. On iOS include maximum practical Dynamic Type, Bold Text
or Increase Contrast, and VoiceOver. Switch Access/Control and external keyboard
are additional evidence when available, not substitutes for the reader pass.

## Decision record

Do not mark overall Go until every required row above is Pass or has an explicit,
user-approved exemption.

| Decision | Value |
| --- | --- |
| Android result | Pending |
| iOS result | Pending |
| Same Admin9 product on both devices | Pending |
| Platform interactions remain natural | Pending |
| Final brand direction accepted | Pending |
| Approver / date | Pending |
| Evidence paths or notes | Pending |

Any P0/P1 result returns to the Demo implementation loop with the exact device,
OS, artifact hash, steps and observed behavior. P2 is recorded for the next
stage. Starter migration, versioning, push, publication and release remain
blocked until this record contains explicit user acceptance.
