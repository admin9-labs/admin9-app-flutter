# Admin9 UI Phase 0 验收报告

> **历史记录：** 本文保留 Foundation 阶段当时的验收结论，不是当前 Starter 规范，
> 也不构成对任何 fork 的认证、兼容或支持承诺。

> 结论：Revise，Phase 0 尚未通过退出门禁
> 证据基线：`main@606938f3b0d1287a3ec3c7fe9791f8e737e52707`
> 计划基线：Admin9 UI v1.1，SHA-256 `8479729b26a4ec81d227838d24a3cde71eb2d51a63e87d85eb03b50afb0d20e5`
> 执行日期：2026-07-29
> 授权边界：只执行 Phase 0；未进入 Phase 1；Phase 0 变更不暂存、不提交

## 1. 结论摘要

Phase 0 的消费者盘点、迁移清单、设备清单、当前行为证据和工期校准已经完成。当前 SHA 的 Android API 36 与 iOS 26.5 设备 smoke 均通过；iOS 已取得首页、我的、设置、认证表单和隐私门禁的当前截图。

Phase 0 不能判定通过，原因是 v1.1 第 8 节尚不足以生成完整、可调用、无实现的 Dart API 草案：10 个 Widget 契约可以声明为不可实例化的 abstract probe，但 `AppDialog`、`AppFeedback` 的静态命令入口无法在 Dart 中以 abstract static 表达；同时缺少必需的枚举名称、nullability、回调类型、反馈作用域和 `BuildContext`。按授权要求，本次没有用 `throw`、`external`、空返回或临时 Widget 伪装完成。

最终判断固定为 **Revise**。在完成第 6 节的最小 v1.2 签名勘误并重新生成完整可编译 API 草案前，不得进入 Phase 1。

## 2. 执行边界

本次已完成：

- 五个责任域的独立只读取证与主任务去重汇合。
- 仓库内 UI 消费者、旧组件、直接 Material 使用和测试绑定盘点。
- Flutter/Dart/Android/iOS 工具链与设备清单回读。
- 当前 SHA 的 Android/iOS device integration smoke。
- iOS 当前运行时的六张迁移前视觉基线。
- Phase 0 退出门禁审计和剩余工期重估。

本次未执行：

- 未实现任何 Admin9 UI 视觉、平台 Widget、主题、Token 或交互。
- 未创建 Gallery，未迁移页面，未修改导航、依赖、业务状态或持久化。
- 未修改现有测试来制造验收证据。
- 未创建不可调用或运行即失败的 Dart API 假实现。
- 未运行 Phase 1 及其后的设备人工门禁。

## 3. 唯一消费者与迁移清单

当前生产代码共有 30 个 Dart 文件，其中 21 个直接导入 `flutter/material.dart`，10 个 feature view 全部直接导入 Material。生产代码没有 Cupertino import，没有 `Platform.isIOS` / `Platform.isAndroid`，也没有 `Theme.of(context).platform`。当前不存在 `lib/admin9_ui.dart`。

| 固定目标 | 当前真实消费者 | Phase 0 固定迁移结论 |
| --- | ---: | --- |
| `AppPage` | `FoundationPage` 8 个；Home、Account、unknown route 3 个直接页面容器 | 11 个普通页面迁移；privacy gate 保留 app-layer 专用容器，只迁移其按钮与反馈 |
| `AppBottomNavigation` | Shell 1 处、2 个 destination | Shell 继续持有 index 和页面实例 |
| `AppSection` | 4 个实例、2 个文件 | 直接替换，不保留兼容包装 |
| `AppNotice` | 2 个 `UnavailableNotice` | 业务文案移回 feature；未使用的 `compact` 不进入新 API |
| `AppListTile` | 15 个普通列表行，加 3 个 Switch 复合行 | 共 18 行；尾部箭头由组件在 `onTap != null && trailing == null` 时自动提供 |
| `AppSwitch` | 3 | 受控迁移 |
| `AppSegmentedControl` | 1 | 受控、非空单选值 |
| `AppSelect` | 1 | 当前值允许为空；选择后回调非空值 |
| `AppTextField` | 5 个底层构造点 | feature 新增并持有 `FocusNode`，同时负责 dispose |
| `AppButton` | 14 个按钮构造点 | Dialog 内 2 个由 `AppDialog` 吸收；其余 12 个迁移；账号注销的 tonal 按钮固定为 destructive |
| `AppDialog` | 1 | 退出登录确认框 |
| `AppFeedback` | 2 | 均为无 action 的现有 SnackBar |
| 路由 | 1 个集中式 `MaterialPageRoute` 工厂 | 保留入口和 Flutter 默认 builder |

