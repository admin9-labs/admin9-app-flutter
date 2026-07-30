# Admin9 UI Phase 6 device evidence

Date: 2026-07-31

These records supplement the Phase 6 acceptance report. They are runtime and
delivery observations, not Design System reference art. Human-operated
accessibility and system-gesture claims count only when explicitly marked as
passed in the acceptance report and bound to their human observation record.

## Evidence integrity

`SHA256SUMS` is the complete current manifest for this directory, excluding the
manifest itself. Regenerate it after any evidence change, then verify every
entry from the repository root:

```bash
find docs/architecture/evidence/admin9-ui-phase-6 -type f \
  ! -name SHA256SUMS -print0 \
  | sort -z \
  | xargs -0 shasum -a 256 \
  > docs/architecture/evidence/admin9-ui-phase-6/SHA256SUMS
shasum -c docs/architecture/evidence/admin9-ui-phase-6/SHA256SUMS
```

The repository-wide `*.log` ignore rule matches required runtime transcripts.
At the final Phase 6 commit, stage exactly the manifested evidence with
`git add -f`; ordinary directory staging is insufficient. Then require every
manifest path to be known to Git:

```bash
cut -c 67- docs/architecture/evidence/admin9-ui-phase-6/SHA256SUMS \
  | git add -f --pathspec-from-file=-
git add docs/architecture/evidence/admin9-ui-phase-6/SHA256SUMS
cut -c 67- docs/architecture/evidence/admin9-ui-phase-6/SHA256SUMS \
  | while IFS= read -r file; do
      git ls-files --error-unmatch "$file" >/dev/null || exit 1
    done
```

All representative physical/manual P0/P1 hard gates pass. The evidence remains
unstaged until the final serial checks and independent review complete.

## Android API 36 navigation modes

The active Android emulator is `sdk_gphone64_arm64`, API 36, 1080x2400 pixels at
420dpi. Gesture navigation reported `navigation_mode=2`, the gestural SystemUI
overlay enabled, and `enable_back_animation=1`.

The final acceptance run preserves raw inset, navigation-overlay, display
cutout and screenshot evidence. The accepted review is recorded in
[`android-api36-edge-to-edge-review.md`](android-api36-edge-to-edge-review.md).

The gesture-navigation run completed all Foundation smoke assertions. Its log
is `android-api36-gesture-foundation-smoke.log` with SHA-256
`2a022e61b5383d63772f25d9ce477de41ffc73e591e84730f606eef7019f4122`.
The SystemUI overlay was then changed to three-button navigation, which
reported `navigation_mode=0`. A clean-boot run used:

```bash
flutter test integration_test/foundation_smoke_test.dart \
  -d emulator-5554 -r expanded
```

That run did not complete and was interrupted after 1 minute 48 seconds. Its
log is `android-api36-three-button-foundation-smoke.log` with SHA-256
`27e695dd17fbcaa1dec30527c0010f25f508d7c4302d70a13cbb06b67b51f3f1`.
It is failure evidence, not a three-button pass.

A later clean AVD was started with the `-wipe-data`, `-no-snapshot-load`,
`-no-boot-anim`, and `-gpu host` options, allowed to finish first-run
initialization, changed to the three-button overlay, and verified as
`navigation_mode=0`. Its first install and smoke completed with
`All tests passed!` in 15 seconds. The passing log is
`android-api36-three-button-clean-foundation-smoke.log` with SHA-256
`74d253f445f5cda4866b95f75111833bdcd575ca875a9b2d916d09bc42e9837b`.
The matching raw environment record is
`android-api36-three-button-environment.txt` with SHA-256
`682c1ef93d452d66adf55299ef2edc18e40a37da55808c62cc2baee986af0ec7`.
The AVD was restored to the gestural overlay and `navigation_mode=2`, then
stopped.

Release visual inspection then found a real implementation defect: without an
explicit root `SystemUiOverlayStyle`, three-button navigation could render light
icons against the App's light bottom surface. The App now supplies theme-aware
status/navigation icon brightness, transparent edge-to-edge colors, and Android
navigation-bar contrast enforcement. The release APK rebuilt from this working
tree is 51,598,161 bytes with SHA-256
`192d27fd82585d4a47cc06e8e7b8259c088ed7346d7e17d3c5030fa9642d2a80`.

The files `android-api36-gesture-release.png` and
`android-api36-three-button-release.png` preserve the pre-fix comparison. The
later files named `android-api36-gesture-release-fixed.png` and
`android-api36-three-button-release-fixed.png` both visibly contain the gesture
handle; despite their old names, neither is accepted as three-button evidence.
`android-api36-gesture-app.png` is an integration-test waiting splash and is
also not release acceptance evidence.

The valid post-fix three-button chain is:

- `android-api36-three-button-post-system-ui-fix-environment.txt`, SHA-256
  `42aaa40a01ecf596500b68767a2da1b94bd797dd52ba892dcd54864dc6880a04`;
- `android-api36-three-button-release-post-fix-light.png`, SHA-256
  `6db789b8243a4e9524f3999af055d8406bb3503e33fab6549a6918683346d865`;
- `android-api36-three-button-release-post-fix-dark.png`, SHA-256
  `5d1833d9023fbcb041024e20aec08343f93dca5d71cde26a5ac54ec15fc0dcdb`.

The environment record reads Android 16/API 36, `navigation_mode=0`, with only
the three-button overlay enabled. Both screenshots visibly show Back, Home,
and Overview: dark icons on the light surface and light icons on the dark
surface. This closes the observed system-icon contrast defect on that AVD.

