# Derived App Quickstart

本文给出从 Admin9 App Foundation 创建派生 Android/iOS App 的最短可验证流程。规范性要求以 [Derived-Project Contract](../design-system/05-derived-project-contract.md) 和[兼容性 registry](../design-system/schema/admin9-foundation-compatibility.json)为准。

## 1. Prerequisites

- Git；
- Flutter `3.44.1` 与 Dart `3.12.1`；
- 客户拥有的独立 Git 仓库 URL；
- 正式 App 名称、版本、Android application ID 和 iOS bundle ID；
- `assets/` 内的方形 PNG Logo 和启动源图；Logo 至少为 `1024x1024`；
- Brand light/dark primary、secondary 色值。

不要提交客户密钥、签名文件、Token、真实用户数据或未公开的后端地址。

## 2. Choose An Approved Source

从 compatibility registry 选择一个 `status: "approved"` 的完整 tuple，包括 Foundation implementation commit、Design System version/source Tag 和 Flutter/Dart 版本。已有 Tag 不移动、不重打。

开源派生还必须确认 checkout 实际包含根 `LICENSE`。现有 `design-system-v1.0.0` 至 `design-system-v1.0.3` Tag 均不包含该文件；如果 registry 尚无同时满足 approved 和包含 `LICENSE` 的来源，停止派生并等待批准来源。

替换下列全部占位符：

```bash
git clone --branch <design-system-source-tag> \
  https://github.com/admin9-labs/admin9-app-flutter.git \
  <derived-directory>
cd <derived-directory>
git rev-parse '<design-system-source-tag>^{commit}'
test -f LICENSE
git switch -c <customer-main-branch>
```

manifest 的 `foundation.commit` 必须使用 registry 中的精确 implementation commit，不要用 Tag 指向的 provenance commit 代替。

## 3. Configure Remotes

```bash
git remote rename origin foundation
git remote set-url --push foundation DISABLED
git remote add origin <customer-repository-url>
git fetch foundation --tags
git remote -v
```

`foundation` 的 fetch URL 必须为 `https://github.com/admin9-labs/admin9-app-flutter.git`，push URL 必须为 `DISABLED`。

## 4. Create And Validate The Manifest

仓库没有 manifest 初始化命令。复制有效 fixture 和示例资源后，替换为真实资料：

```bash
cp docs/design-system/fixtures/foundation-manifest/valid.yaml \
  admin9-foundation.yaml
mkdir -p assets/brand
cp docs/design-system/fixtures/foundation-manifest/assets/brand/logo.png \
  assets/brand/logo.png
cp docs/design-system/fixtures/foundation-manifest/assets/brand/launch.png \
  assets/brand/launch.png
```

必须更新：

- `foundation`：registry 的 implementation commit、canonical URL，以及仅在该 commit 存在精确 Tag 时填写的 `tag`；
- `designSystem`：registry 的版本和 source Tag；
- `app`：正式名称、版本、Android application ID 和 iOS bundle ID；
- `brandConfiguration`：颜色、字体/圆角、资源路径和 SHA-256；
- `toolchain`、`ownership`、`compatibility`、`deviations` 和 `provenance`：当前真实值。

fixture 和示例资源不能直接作为客户 identity 或生产品牌交付。资源必须位于 manifest 相邻的 `assets/` 子树，且不能经 `..` 或符号链接逃逸。

```bash
shasum -a 256 assets/brand/logo.png
shasum -a 256 assets/brand/launch.png
dart run tool/design_system/validate_foundation_manifest.dart \
  admin9-foundation.yaml
```

`themeSha256` 按[派生项目合同](../design-system/05-derived-project-contract.md#1-source-record)计算。validator 未退出 0 时停止，不进入生成步骤。

## 5. Generate And Verify Identity

```bash
dart run tool/design_system/generate_brand_entry.dart \
  admin9-foundation.yaml .
dart run tool/design_system/verify_brand_contract.dart \
  admin9-foundation.yaml .
dart run tool/design_system/verify_repository_governance.dart \
  --derived-root .
```

修改 identity、Brand 或资源时，修改 manifest/源资源并重新生成，不手工修补生成文件。提交前审查生成 diff。

## 6. Add Business Features

业务代码放在 `lib/ui/features/<feature>/**`。Business 访问 Core UI 只能导入：

```dart
import 'package:admin9_app_flutter/admin9_ui.dart';
```

派生项目修改 package name 后同步调整 package URI。Business 还可访问本 feature、`lib/ui/shared/**`、`lib/app/app_identity.dart` 和 `lib/app/app_route_names.dart`；不得导入 Core internals、Brand 入口、其他 App Host 文件或另一 feature 的实现。

简单状态可使用 ViewModel；出现真实数据源后再在所属 Feature 引入 Repository/Service；只有复杂且复用的业务规则才增加 Domain。真实服务接入前保留“服务尚未接入”，不创建模拟用户、会话、Token 或成功状态。

## 7. Run Acceptance Gates

```bash
dart run tool/design_system/validate_foundation_manifest.dart \
  admin9-foundation.yaml
dart run tool/design_system/verify_brand_contract.dart \
  admin9-foundation.yaml .
dart run tool/design_system/verify_repository_governance.dart \
  --derived-root .
dart format --output=none --set-exit-if-changed lib test integration_test tool
flutter analyze
flutter test
flutter analyze tool/design_system/design_system_contract_probe.dart
flutter analyze tool/design_system/design_system_implementation_probe.dart
dart run tool/design_system/verify_public_api_parity.dart --self-test
dart run tool/design_system/verify_import_boundaries.dart --fixtures
dart run tool/design_system/verify_import_boundaries.dart --phase=final
dart run tool/design_system/verify_gallery_boundary.dart
dart run tool/design_system/verify_rule_links.dart
node tool/design_system/verify_documentation.mjs
dart run tool/design_system/verify_android_release_plugins.dart --self-test
dart run tool/design_system/verify_android_release_plugins.dart
flutter build apk --release
flutter build ios --release --no-codesign
git diff --check
```

发布 Tag 时还必须对目标版本运行 release consistency gate；不要在 Quickstart 中写死未来 implementation SHA。

## 8. Record Device Evidence

自动化和无签名构建不证明签名安装、冷启动、TalkBack/VoiceOver、系统手势、真实 IME、安全区或后端接入。只有绑定精确 source 和 artifact 的当代设备执行才能记为 `Pass`；未执行或只有旧版本证据时记为 `Unknown`。