旧组件的具体消费者：

- `FoundationPage`：about、contact、account deletion、account security、profile、auth form、legal document、settings，共 8 个。
- `SettingsSection`：account 2 个、settings 2 个，共 4 个。
- `UnavailableNotice`：account deletion、auth form，共 2 个。
- `BrandMark`：privacy gate、home、about，共 3 个；继续属于 branding，不进入 `admin9_ui.dart`。

测试侧另有 19 处 Material 实现类型定位或断言，分布于 `navigation_test.dart`、`auth_boundaries_test.dart`、`app_host_test.dart` 和 `foundation_smoke_test.dart`。后续迁移时必须改为稳定 Key、可见文字、Semantics 或结果状态。

当前 workspace 范围没有发现仓库外消费者；仓库为 `publish_to: none`、单一 worktree、无 submodule、无 remote。workspace 之外的复制项目或私有仓库是否引用旧代码无法证明，保持 Unknown。Phase 5 删除旧组件前必须再次执行全仓搜索，但当前不建立 `@Deprecated` 包装。

## 4. 迁移清单中的契约冲突

以下冲突不能由实现者自行选择：

1. `AppListTile.leadingIcon` 只接受 v1.1 的 `AppIconRole`，但现有列表需要 badge、security、account recovery、sign out、document、privacy、apps、version、contact、password 和 delete account 等语义。现有固定枚举无法表达，且不得用 `IconData` 逃生口。
2. privacy gate 当前是无 AppBar 的品牌门禁，不能在不改变行为的情况下套入必需 `title` 的 `AppPage`。固定处理是保留 app-layer 专用容器，仅迁移其通用按钮和反馈。
3. `AppTextField` 要求 feature 持有 `TextEditingController` 和 `FocusNode`。当前 5 个构造点均未创建 FocusNode，其中 profile 的 2 个禁用字段也没有 controller；该页面必须在 Phase 4 获得明确的 controller/focus 生命周期所有者。
4. `docs/architecture/admin9-app-foundation.md` 仍把 `NavigationBar` 和 `FoundationPage` 描述为正式结构，Phase 5 必须同步更新。

第 1、2 项改变 v1.1 的公共枚举或迁移边界，必须先进入第 6 节的计划勘误，不允许在代码评审时临时决定。

## 5. API 草案可行性

### 5.1 Confirmed

Flutter 3.44.1 中存在 v1.1 映射所需的 Material/Cupertino API，包括 `DropdownMenuFormField<T>`、`CupertinoButton.tinted`、`CupertinoCheckbox`、`CupertinoRadio<T>` 和 `RadioGroup<T>`。17 个现有 `AppIconRole` 的两端 SDK 图标常量均存在。

以下 10 个 Widget 可用 abstract Widget、const generative constructor、`super.key`、final 字段和 abstract `build/createState` 边界表达为可分析但不可实例化的声明：

- `AppButton`
- `AppSwitch`
- `AppTextField`
- `AppSegmentedControl<T extends Object>`
- `AppSelect<T extends Object>`
- `AppListTile`
- `AppSection`
- `AppNotice`
- `AppPage`
- `AppBottomNavigation`

`AppSegment<T>`、`AppSelectOption<T>`、`AppNavigationDestination` 和 `AppPageAction` 可表达为 immutable const value object；`AppIconRole` 可表达为 enum。

### 5.2 Blocked

