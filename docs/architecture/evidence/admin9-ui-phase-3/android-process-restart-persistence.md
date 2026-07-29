# Android Phase 3 process-restart persistence evidence

Date: 2026-07-30 (Asia/Shanghai)

This is device evidence from the normal debug application, not an integration-test host reconstruction and not release-package evidence.

## Environment

- Device: `sdk_gphone64_arm64`
- Android: API 36
- Physical canvas: `1080x2400`, density `420`
- APK SHA-256: `2c46d48cca0acfce16959bfbedd9c45517fa67d7c8c166265dd312efb8ec215d`
- Package: `com.admin9.app.foundation`

## Procedure and result

1. Built `build/app/outputs/flutter-apk/app-debug.apk` with `flutter build apk --debug --target-platform android-arm64`.
2. Installed the APK, cleared package data, launched the normal `MainActivity`, accepted the privacy gate, and opened My > Settings through the Android accessibility hierarchy.
3. Selected Dark, Extra Large, and High contrast through the rendered controls.
4. The pre-stop hierarchy reported `主题\n深色`, `App 字号\n特大`, and an Android switch node for High contrast with `checked="true"`.
5. Ran `adb shell am force-stop com.admin9.app.foundation`, started `MainActivity` again, navigated back to Settings, and dumped a new hierarchy.
6. The post-start hierarchy again reported `主题\n深色`, `App 字号\n特大`, and High contrast with `checked="true"`.

Hierarchy SHA-256:

- before stop: [`android-api36/process-restart-before-stop.xml`](android-api36/process-restart-before-stop.xml), `719cd171ad290c9a6d350e8c5aeadff6510b121c23b4a41d4ef2bc4eff402c76`
- after restart/settings: [`android-api36/process-restart-after-settings.xml`](android-api36/process-restart-after-settings.xml), `4e2f193f9c12ab9a99ac683fac7c399484a30c1dcc3364a3bca1fc39141af8f3`

This closes Android process-restart preference persistence. It does not claim uninstall/reinstall persistence, release-build behavior, TalkBack speech quality, or iOS persistence.
