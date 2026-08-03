# Admin9 Design System Phase 1 验收报告

> **历史记录：** 本文保留 Foundation 阶段当时的验收结论，不是当前 Starter 规范，
> 也不构成对任何 fork 的认证、兼容或支持承诺。

> 结论：Go
> 验收日期：2026-07-29
> 基线：`design-system-v1.0.1` / `e3701a4e0257539228a8922ccfbfd089a7fb2072`
> SDK：Flutter 3.44.1 / Dart 3.12.1

## 1. 范围与边界

Phase 1 已完成 Foundations、Material 3/Cupertino theme bridge、系统辅助设置合并、系统非线性字号与 App 1.00/1.12/1.24、`zh_CN`，以及仅 debug/profile 可达的 Gallery 外壳。本阶段没有迁移业务页面，没有连接后端、创建会话或改变“服务尚未接入”结果。

公共 barrel 仍只导出 `app_contracts.dart` 与 `app_design_tokens.dart`。内部主题解析器和 Gallery 不向 Business 导出；App host 只通过 AST 精确 allowlist 使用四条内部 seam。

## 2. 已实现合同

- 浅色、深色语义色、Android/iOS 字体几何、spacing、field radius 6、control radius 8、motion 和 Brand radius delta 已由真实 Theme/Token 对象解析。
- Brand primary 在浅色、深色各三类 surface 上必须达到 3:1；manifest validator 与运行时共同拒绝无效覆盖。
- `onPrimary`、`onSecondary` 必须达到 4.5:1，不足时从黑白前景中选择更高对比值。
- 系统 `TextScaler.scale(fontSize)` 先执行，App 1.00/1.12/1.24 再单调相乘；没有总字号上限。字号相关的非线性系统缩放不会退化为单一 factor。
- 系统 High Contrast、Bold Text、Reduce Motion 只能加强 App 偏好；运行时辅助功能变化会重建有效 Theme、Token 和 motion。
- Reduce Motion 将局部状态/进入/退出 motion 归零，但保留 Flutter 默认 `PageTransitionsTheme`，不破坏平台返回手势 builder。
- Gallery 路由只在 `!kReleaseMode` 注册，且不进入公共出口。

## 3. 自动化证据

顺序执行的结果：

| 命令 | 结果 |
|---|---|
| `flutter analyze` | Pass，0 issue |
| `flutter test test/design_system_phase_1_test.dart -r expanded` | Pass，24 tests |
| `flutter test -r expanded` | Pass，34 tests |
| `dart run tool/design_system/validate_foundation_manifest.dart --fixtures` | Pass，1 valid / 12 invalid |
| `dart run tool/design_system/verify_import_boundaries.dart --fixtures` | Pass，3 positive / 19 negative |
| `dart run tool/design_system/verify_import_boundaries.dart --phase=0d` | Pass |
| `dart run tool/design_system/verify_gallery_boundary.dart` | Pass |
| `node tool/design_system/verify_documentation.mjs` | Pass，16 Markdown files（新增本报告后最终复跑） |
| `dart run tool/design_system/verify_rule_links.dart` | Pass，22 stable rules |
| `git diff --check` | Pass |

A-L 全矩阵覆盖 320/360/390/600 logical width、手机横屏、Android/iOS target platform、浅色/深色、高对比、Standard/Large/Extra Large，以及 2.0/3.0 synthetic system stress。每行断言实际 platform、brightness、outline Token、有效 scaler、可滚动终点和无异常。代表性 A/F/G/L Golden 按权威实施计划固定在 Phase 5，本阶段不把布局测试冒充 Golden。

## 4. Android 设备证据

设备：Android Emulator `sdk_gphone64_arm64`，Android 16 / API 36，1080x2400、420 dpi，逻辑宽度约 411dp。

Profile：

```text
FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/gallery_profile_test.dart \
  --profile -d emulator-5554
```

结果：测试显式断言 `kProfileMode == true`，并验证 Gallery registry 已注册且命名路由打开 `AppGalleryPage`。使用镜像只解决 Flutter 官方 profile engine artifact 的本地下载速度，不改变项目依赖或运行时行为。

Release：`flutter build apk --release` 通过，生成 50.9MB APK；`adb install -r` 成功。构建 APK 与模拟器已安装 `base.apk` 的 SHA-256 均为 `b74275090570f1bc1c8d94a1e0d6519940691ded29813f8a2d9b1933b451c4f7`。Package resolver 只有 `MAIN/LAUNCHER`，不存在 `VIEW/BROWSABLE` deep link。冷启动同意隐私后再次抓取可达主 Shell hierarchy，只存在“首页/我的”两项一级导航，没有 Gallery 菜单或入口。完整命令、设备和 hierarchy 摘要见 [Android release Gallery exclusion evidence](evidence/admin9-ui-phase-1/android-release-gallery-exclusion.md)。

## 5. 独立复审关闭

- Flutter 架构复审提出的字体几何、公共 barrel 泄漏、内部返回类型、Brand 对比、运行时辅助设置、profile 模式断言和 release 不可达证据均已关闭。
- 无障碍复审提出的 A-L 实值断言、非线性 scaler、High Contrast/Bold Text runtime 切换、全部文字角色与幂等性均已关闭。
- 两轮最终只读复审均未发现运行时代码 P0；全部 Phase 1 P1/P2 已关闭。Golden 阶段归属已明确为 Phase 5。

## 6. Unknown 与后续门禁

- iOS 真机上的 Dynamic Type、Bold Text、Increase Contrast 与 Reduce Motion 视觉/读屏结果留到对应组件完成后的设备门禁和 Phase 6 总验收。
- Android TalkBack、iOS VoiceOver、Switch Access/Control 仍需真实组件与页面完成后验证。
- Android predictive back、iOS edge-back、IME/autofill 不属于 Phase 1；按 Phase 2、4、6 门禁执行。

## 7. Git 边界

提交前暂存区为空。Phase 1 变更限于 Design System Foundations、App host、内部 Gallery、SDK 自带本地化依赖、validators、测试和本报告；未混入 Phase 2 组件或页面迁移。结论为 **Go**，允许创建聚焦本地提交；本 Goal 已授权提交后自动进入 Phase 2。