Post-fix application-state smoke also passed in API 36 gesture and three-button
modes. The logs are
`android-api36-gesture-post-system-ui-fix-smoke.log` (SHA-256
`b2aa065189bf5a0ac154e792d7e8fe34d4b347fc8d60179cb1ae62b10940d319`) and
`android-api36-three-button-post-system-ui-fix-smoke.log` (SHA-256
`764502d921113f247350d489ee9125e36aa9f79cb63df4b2886f7f73ef010563`).
The gesture run is independently tied to `navigation_mode=2`, the gestural
overlay, its debug APK, source bytes, command, time, and result by
`android-api36-gesture-post-system-ui-fix-environment.txt` (SHA-256
`ccf3c2db529a4b37701868420ff52924234f2f7b710438b79fcfb6d66370514d`).

The clean pass closes application-state smoke under three-button navigation;
the earlier incomplete attempt remains for provenance. The later final review
also passed representative gesture/three-button system bars, the centered
display cutout, AppBar/form safe areas and visible-IME resizing. It preserves
1080x2400 screenshots plus raw inset and overlay records and restores the AVD
to gesture navigation afterward.

A later current-source API 36 run added a system-input predictive-back precheck.
The raw Emulator-console recordings visibly contain gesture start, system
progress, cancellation that remains on Theme, and completion that returns one
route to Settings. The source WebM, H.264 MP4, progress/result PNG, exact
environment, release APK identity, and hashes are indexed by
`android-api36-predictive-back-system-input-precheck.txt`. That record is
supplementary: its gesture was injected as Android system input and is not the
accepted manual proof. A later native-window human-mouse run independently
passed start, visible progress, cancellation and exactly one completed pop.
The accepted observation, native-window captures and the rejected low-frame-rate
device-recording boundary are documented in
[`android-api36-predictive-back-human-mouse.md`](android-api36-predictive-back-human-mouse.md).

The final current-source API 36 Foundation integration run passed and is saved
as `android-api36-final-foundation-smoke.log`, SHA-256
`0f159971b1eb94774476f3f0b5fa715069e4768e55b9d7a7399f0b9f77536e44`.
The release APK was restored and rendered the Dark privacy gate in
`android-api36-final-release-privacy-gate.png`, SHA-256
`807367b110857ebc97c78f64051528ecadadc6f511159059f28eaa2a7b60407e`.

## Android API 34 emulator

The official `system-images;android-34;google_apis;arm64-v8a` revision 14 image
was installed and registered with the Android SDK. Its source ZIP size is
1,610,393,229 bytes and its SHA-1 is
`2fe8b46d419a3400e30f31b0152b241b50c8b99f`, matching the checksum published
in the Google SDK repository metadata. The AVD is `Admin9_API_34` on
`emulator-5556`.

| Field | Value |
| --- | --- |
| API / build | 34 / Android 14 `UE1A.230829.050` |
| Device family | `sdk_gphone64_arm64` / Pixel 7 profile |
| Display | 1080x2400 pixels at 420dpi |
| Navigation | Gesture, `navigation_mode=2` |
| Predictive-back setting | `enable_back_animation=1` |
| Renderer for passing run | Host GPU, Apple M1 Pro |

The first smoke attempt used the emulator's software renderer after a host
memory-pressure fallback. The App remained on the Android starting window and
the test was interrupted as `did not complete`; that attempt is not a pass. A
later repeat after an existing run also remained on that window; its preserved
log is `android-api34-repeat-not-complete.log` (SHA-256
`436eacba2e361e1a0e2c9cbbbfecc3b3bfeef34396d3e9ccc9a584f0bb5fe53d`).

After other simulators were shut down, the dedicated AVD was wiped and restarted
with `-gpu host`. The clean run completed with `All tests passed!`:

```bash
flutter test integration_test/foundation_smoke_test.dart \
  -d emulator-5556 -r expanded \
  --file-reporter \
  expanded:docs/architecture/evidence/admin9-ui-phase-6/android-api34-foundation-smoke.log
```

The passing log SHA-256 is
`54eb19298e4edae804298b801fc543190ea92b8ef344786b7a55e53a1d6300da`.
It proves build, install, App launch, and ordinary application state transitions
on API 34. It does not prove predictive-back gesture start, visible progress,
cancellation, or completion.

After the system-UI fix, the same API 34 application-state smoke passed again.
`android-api34-post-system-ui-fix-smoke.log` has SHA-256
`6707da510d1e485722af3752b21e64a01bfd95173550c166c7daa01abcc3d0d7`.

The AVD later restarted on `emulator-5554`. A final release-plugin regression
first ran the integration test so Flutter's generated Java registrant again
contained both the dev `integration_test` plugin and production
`shared_preferences_android`. The Foundation smoke passed, then the release
plugin validator self-test and repository validation passed, and release was
rebuilt, installed, cleared and cold-launched. The running process was PID
`5000`; logcat contained the normal Impeller startup line and no
`MissingPlugin`, `IntegrationTestPlugin` or fatal exception. The release APK is
51,598,161 bytes with SHA-256
`279f44977c21a8b7aa9e060e97f66c65bea8c0bd1667b125ef67052d39a41dd9`.

- `android-api34-foundation-smoke-after-release-registry-fix.log`, SHA-256
  `97195db367e2d23728bb5612ce983124abe8e642f14a30fa3d4026d6e4ffcf38`;
