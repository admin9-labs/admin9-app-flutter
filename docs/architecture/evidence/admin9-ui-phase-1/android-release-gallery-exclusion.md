# Android release Gallery exclusion evidence

> Evidence date: 2026-07-29
> Device: Android Emulator `sdk_gphone64_arm64`, Android 16 / API 36, `emulator-5554`
> Artifact: `build/app/outputs/flutter-apk/app-release.apk`

The release APK and the installed `base.apk` both had SHA-256:

```text
b74275090570f1bc1c8d94a1e0d6519940691ded29813f8a2d9b1933b451c4f7
```

The package resolver exposed only `android.intent.action.MAIN` with `android.intent.category.LAUNCHER`. Queries for `android.intent.action.VIEW` with `android.intent.category.BROWSABLE` returned `No activities found`; the App has no external deep-link contract.

After a cold launch, the UI hierarchy showed the privacy gate. The `同意并继续` action was activated, then a second hierarchy was captured from the reachable main Shell. Its interactive navigation contained exactly:

- `首页`, selected, item 1 of 2;
- `我的`, not selected, item 2 of 2.

The reachable Shell contained no Gallery label, menu, action, or externally addressable route. This is release-package evidence, not a claim about debug/profile behavior.

Commands used, with the SDK-owned `adb` binary:

```text
flutter build apk --release
adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-release.apk
adb -s emulator-5554 shell pm path com.admin9.app.foundation
adb -s emulator-5554 shell uiautomator dump /sdcard/admin9-window.xml
adb -s emulator-5554 shell input tap 540 1521
adb -s emulator-5554 shell uiautomator dump /sdcard/admin9-shell.xml
adb -s emulator-5554 shell cat /sdcard/admin9-shell.xml
```

The tap coordinate was derived from the first hierarchy's `同意并继续` bounds. It is evidence capture for this emulator only, not a reusable UI test locator.
