# Foundation final candidate provenance

> **Historical evidence:** This file preserves phase- and date-bound evidence.
> It is not a current Admin9 App Starter specification, compatibility promise,
> or rule for independent forks.

Recorded: 2026-07-31; final iOS artifact and human gate updated after the
selected-state Semantics fix

This record binds the final Phase 6 source to rebuilt Android and iOS release
artifacts. Artifact and process records prove identity only; the separate
human-acceptance transcript owns VoiceOver, real iOS keyboard, physical safe
area and human edge-gesture observations.

## Source identity

- Committed base: `a31227b014ac5d5564735552c4e30851eca8707e`
- Runtime/test/tool source manifest:
  `foundation-final-candidate-source-sha256.txt`
- Source-manifest SHA-256:
  `0b3bf8bb1314c6fff95676727461f5e06f6311ec4a495b1761b509d104e5be09`
- The manifest includes `lib`, `test`, `integration_test`, Design System tools,
  Android main sources/build configuration and iOS Runner project sources.
- The candidate remains an unstaged working tree. The final Phase 6 commit SHA
  must replace this mutable-source description before the v1.0.2 compatibility
  tuple is frozen.

The reader-sensitive deltas after the earlier Xiaomi human traversal are fully
enumerated: the page-level authentication unavailable-result live region and
the iOS-only explicit selected-state node for `AppSingleChoiceList`. The former
is locked by the cross-platform authentication semantics/business-truth tests;
the latter is locked by the iOS label/role/enabled/selected/tap-action test and
was then exercised in the final iPhone human pass. The full suite is rerun on
this source manifest. No Android reader-sensitive behavior changed after the
final Android release was built and install-bound.

## Android candidate

- Artifact: `build/app/outputs/flutter-apk/app-release.apk`
- Size: 51,598,161 bytes
- SHA-256:
  `aa2deda938ead8b1e9644c1210cc5c7a9b3b0c8356ccff43825c7744a2767995`
- Device: Xiaomi M2007J22C, Android 11 / API 30, serial
  `r8ovcmxwberwtoau`
- `adb install -r`: Pass
- Force-stop and launcher cold start: Pass; final PID `15904`
- Installed `base.apk` pulled back: 51,598,161 bytes, SHA-256 identical to the
  local artifact
- The final installed `base.apk` SHA-256 matches the local artifact. No data
  clear or reader manipulation was performed. Existing Xiaomi human
  evidence is reused only under the composite-evidence policy; this install is
  not described as a new TalkBack observation.

## iOS candidate

- Artifact: `build/ios/iphoneos/Runner.app`
- Runner size: 281,632 bytes
- Runner SHA-256:
  `89fc6f98e42089afa592e3f3ba0515fe2935e5744de83dbdd475372bf03db209`
- Info.plist SHA-256:
  `81a9361e8c033fa426f36287a73aa55f7ba64edd264c60c4f6421713656c73d8`
- CodeResources SHA-256:
  `2c9d940e42f2964911a04b70af785c6b5dc6c99c2751fcb277a8b0314d85b75c`
- Full CDHash:
  `b62793955e45e5bba1a70dce092eba4431c7c4004e5e10a38522237be9519723`
- Signing Team: `J25XZRW743`; strict deep codesign verification passed
- Device: Qiyue iPhone, iPhone 17 Pro Max, iOS 26.5.2, CoreDevice ID
  `44C6E299-C645-56DD-8A6F-6E03EE2B631E`
- Installation URL:
  `file:///private/var/containers/Bundle/Application/BCEF21D2-ECFC-4AB5-B5C0-68317ABB5470/Runner.app/`
- Install and `--terminate-existing` launch: Pass
- Running PID `27173` points to the same installation directory

Raw iOS command records:

- `physical-iphone-v102-install.json` / `.log`
- `physical-iphone-v102-launch.json` / `.log`
- `physical-iphone-v102-final-processes.json` / `.log`

## Human gate result

The device owner reports the final selected-state announcement, representative
VoiceOver flow, real iOS Next/Done path, App Extra Large safe-area endpoint,
and edge-back cancellation/completion all pass on this candidate. Exact
expectations, actual outcomes and claim limits are recorded in
`physical-iphone-v102-human-acceptance.md`. This is representative minimum
usable accessibility evidence, not full accessibility certification.