- `android-api34-release-registry-fix-privacy-gate.png`, 1080x2400 pixels,
  SHA-256
  `9a7c0ddc9b1be2e8ac79b89accf93da106169b0fa1a1fd987db110b3b9f40074`.

This chain proves the production-plugin release workaround after the exact
integration-test pollution sequence. It does not prove predictive-back gesture
progress or any physical-device behavior.

A later current-source API 34 run passed (`1` integration test) and is saved as
`android-api34-final-foundation-smoke.log`, SHA-256
`d0732ce4c5ee5eac440799e54767777f270fd212d8760d3de177a5b99d94044a`.
The restored release APK has SHA-256
`d6765958320a271272fe68437113e4db9e35537e348de884f3009d1f456f1326`
and rendered the Light privacy gate in
`android-api34-final-release-current.png`, SHA-256
`e40823ac06e20709091717967caa87f1035b7617d3804d6674636d9659926b76`.

The same session added a system-input predictive-back precheck. Its raw
Emulator-console recordings visibly contain system start and progress,
cancellation that remains on Theme, and completion that returns one route to
Settings. The WebM/MP4/PNG hashes, AVD identity, release identity, input
boundary and actual results are recorded in
`android-api34-predictive-back-system-input-precheck.txt`. Like the API 36
precheck, this is supplementary system-input evidence rather than the required
independent human mouse/finger drag. The API 34 gate was still open at this
checkpoint and is closed by the later native-mouse record indexed below.

Two later `scrcpy` setup recordings are explicitly rejected as predictive-back
evidence. `android-api34-predictive-back-rejected-no-gesture.mp4` contains only
the mirror setup (2,290,223 bytes, SHA-256
`27ce386e6c21326b327f4b8d5f2e1be379253344460a780ba376e7331668b263`).
`android-api34-predictive-back-rejected-mac-locked.mp4` was recorded while the
Mac was locked and contains no reviewed gesture (6,915,931 bytes, SHA-256
`aff9d77e3439d760d9dd1f3cc68167d6534cdff2fcacc10c369687e5260fe633`).
Neither file closes start, visible progress, cancel or complete.

## iOS simulator matrix

| Device | Runtime | Pixels | Logical canvas | Result |
| --- | --- | --- | --- | --- |
| iPhone 17e `C10E0968-4695-4C02-BC55-8C322531239A` | iOS 26.5 | 1170x2532 at 3x | 390x844pt | Post-system-UI-fix Foundation smoke passed |
| iPhone 17 Pro `0E2E19C6-FD8F-484A-9712-584A1B233A55` | iOS 26.5 | 1206x2622 at 3x | 402x874pt | Post-system-UI-fix Foundation smoke passed |

Both current-working-tree runs used the same command shape with their recorded
device identifier. Their preserved transcripts report `All tests passed!`:

- `ios-26.5/iphone-17e-post-system-ui-fix-smoke.log`, SHA-256
  `7cd07df50d36eae00005de4898fb2cdc53f7aaebe6a8b19d6addd9d09d8ed79f`;
- `ios-26.5/iphone-17-pro-post-system-ui-fix-smoke.log`, SHA-256
  `8c6e006382f66d7f3a482d8b9859318d53316c3d4629d2cdef472ac2a7748cf7`.

The iPhone 17 Pro command was:

```bash
xcrun simctl boot 0E2E19C6-FD8F-484A-9712-584A1B233A55
xcrun simctl bootstatus 0E2E19C6-FD8F-484A-9712-584A1B233A55 -b
flutter test integration_test/foundation_smoke_test.dart \
  -d 0E2E19C6-FD8F-484A-9712-584A1B233A55 -r expanded
```

The earlier screenshot
`ios-26.5/iphone-17-pro-foundation-smoke.png` shows the normal simulator build
at the privacy gate after the pre-fix session. The normal build was produced with
`flutter build ios --simulator`, installed with `xcrun simctl install`, and
launched with `xcrun simctl launch`. Its SHA-256 is
`dcaba26a6b65f8b2bda3044e759968dd866b6de588de82302ddd8ca0deff7012`.
It proves only that earlier model canvas and normal App launch state. The new
transcripts close the missing simulator smoke record for the post-fix working
tree; neither transcript proves VoiceOver, Switch Control, physical-device
rendering, human edge-back gestures, or visual system-bar correctness.

## Physical iPhone signed delivery provenance

| Field | Value |
| --- | --- |
| Reviewed HEAD | `a31227b014ac5d5564735552c4e30851eca8707e` |
| Device | Qiyue iPhone, iPhone 17 Pro Max, iOS 26.5.2 |
| CoreDevice ID | `44C6E299-C645-56DD-8A6F-6E03EE2B631E` |
| Hardware UDID | `00008150-000268290C44401C` |
| Bundle | `com.admin9.app.foundation`, 1.0.0 (1), minimum iOS 13.0 |
| Team / authority | `J25XZRW743` / `Apple Development: qiyue feng (252TTDSH8C)` |
| Signed time | 2026-07-30 06:47:48 +0800 |
| Runner SHA-256 | `89f6910268bb8b8dca9874b66f4a7338887dd7b79617f0e02b1e68dd609c849b` |
| Info.plist SHA-256 | `81a9361e8c033fa426f36287a73aa55f7ba64edd264c60c4f6421713656c73d8` |
| CodeResources SHA-256 | `27892573611f8a9a6315f9201d30c85916a6a85f054a6d1624c1eb1c97743ac4` |
| Full CDHash | `735d500e619baad3a09a610599dfcc5dc24cffdf0713e4e7348b6d5a1bac2fa2` |
| Installation URL | `file:///private/var/containers/Bundle/Application/3CB38C73-C030-4832-B29E-8A50FC725E22/Runner.app/` |
| Install JSON SHA-256 | `994cc3be0cad31a59839a26afa773f0ba7eba559d240eaa2d46ba386f026fa5c` |
| Install log SHA-256 | `f8f00cd9dd9cbf227b42c44c738b4cf4b19b02d3d390609b438dfe1d37a73ddd` |