1. Dart 没有 abstract static method。`external static` 虽可通过 analyzer/AOT 编译，但调用会失败，属于禁止的假实现。
2. `AppDialog.show*` 在 Flutter 两端都需要 `BuildContext`，v1.1 契约没有该参数，也没有定义全局 Navigator 所有权。
3. `AppFeedback.show` 没有冻结返回类型、同步/异步回调类型和“同一时刻一条”的作用域。
4. “所有公共组件必须 Key 透传、const”不适用于命令式 `AppDialog` / `AppFeedback`。
5. v1.1 未冻结 `variant`、`tone` 的类型名，也未显式列出 `AppPageBodyMode` 成员。
6. 多个字段的 nullability 和回调类型未冻结，会直接改变消费者调用方式。

因此本次没有创建部分 `lib/admin9_ui.dart`。只冻结 10 个 abstract Widget、遗漏两个公共入口，会让不完整 barrel 看起来像已批准 API，不能满足 Phase 0 的“完整签名冻结”目的。

## 6. 唯一 v1.2 签名勘误方案

下一次计划修订必须一次性固定以下内容，不保留候选项：

1. 定义 `AppButtonVariant { primary, secondary, tertiary, destructive }`，`AppButton` 只使用单一默认构造器和必需 `variant`，不增加四个 named constructors。
2. 定义共享 `AppTone { info, success, warning, error }`，供 `AppNotice` 与 `AppFeedback` 共用。
3. 定义 `AppPageBodyMode { padded, list }`。
4. 10 个 Widget 才要求 `Key` 透传和可适用的 const 构造；命令式入口不适用该条。
5. `AppButton.onPressed` 为 `VoidCallback?`；null 即禁用。
6. `AppSwitch.onChanged` 为 `ValueChanged<bool>?`；null 即禁用。
7. `AppSegmentedControl.value` 为非空 `T`，`onChanged` 为必需 `ValueChanged<T>`。
8. `AppSelect.value` 为 `T?`，`onChanged` 为必需 `ValueChanged<T>`，`validator` 为 `FormFieldValidator<T>?`，`forceErrorText` 为 `String?`。
9. `AppListTile.subtitle` 为 `String?`，`trailing` 为 `Widget?`，`onTap` 为 `VoidCallback?`；`onTap == null` 或 `enabled == false` 时不可操作。仅当 `onTap != null && enabled == true && trailing == null` 时，组件自动显示 `AppIconRole.chevronForward`。
10. `AppTextField.controller` 为必需 `TextEditingController`，`focusNode` 为必需 `FocusNode`，`label` 为必需 `String`，`validator` 为 `FormFieldValidator<String>?`，`forceErrorText` 为 `String?`，`keyboardType` 为 `TextInputType?`，`textInputAction` 为 `TextInputAction?`，`autofillHints` 为 `Iterable<String>?`，`onChanged` 与 `onFieldSubmitted` 均为 `ValueChanged<String>?`。feature 通过 `onChanged` 显式清除服务端错误。
11. `AppNotice.actionLabel/onAction` 与 `AppFeedback.actionLabel/onAction` 成对为空或成对非空，`onAction` 固定为 `VoidCallback?`。
12. `AppDialog` 固定为真实实现阶段提供的 static façade；三个方法第一个位置参数均为 `BuildContext context`，其余参数使用 named required。返回类型保持 v1.1：information 为 `Future<void>`，confirmation/destructive 为 `Future<bool>`。
13. `AppFeedback.show` 固定返回 `void`，第一个位置参数为 `BuildContext context`；消息状态由 app root 的单一 feedback owner 持有，作用域是整个 App，不按页面或嵌套 Navigator 分裂。
14. `AppPageAction.onPressed` 为 `VoidCallback?`；`AppNavigationDestination` 固定只含 `label` 与 `AppIconRole`；底栏回调为 `ValueChanged<int>`。
15. `AppIconRole` 增加下表 11 个标识符和固定映射；仍禁止公开 `IconData`。
16. 明确 privacy gate 不迁入 `AppPage`，只迁移其中的通用控件。

