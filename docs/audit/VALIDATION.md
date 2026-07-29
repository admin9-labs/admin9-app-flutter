# Validation

Admin9 App Foundation 的验收从仓库根执行：

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test test/app_host_test.dart
flutter test test/navigation_test.dart
flutter test test/auth_boundaries_test.dart
flutter test
flutter build apk --release
flutter build ios --release --no-codesign
git diff --check
```

必须另外回读平台产物身份，并静态检查旧品牌、媒体业务、网络依赖和已删除平台目录。浏览器不属于本项目验收面。