Build, signature verification, and installation commands:

```bash
flutter build ios --release
codesign --verify --deep --strict --verbose=2 build/ios/iphoneos/Runner.app
codesign -dv --verbose=4 build/ios/iphoneos/Runner.app
shasum -a 256 build/ios/iphoneos/Runner.app/Runner \
  build/ios/iphoneos/Runner.app/Info.plist \
  build/ios/iphoneos/Runner.app/_CodeSignature/CodeResources
xcrun devicectl device install app \
  --device 44C6E299-C645-56DD-8A6F-6E03EE2B631E \
  --json-output docs/architecture/evidence/admin9-ui-phase-6/physical-iphone-install.json \
  --log-output docs/architecture/evidence/admin9-ui-phase-6/physical-iphone-install.log \
  build/ios/iphoneos/Runner.app
```

The build succeeded, `codesign` reported `valid on disk` and `satisfies its
Designated Requirement`, and the preserved `devicectl` JSON reports `success`,
the exact input App path, device identifier, bundle identifier, and installation
URL above.

This signed installation predates the uncommitted system-UI source fix. It is
valid provenance for the Phase 5 HEAD build only and is no longer sufficient as
the final Phase 6 delivery artifact. A final signed rebuild, install, unlocked
cold launch, and process-path query are required after the code and all device
gates are accepted.

All four cold-launch attempts are **not passes**. The device rejected them with
`FBSOpenApplicationErrorDomain error 7` because the phone was locked. The second
and third attempts reused `physical-iphone-launch.*`, so the third replaced the
second record. Three record pairs remain. A launch after unlocking, followed by
a process-path query tied to the installation URL, is still required. This
delivery record does not prove any human-operated accessibility, input, or
gesture gate.

The rejected launch is preserved as
`physical-iphone-launch-locked.json` (SHA-256
`f64fa26f42604e9f13bc4bfe7f4df87276b3052d08ebed46f654075e62eb7a5b`)
and `physical-iphone-launch-locked.log` (SHA-256
`e2188a2ef3958efd32a40a10c21af27c600974fc0a592819d35e11008c729bf9`).

The latest rejected attempt is preserved as `physical-iphone-launch.json`
(SHA-256
`824ef908c2d11572bbec9834dcb2dfb2810200d1b8cb19e353548e4fd6778f56`)
and `physical-iphone-launch.log` (SHA-256
`3bb511156c94a0239f30fd1592e3e25072f5c9ee4515bf751983053990080b54`).

The fourth rejected attempt is preserved as
`physical-iphone-launch-unlock-retry.json` (SHA-256
`524682918ae07074c24d6e4ebe9209beb67a39386e02e4bf659820f19ba5ce52`)
and `physical-iphone-launch-unlock-retry.log` (SHA-256
`e2167afec0c5c3e9b1ff04f09cdece1b90f7be1e3f41cda4f5d38e899564d96c`).

## Earlier Phase 6 physical iPhone delivery

The device became available and unlocked later on 2026-07-30. A release was
rebuilt and signed after the system-UI fix, then installed and cold-launched.
This lane predates the later root Grayscale focus fix and is retained as valid
signed-delivery provenance rather than the accepted final artifact:

| Field | Final delivery value |
| --- | --- |
| Working-tree base HEAD | `a31227b014ac5d5564735552c4e30851eca8707e` plus the documented unstaged Phase 6 system-UI fix |
| Device | Qiyue iPhone, iPhone 17 Pro Max, iOS 26.5.2 |
| Bundle | `com.admin9.app.foundation`, minimum iOS 13.0 |
| Team / authority | `J25XZRW743` / `Apple Development: qiyue feng (252TTDSH8C)` |
| Signed time | 2026-07-30 11:53:49 +0800 |
| Runner bytes / SHA-256 | 281,632 / `3722ce6dc8bbec49570e73b17c055115c2373b1810aba46c85264afb10b064e3` |
| Info.plist SHA-256 | `81a9361e8c033fa426f36287a73aa55f7ba64edd264c60c4f6421713656c73d8` |
| CodeResources SHA-256 | `e48458f4bc0401ce81dea64f7ee36549b49890604479fe0c4b533e207059de2f` |
| Full CDHash | `1b35b61e3be7b27787aab8a74047135445edde5ac17dddc2bb8779aa9eb16aad` |
| Installation URL | `file:///private/var/containers/Bundle/Application/683C7D96-1548-42EA-A669-161976FC662F/Runner.app/` |
| Running executable / PID | matching installation URL plus `Runner`; PID `24765` |

`codesign --verify --deep --strict` reported `valid on disk` and `satisfies its
Designated Requirement`. The final `devicectl` installation, unlocked cold
launch, and running-process query all returned success. Their records are:

- `physical-iphone-delivery-install.json`, SHA-256
  `bb80ff4624ee5c41025396bb3bf64f3a8f2291a5715c4ad848f15250de29e50a`;
- `physical-iphone-delivery-install.log`, SHA-256
  `837733430832d7d9e3a2b3dcb93bebd4ee35e65ac92cef1001576c702429acf3`;
- `physical-iphone-delivery-launch.json`, SHA-256
  `15c5ea54c1cc6d504bc9e0340c0516588e5981129b9fe765aef952ca1006eb7e`;
- `physical-iphone-delivery-launch.log`, SHA-256
  `3700f14ee7dcfd353f7ded2c39208d5fc5660ca7e6503b7c4926d3a2bf529099`;
- `physical-iphone-delivery-process-all.json`, SHA-256
  `7632db41a1329eeb974c57d4b890b279f8ec4b6077842cd95ed223bf0ec7c091`;
- `physical-iphone-delivery-process-all.log`, SHA-256
  `99abba10056282bc615769e7c055406c6336268345e00608312f6d107af93be4`.

This closes build, signature, installation, unlocked cold launch, and
process-provenance for that earlier source state. It does not close the final
source artifact, Foundation integration, VoiceOver, Switch Control, Dynamic
Type, platform gesture, physical hit-target, real input, or full visual-flow
acceptance.

Two later physical Foundation attempts against the final source did not pass.
`physical-iphone-final-foundation-smoke.log`, SHA-256
`10a453e290a682812fc04ef35474c8f11e053a8f184dd13d47a2f5bfe3a9b8ec`,
failed to start the Xcode debug session. The retry,
`physical-iphone-final-foundation-smoke-retry.log`, SHA-256
`17513929b1f45bb3f738b9b11e4d83f9bf28fded27dd454828d8b88b1703256c`,
did not discover the Dart VM Service after 75 seconds. Both are failure records.
That statement is retained as history for the failed attempts. A later final
source build completed the signed-delivery lane described below.

The files named `physical-iphone-final-install.*`,
`physical-iphone-final-launch-unlocked.*`, and
`physical-iphone-final-process*.*` are an intermediate, superseded delivery
attempt. Their JSON shows installation and launch success for installation URL
`7A9BB743-46E3-4D0C-8025-3F1A67F4F7C3`, but the attempt has no preserved source
state, signed-artifact hash, or complete process-provenance binding; the filtered
process query is empty. These files MUST NOT be used to close the final-source
delivery gate despite the word `final` in their filenames. The later
`physical-iphone-delivery-*` chain above is the fully bound pre-Grayscale-fix
delivery evidence. It is superseded by the fully bound final-source chain
below.

## Final-source physical iPhone delivery

The current Phase 6 source was rebuilt with `flutter build ios --release`,
automatically signed by Team `J25XZRW743`, verified with strict `codesign`,
installed on the unlocked iPhone, cold-launched with `--terminate-existing`,
and bound to its exact installation URL by the device process inventory.

| Field | Value |
| --- | --- |
| Device | Qiyue iPhone, iPhone 17 Pro Max, iOS 26.5.2 |
| Runner bytes / SHA-256 | 281,632 / `38ba0d654385fd3056591e20b46f436a7d644fff9c86af556ba1d468615ef3a1` |
| Full CDHash | `ba15ded10892924887028748921cae422ed48289567333f37a9fce678ca0e771` |
| Installation URL | `file:///private/var/containers/Bundle/Application/5F4DB1C7-61E8-4931-98C8-D8E3BBBEE674/Runner.app/` |
| Running executable / PID | matching installation URL plus `Runner` / `26739` |

The exact signature, artifact and raw-record hashes are in
[`physical-iphone-v102-provenance.md`](physical-iphone-v102-provenance.md).
This older artifact closes its signed build, install, unlocked cold launch and
process binding only. Its human gates were still open at that checkpoint; the
accepted candidate and human results are recorded in the next section.

## Accepted Phase 6 final candidate

The authentication unavailable result subsequently gained a page-level live
region and an Android/iOS semantics regression. That additive reader-sensitive
change invalidated the word `final` for the artifacts above. Both release
artifacts were rebuilt, the Android APK was installed/cold-started and pulled
back with an identical hash, and the iOS App was strictly signature-verified,
installed, cold-started and bound to its new process path.

The exact source manifest, artifact hashes, install paths and evidence boundary
are recorded in
[`phase6-final-candidate-provenance.md`](phase6-final-candidate-provenance.md).
The accepted candidate hashes are Android
`aa2deda938ead8b1e9644c1210cc5c7a9b3b0c8356ccff43825c7744a2767995`
and iOS Runner
`89fc6f98e42089afa592e3f3ba0515fe2935e5744de83dbdd475372bf03db209`.
The Android final install/pull identity is recorded in
`physical-android-api30-v102-final-provenance.md`. The iPhone selected-state,
VoiceOver, real IME, App Extra Large safe-area and edge-back observations pass
in `physical-iphone-v102-human-acceptance.md`.

## Physical Android API 29 compatibility lane

A Xiaomi `M2007J22C` (`cannon`) running Android 10 / API 29 became available
over authorized USB debugging. This is physical Android evidence, but it is not
a current-version Android device and cannot replace the API 34/API 36 gesture
or current-version hardware gates.