| 新增 `AppIconRole` | Android | iOS |
| --- | --- | --- |
| `badge` | `Icons.badge_outlined` | `CupertinoIcons.person_crop_rectangle` |
| `security` | `Icons.security_outlined` | `CupertinoIcons.shield` |
| `accountRecovery` | `Icons.manage_search_outlined` | `CupertinoIcons.person_crop_circle_badge_exclam` |
| `signOut` | `Icons.logout` | `CupertinoIcons.square_arrow_right` |
| `document` | `Icons.description_outlined` | `CupertinoIcons.doc_text` |
| `privacy` | `Icons.privacy_tip_outlined` | `CupertinoIcons.lock_shield` |
| `apps` | `Icons.apps_outlined` | `CupertinoIcons.app` |
| `version` | `Icons.numbers` | `CupertinoIcons.number` |
| `contact` | `Icons.contact_support_outlined` | `CupertinoIcons.mail` |
| `password` | `Icons.password_outlined` | `CupertinoIcons.lock` |
| `deleteAccount` | `Icons.person_remove_outlined` | `CupertinoIcons.person_badge_minus` |

上述勘误必须同时修订 Phase 0 的产物定义和退出门禁：Phase 0 对 10 个 Widget、4 个 value object 和全部 enum 建立完整未导出 declaration probe，并运行 format/analyze；`AppFeedback.show` 与 `AppDialog.show*` 在文档中冻结到参数类型和返回类型，但因 Dart 不支持 abstract static，不要求 Phase 0 制造可调用声明。两组 static façade 分别与 Phase 2 的 `AppFeedback`、Phase 4 的 `AppDialog` 首次真实实现同批落地并编译测试。Phase 0 退出门禁必须相应改为“declaration probe 通过且命令式入口签名完整冻结”，不能继续写成所有入口均有可编译 Dart 草案。正式 `admin9_ui.dart` 公共出口只在首次真实实现存在时创建；Phase 0 不使用 `external`、`throw` 或空实现占位。

## 7. 工具链与设备清单

| 项目 | Confirmed 基线 |
| --- | --- |
| Flutter / Dart | Flutter 3.44.1 stable；Dart 3.12.1 |
| Android | compile SDK 36；min SDK 24；target SDK 36；NDK 28.2.13676358；JDK 17.0.19 |
| Android AVD | `Admin9_API_36`，Pixel 7 profile，API 36，1080x2400，420dpi，手势导航 |
| Android 缺口 | 没有 API 34 AVD；没有 Android 真机 |
| iOS | deployment target 13.0；Xcode 26.6；唯一 runtime iOS 26.5 |
| iOS 小屏模拟器 | iPhone 17e，390x844pt，本轮实际运行 |
| iOS 常规屏模拟器 | iPhone 17 / 17 Pro，402x874pt，已创建但本轮未运行 |
| iOS 其他模拟器 | iPhone Air 420x912pt；17 Pro Max 440x956pt；多种 iPad 744-1032pt |
| iOS 真机 | 发现一台 iPhone18,2 / iOS 26.5.2；最终复查时无线不可用，本轮未执行真机验收 |
| 320pt | 当前 Xcode 没有 320pt 模拟器，只能由未来 Widget 测试窗口覆盖 |

环境风险：`flutter doctor -v` 唯一告警为 CocoaPods 1.8.4 低于推荐 1.16.2。Phase 0 不升级依赖或本机工具；进入需要 CocoaPods 的实现/构建前必须处理或形成明确豁免。

## 8. 当前行为与截图证据

### 8.1 设备 smoke

| 平台 | 命令 | 结果 | 证据边界 |
| --- | --- | --- | --- |
| iOS 26.5 / iPhone 17e | `flutter drive --driver=test_driver/integration_test.dart --target=integration_test/foundation_smoke_test.dart -d C10E0968-4695-4C02-BC55-8C322531239A` | 通过，2 个 driver/test harness 测试完成 | 现有边缘返回失败时会退回 `handlePopRoute()`，不能证明边缘返回完成/取消 |
| Android API 36 / Pixel 7 AVD | `flutter test integration_test/foundation_smoke_test.dart -d emulator-5554` | 通过，1 个 smoke 测试完成 | 只证明普通返回后的现有流程，不证明 predictive back 四阶段 |

