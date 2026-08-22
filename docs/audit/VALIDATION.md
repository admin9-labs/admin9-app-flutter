# Admin9 App Starter 验证

本文是当前上游仓库的验证入口，只约束准备合入 Admin9 App Starter 上游的修改。
fork 可独立选择自己的测试与发布流程，本项目不据此认证或追踪 fork。

在仓库根使用 Flutter 3.44.1 与 Dart 3.12.1：

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test tool
flutter analyze
flutter test
dart run tool/design_system/validate_app_config.dart --fixtures
flutter analyze tool/design_system/design_system_contract_probe.dart
flutter analyze tool/design_system/design_system_implementation_probe.dart
dart run tool/design_system/verify_public_api_parity.dart --self-test
dart run tool/design_system/verify_import_boundaries.dart --fixtures
dart run tool/design_system/verify_import_boundaries.dart --phase=final
dart run tool/design_system/verify_ui_candidate_boundary.dart --fixtures
dart run tool/design_system/verify_ui_candidate_boundary.dart
dart run tool/design_system/verify_gallery_boundary.dart
node --check docs/design-system/evidence/sources/generate_visual_references.mjs
node --check docs/design-system/evidence/sources/verify_visual_references.mjs
node docs/design-system/evidence/sources/verify_visual_references.mjs docs/design-system/evidence/visual-references
dart run tool/design_system/verify_app_config.dart
dart run tool/design_system/verify_app_config.dart --fixtures
dart run tool/design_system/verify_rule_links.dart
dart run tool/design_system/verify_upstream_ownership.dart
dart run tool/design_system/verify_android_release_plugins.dart --self-test
dart run tool/design_system/verify_android_release_plugins.dart
node tool/design_system/verify_documentation.mjs
flutter build apk --release
flutter build ios --release --no-codesign
git diff --check
```

涉及身份时，另外回读 `AppIdentity`、Android label、iOS display/name、技术标识及
`pubspec.yaml`。本项目是 Android/iOS 原生 Flutter 工程，浏览器测试不属于验收面。

自动化和无签名构建不证明签名、安装、冷启动、TalkBack/VoiceOver、系统手势、真实
IME、安全区、正式法务内容或后端接入。只有绑定精确源码与产物的当代执行才能记为
`Pass`；未执行时记录 `Unknown`。