The Foundation integration smoke passed against the current Phase 6 working
tree (`1` test, `All tests passed!`). Its transcript is
`physical-android-api29-foundation-smoke.log`, SHA-256
`aa8aea156e2334d148bef7244c14356a58eaf3de4cdb9df3e01acb8ece1014b3`.
The run proves build, debug installation, launch, and the automated Foundation
state assertions on this physical API 29 device.

The environment record is `physical-android-api29-environment.txt`. It records
1080x2340 pixels at 440dpi, system font scale `1.0`, no enabled accessibility
service, and the real Xiaomi Sogou IME
`com.sohu.inputmethod.sogou.xiaomi/.SogouIME`. Its SHA-256 is
`e1f67b21c4b7c81a27396ab2b4bd2695a58cae3a127fb4bfea9540dd3a6a8ac9`.

Two initial release installation attempts were rejected by MIUI with
`INSTALL_FAILED_USER_RESTRICTED`. The second rejected attempt remains as
provenance in `physical-android-api29-release-install-attempt.txt`, SHA-256
`0220799175e6b5ab8b6b6e2687ca611fd9e02bfba38e3597e5568748cad29085`.
After the user authorized USB installation, the same reviewed release installed
successfully and cold-launched. The installed `base.apk` is 51,598,161 bytes and
its SHA-256 exactly matches the local release APK:
`192d27fd82585d4a47cc06e8e7b8259c088ed7346d7e17d3c5030fa9642d2a80`.
The provenance record is `physical-android-api29-release-provenance.txt`,
SHA-256
`9b14a617bd22af4e4c3c034301ad70d0451f43e50eb9171bada9510a3f0eb38e`.

The physical walkthrough covered light appearance, 2.0 system font scale,
guest account and login layout, real Sogou IME resizing, MIUI's password
security keyboard boundary, the theme selection page, immediate Dark
appearance, persistence after process restart, and a clean release first launch
at the privacy gate. The walkthrough record is
`physical-android-api29-visual-input-walkthrough.txt`, SHA-256
`9603d16087cedc56b630c91a20ecbee8bca8333a6dca52c1dbe4332aaa6d22d7`.

A second evidence chain binds the previously separate observations to exact
runtime state. `physical-android-api29-system-2x-app-standard-transcript.txt`
records `font_scale=2.0`, while the matching Settings capture visibly reports
App font size `Standard`. The Home and Account captures were taken without
changing either setting. The Dark persistence transcript records the same
system font scale, `am force-stop`, a cold `am start -W`, the running App PID,
and the App's `MainActivity` task. Its post-start screenshot remains Dark. The
MIUI command sometimes reports the Launcher as the waited activity, so the PID
and activity-task lines are retained as the authoritative process binding.

Temporary system font and stay-awake settings were restored to `1.0` and `0`,
and the App theme was restored to `Follow system`. The restoration transcript
is `physical-android-api29-device-restoration.txt`.

All Android API 29 PNG assets are 1080x2340 pixels:

| Asset | SHA-256 |
| --- | --- |
| `physical-android-api29-release-light.png` | `8330945997f7a80e95d13231dafc1c009c757efb66d362466651d7d040f68019` |
| `physical-android-api29-account.png` | `3b73cdbe2c400df72817f23b52b22a8f1f4d71968312381d1dc0ee607d9d8afd` |
| `physical-android-api29-font-scale-2x-home.png` | `bf33f9ddc94cc5d6080ac78ccc9dabf71964674ccda216a836c1df5cbbd314ef` |
| `physical-android-api29-font-scale-2x-account.png` | `e01a569cb0e96a9cb3293fc34ded2b945aa3e8d78dfde70ac814fb6c6a947a21` |
| `physical-android-api29-font-scale-2x-login.png` | `081ced23e89f3e2d554f227bab3ec614d4cb650b3bf7f0340dc5862d6feae4af` |
| `physical-android-api29-font-scale-2x-login-ime.png` | `3c553321847c2bfc92b4bae644eaa9429ad2ba54238cfe45909e97c67b6a24b8` |
| `physical-android-api29-font-scale-2x-login-filled.png` | `1c0e9722cd786a8e3c1e87f8f87bd9b4920b866ef5f9f834ef5660cd1f07963d` |
| `physical-android-api29-settings-light.png` | `e0c21231784c3b6df3b98aea573a3c4c1f1c8da8bf285c7c28ca29e7ce233b33` |
| `physical-android-api29-theme-picker.png` | `6d95582cbab175821e8e71d37a2fa6117f67f83de3a915a88f2f7a8c04adc6f6` |
| `physical-android-api29-settings-dark.png` | `7c0dc7f494b98fd6e7137a99015587725babe0cce738f263cd6021b50703f502` |
| `physical-android-api29-dark-persisted-restart.png` | `ddf4b3ae2cef41b1e3eee521ad4fa9a6ece5981f780597725bd1b87529d4075a` |
| `physical-android-api29-clean-release-privacy-gate.png` | `1e8993ff26620ce4b37c23dcc89e9665e802b9ee9eb482f8e31d2a059a6ac3ca` |
| `physical-android-api29-system-2x-app-standard-home.png` | `05c84615c50f7fb85ea286fe4fb5b53f95196eda05fd0418af5a4d816cb0f75a` |
| `physical-android-api29-system-2x-app-standard-account.png` | `ee39b09b4b1f98f71882819612d41d8c7b87ff5a49b8eb251973d04b8c92bc12` |
| `physical-android-api29-system-2x-app-standard-settings.png` | `27147828e23e96d148cfdb884206712109be9e15097a9efaf46530219394dfa7` |
| `physical-android-api29-dark-immediate-system-2x.png` | `281ea97a8022cbe3bb441a80a9d20a7341a0c54d0feb6070c10aeadb6b181e91` |
| `physical-android-api29-dark-after-restart-system-2x.png` | `5b82743f8d0066222dae0d55379e468b793f41084af1f616f28256b510f96e9f` |