Android 普通 debug APK 的额外构建在 Gradle 阶段超过 3 分钟且 CPU 为 0，已中止；integration test APK 的启动图不是应用页面证据，已丢弃。因此 Android 的五页面视觉截图保持 Unknown，不用无效图片充数。

### 8.2 iOS 截图

所有截图来自当前 SHA、iOS 26.5、iPhone 17e、390x844pt 逻辑尺寸，PNG 为 1170x2532px：

| 状态 | 文件 | SHA-256 |
| --- | --- | --- |
| 隐私门禁 / light | `evidence/admin9-ui-phase-0/ios/ios_01_privacy_gate.png` | `de49abad8ab6e787d962bb076cbfdca228688b9d9fafdf6d5f6317aa7076e568` |
| 首页 / light | `evidence/admin9-ui-phase-0/ios/ios_02_home.png` | `9307cca97a1b68b47ef3a6034875ef7e665c24b49ccb301f73fc44704a02fe9d` |
| 我的 / light | `evidence/admin9-ui-phase-0/ios/ios_02b_account.png` | `36d43579013b0d60acdfaee9a98a3ae3162697788c6d138c3604f5eb86a23d42` |
| 登录表单 / light，键盘输入后的字段状态 | `evidence/admin9-ui-phase-0/ios/ios_03_login_form.png` | `4fcc96267d3a1c267f1c91e3804dab8ee725f143ea7412c2dc1af11855dbd3b4` |
| 设置 / dark + App 1.24 + grayscale + high contrast + reduce motion | `evidence/admin9-ui-phase-0/ios/ios_04_settings_accessibility.png` | `98ec29dd9b4c0798d38f70f613cb24957aaeb4b41e815748c54c4083b5017be7` |
| 重启持久化 / dark | `evidence/admin9-ui-phase-0/ios/ios_05_restart_preferences.png` | `2654d5ca819b561a634a8ad3b288e830da9a5e338b6d3ce06319ba5a161f47c4` |

这些截图只记录迁移前现状，不代表视觉、对比度、Dynamic Type、VoiceOver 或 HIG 验收通过。

### 8.3 Confirmed 与 Unknown

Confirmed：

- light/dark 和 App 内 1.12/1.24 外观偏好可以写入并在重启后恢复。
- 认证表单可输入账号与密码，现有本地校验和“不会创建会话”边界通过。
- 现有路由可以打开并通过普通返回事件回到前页。
- 当前实现仍是 Material-only；iOS 截图明确显示 Material AppBar、输入框、分段控件、Switch 和底栏。
- 当前字号算法仍把系统缩放与 App 倍率结果限制在 0.8-2.0，当前 reduce motion 会用 `_NoTransitionBuilder` 替换默认转场。

Unknown 或只能未来实现后验证：

- Android API 36 edge-to-edge、cutout、IME 避让、系统栏图标对比度和 predictive back 四阶段。
- Android 五页面截图、TalkBack、Switch Access、200% 字号和真机行为。
- iOS 边缘返回短拖取消/长拖完成、最大辅助字号、VoiceOver、Switch Control、Bold Text 和系统高对比度。
- 320/360/390/600 宽度 Widget 测试、横屏、Semantics、键盘 Tab/Shift+Tab、Golden。
- `AppFeedback` 生命周期、live region、持久态、关闭/替换和单次 action；组件尚未实现。
- iOS 13 至 26.4 运行时行为；本机没有对应 runtime。

## 9. 测试基线

当前仓库有 0 个纯 unit test、5 个 Widget test 和 1 个 device integration smoke。现有 Widget test 覆盖隐私门禁、外观偏好持久化、认证边界、两个 Tab 和路由开关；没有显式 Semantics、宽度矩阵、Golden、系统字号、外接键盘或读屏测试。

现有 integration test 与 v1.1 有两项已确认差异：