The state-binding transcripts have these SHA-256 values:

| Transcript | SHA-256 |
| --- | --- |
| `physical-android-api29-system-2x-app-standard-transcript.txt` | `19f5192b9653e6a62e44bed37f9d2fbbb34fbb8ac9b20c02983ef2b2a1fd8e84` |
| `physical-android-api29-dark-persistence-transcript.txt` | `b81d68e8a32d76f3c0d5db06ca73b6be47c6866a238e5a355e008ae2fe9582f9` |
| `physical-android-api29-device-restoration.txt` | `fb0df7877cb7efe8d84ed5721e0b5af1f158a03c445ef2aa5605e7902f5b358d` |

This lane proves older physical-hardware compatibility and the listed visual
and real-input observations. It does not prove current-version Android,
TalkBack, Switch Access, autofill/password manager, external keyboard,
physical hit-target measurement, or predictive-back behavior.

## Physical Android API 30 upgrade lane

The same Xiaomi `M2007J22C` was upgraded to Android 11 / API 30 while retaining
ADB serial `r8ovcmxwberwtoau`. Flutter detected it as an authorized physical
device. `persist.security.adbinstall=1`, `install_non_market_apps=1`,
`device_provisioned=1`, and `user_setup_complete=1` were observed. MIUI still
requires a physical tap on the left-side `Continue installation` button for
each USB install; ADB-injected taps are rejected by the security dialog.

The first API 30 Foundation attempt failed before App launch with
`INSTALL_FAILED_USER_RESTRICTED: Install canceled by user`. Its failure-only
transcript is `physical-android-api30-install-restricted-attempt.log`, SHA-256
`871344d5f99feeea64363a1efa1673146529a7717009a2e0687a215d6dd5b7ee`.
That rejected attempt remains provenance and is not a pass.

After the user accepted MIUI's physical install confirmation, the API 30
Foundation smoke passed (`1` integration test, `All tests passed!`). Its log is
`physical-android-api30-foundation-smoke.log`, SHA-256
`8274aebda7b6e9e6544451012bb0058f2b123504eae34f17a8bf810a5082abfb`.
The then-reviewed release was installed, cleared and cold-launched; the local
and installed APK hashes both equal
`279f44977c21a8b7aa9e060e97f66c65bea8c0bd1667b125ef67052d39a41dd9`.
The exact device/build, package path and launch result are recorded in
`physical-android-api30-release-provenance.txt`, SHA-256
`842155daaea58b78f1d3c65628dc48877c8202ecb06a4e871bc3ff10c025339c`.

The physical walkthrough also recorded the clean privacy gate, Light/Dark and
App Extra Large persistence, large-text plus App Extra Large layouts through
scroll endpoints, and the real-device input boundary. The App setting is
visible in the captured Settings page, but no raw API 30 `font_scale=2.0`
record was preserved, so this lane does not claim an exact system multiplier.
Those assets prove the visible states they contain; they do not prove spoken output, Switch Access,
autofill/password-manager behavior, external-keyboard behavior, or physical
hit-target measurement.

A partial human TalkBack walkthrough is preserved in
`physical-android-api30-talkback-transcript.md`. It confirms bottom navigation,
guest identity, Login/Register, Settings entry and return, Theme radio state,
the Theme current value, a Grayscale switch, the privacy gate, Home/Mine,
Register field order, password visibility state and first-error focus. During
the first Grayscale off transition, replacing the root `ColorFiltered` moved
TalkBack focus to Back. The root filter now remains mounted with an identity
matrix while off; automated tests lock element identity and switch semantics.
The representative Settings switch evidence is accepted under the v1.0.2
risk-tier policy; repeating every switch is P2 backlog.

The final Android artifact includes the subsequent privacy-transition P1 fix.
The local APK and pulled Xiaomi `base.apk` both hash to
`fc43800cd9cd0553ef3b708a0b646f37b520e980b9bdfaba43c618e837b134aa`
at 51,598,161 bytes. Installation, clear-data cold launch and TalkBack's
immediate `已进入首页` output after one consent activation passed.
`physical-android-api30-final-release-provenance.txt` binds the command results,
human result and these screenshots:

- `physical-android-api30-final-release-privacy-gate.png`;
- `physical-android-api30-final-release-home-after-privacy-announcement.png`.

No `uiautomator` command was used in that final reader run. The separate
`physical-android-api30-real-ime-transcript.md` records a passing representative
real-keyboard flow: Next moved focus from Account to New password, Done dismissed
the keyboard and the App preserved input while showing the truthful
service-unavailable boundary. Switch Access, password-manager, external
keyboard, every-page and every-component reader repetition are P2 backlog, not
Pass.

Android 14+ physical-device evidence remains a separate `Unknown`. API 34/API
36 simulator results cover only their explicitly documented emulator lanes.

Current API 30 evidence hashes are listed below. The `system-2x` filename stem
is historical and MUST NOT be treated as proof of an exact system multiplier;
the missing raw `font_scale` record controls the claim.

| Asset | SHA-256 |
| --- | --- |
| `physical-android-api30-foundation-smoke.log` | `8274aebda7b6e9e6544451012bb0058f2b123504eae34f17a8bf810a5082abfb` |
| `physical-android-api30-real-ime-next-ready.png` | `a20447be132486c6065f431470e7bcbde387e3ddd9fb54c4cecfbaa551888ee9` |
| `physical-android-api30-real-ime-done-result.png` | `87ae9443f594714d2435219013848bd2ba11e0e28daec7c90c236feec961db48` |
| `physical-android-api30-install-restricted-attempt.log` | `871344d5f99feeea64363a1efa1673146529a7717009a2e0687a215d6dd5b7ee` |
| `physical-android-api30-registration-real-ime-unavailable.png` | `d1acb56d1c732ed6a5c96d8f061bfc7d4da5115037b321f31a43eb3812a2d7c9` |
| `physical-android-api30-release-dark-extra-large-accessibility.png` | `1d2ac54a7d268a7dbe93e00a7600b840dbfa3292e27c753a011728834fb62cbe` |
| `physical-android-api30-release-dark-extra-large-after-restart.png` | `d3b880fb2468b147546f07a829d1fa1b277475c9c22037a200760d12cfb81d70` |
| `physical-android-api30-release-persistence.txt` | `904a1091613089bda5fbdf1a021312bafb854bcc5ef7c3432372b3cccf841368` |
| `physical-android-api30-release-privacy-gate.png` | `2fa2c7bc53ec15926f3de1ce7d6d5ee5bf90ec715f717ff2898349471a9c456c` |
| `physical-android-api30-release-privacy-gate.xml` | `9ed68c1c06e89e78d8d297422ee540a6fb16632260a8693087688716281a9e99` |
| `physical-android-api30-release-provenance.txt` | `842155daaea58b78f1d3c65628dc48877c8202ecb06a4e871bc3ff10c025339c` |
| `physical-android-api30-system-2x-app-extra-large-home.png` | `b4ac9e3a13fecef9bf7b370e63e173dc6bed3a6f274dcd7a14e251483c5f2611` |
| `physical-android-api30-system-2x-app-extra-large-mine-end.png` | `b90e06980142cd6ef2ae384b1d4ec9d5740528dff1d8beb862865dfed746609a` |
| `physical-android-api30-system-2x-app-extra-large-mine.png` | `422b894170117812b73e1c3e700b73e73fa6ba1c865d8aa7a80eaf7c6b2a0248` |
| `physical-android-api30-system-2x-app-extra-large-settings-end.png` | `290ee26d68d988b509535a220fc1d3edf698d80576a0bd6f5ec060536a0af2e5` |
| `physical-android-api30-system-2x-app-extra-large-settings.png` | `ee316be5be67800eb369940e47002182b4e3e97d6327da9fa5822bca9676b1ab` |
| `physical-android-api30-talkback-app-font-focus.png` | `bc0ba4d3aea911994eb7f33a37e779796582fa1f0d3034aa04fa0567c9f3c6be` |
| `physical-android-api30-talkback-bottom-nav-mine-unselected.png` | `19b0998bbf35f0507a1ee2d8fd85e99d962348d665b0409f6da295992aa09496` |
| `physical-android-api30-talkback-grayscale-off.png` | `87679f679885edf569182c11c7ed373eb49552ce542288c39cb2537a694d849d` |
| `physical-android-api30-talkback-grayscale-on.png` | `ad5cfda9f87c6a99aa6d1b39a8ffce0802fa3d3b5f2f49561be4c26bd2a3a7ed` |
| `physical-android-api30-talkback-login-focus.png` | `308fbbc81fcb4f7b404253e178a5b880bc09990ce1e1e92a34bd75a08c0c4ca4` |
| `physical-android-api30-talkback-mine-selected.png` | `54ff7baf4c9c038f7e96abb3a273d8ab2aa2cb8bcb74940c06bb7f72761b04de` |
| `physical-android-api30-talkback-settings-back-focus.png` | `d235c6c6777a9f7d764f37cc6c3658dea0272934fe5602a22603b750c68df34f` |
| `physical-android-api30-talkback-settings-focus.png` | `ce562f218fe3841b42637510f952ee1f1e0ce394a286bcf24b33589d4aa67e70` |
| `physical-android-api30-talkback-settings-row-focus.png` | `35bb0d18702945920e82a43bf4a4cfb40f8c094d1f94cacda0cbb512e8d2d648` |
| `physical-android-api30-talkback-theme-row-focus.png` | `1a359201dd578b38f0bfe1684a61af6c6e54197a53992064c10fc2afe091d8eb` |
| `physical-android-api30-talkback-theme-system-unselected.png` | `6bdf38c375d7e6d667abbd66cf1a2cb364c74f8b4f16d3ffa8843228f8f49bae` |
| `physical-android-api30-talkback-transcript.md` | `910c84a1c4f29998d31d09bee3a927525efdd636ac679d69bc94df04815ca6d3` |

## Remaining non-blocking Unknown and backlog

The executable human-review sequence and required evidence fields are fixed in
[`manual-device-acceptance-checklist.md`](manual-device-acceptance-checklist.md).

- Android 14+ physical-device evidence remains separately `Unknown`; API 34 and
  API 36 emulator system-version gates do not manufacture hardware proof.
- Switch Access/Control, password-manager/autofill, external-keyboard and
  exhaustive per-page/per-control reader repetition remain tracked P2 backlog,
  not `Pass` and not release blockers while the representative flows remain
  usable.