1. iOS 只做一次长拖，失败后使用 `handlePopRoute()` 兜底；没有短拖取消断言。
2. 测试仍使用 `AppBar`、`TextFormField`、`MaterialApp`、`DropdownButton`、`SwitchListTile` 等底层类型定位。

这些差异是后续对应阶段的测试迁移项，不在 Phase 0 修改。

## 10. 工期校准

基于 11 个普通页面、18 个列表行、12 个页面按钮、5 个输入构造点、4 个 section、3 个 switch、2 个 notice、2 个 feedback、1 个 dialog、1 个 select、1 个 segmented control、1 个底栏，以及当前设备缺口，剩余单人工期从 v1.1 的 15-26 个工作日校准为 **17-29 个工作日**：

| 工作包 | 校准工期 |
| --- | ---: |
| v1.2 签名勘误与 Phase 0 API 草案重做 | 1-2 天 |
| Phase 1 主题、系统偏好、本地化、Gallery 骨架 | 2-3 天 |
| Phase 2 平台骨架、导航、反馈 | 2-4 天 |
| Phase 3 设置页完整试点 | 2-3 天 |
| Phase 4 按钮、Dialog、输入和通用能力 | 3-5 天 |
| Phase 5 的 11 个普通页面与测试定位迁移 | 3-5 天 |
| Phase 6 双端自动化、设备人工验收、修正和文档 | 4-7 天 |

上限增加的主要原因是：真实消费者数量已确认、缺少 API 34/Android 真机、现有 iOS 手势脚本不符合 v1.1、当前没有 Semantics/宽度/Golden 证据，以及 CocoaPods 环境风险。不得通过删除 P1 门禁压缩工期。

## 11. Phase 0 退出门禁

| 门禁 | 状态 | 判定 |
| --- | --- | --- |
| 唯一迁移清单 | 完成 | Pass |
| 完整可编译 API 草案 | 未完成 | Blocked：v1.1 签名不足，且禁止假实现 |
| 设备清单 | 完成 | Pass |
| 当前基线证据 | 部分完成 | iOS 完整；Android smoke 完成、视觉/人工项 Unknown |
| 影响 Phase 1-3 的产品/API 选择清零 | 未完成 | Blocked：图标角色、privacy gate 边界、命令式入口与字段类型 |
| 未提前进入 Phase 1 | 完成 | Pass |

最终判断：**Revise，不允许进入 Phase 1。** 下一步仅允许先修订 v1.1 为包含第 6 节固定签名的 v1.2，再重跑 Phase 0 的 API 编译与独立验收。

## 12. 最终只读验收

独立验收在主任务完成汇合报告后执行。首轮发现的文件总数、图标角色数、iOS 设备 ID、测试绑定数量、profile controller 生命周期、字段类型、自动尾箭头和 Phase 0 static façade 门禁矛盾，均已在本报告中修正；没有因此修改 v1.1 或源码。

| 验收项 | 最终结果 |
| --- | --- |
| `dart format --output=none --set-exit-if-changed lib test integration_test` | Pass：34 files，0 changed |
| `flutter analyze` | Pass：No issues found |
| `flutter test -r expanded` | Pass：5 tests，All tests passed |
| Markdown 表格与代码围栏 | Pass：表格结构有效，代码围栏成对 |
| 证据图片 | Pass：6 张 PNG 均为 1170x2532px，SHA-256 与第 8.2 节一致 |
| `git diff --check` | Pass |
| 基线提交 | Pass：`606938f3b0d1287a3ec3c7fe9791f8e737e52707` 仅包含 v1.1 计划文件 |
| push / remote | Pass：仓库没有 remote，未 push |
| Phase 0 工作区 | Pass：仅本报告与 6 张证据图未跟踪；未暂存、未提交 |
| 源码、依赖、主题、导航、页面与业务行为 | Pass：无差异 |
| Phase 0 退出门禁 | Fail：完整 API 草案缺失，v1.1 仍有影响签名与迁移的未冻结选择 |

独立终审最终判断为 **Revise**，与主报告一致。当前产物可以作为“Phase 0 阻塞验收报告”，不能标记为“Phase 0 已完成基线”，也不能授权进入 Phase 1。
