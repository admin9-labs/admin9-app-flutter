# Admin9 Phase 0C Gate 1 只读验收报告

> **历史记录：** 本文保留 Foundation 阶段当时的验收结论，不是当前 Starter 规范，
> 也不构成对任何 fork 的认证、兼容或支持承诺。

> 日期：2026-07-29
> 结论：Go，仅进入用户结构接受判断
> 边界：Phase 0C 第一门；不是 Phase 0C 完成、v1.2、Phase 0D 或 Phase 1 授权

## 1. 验收结论

个人中心、认证表单、设置页的 Android/iOS 低保真结构已形成唯一推荐方向。六个独立视角的首轮 P1/P2 已去重并收口；最终没有遗留阻断用户判断结构的 P0-P2。

本轮 Go 只表示：用户可以逐页判断信息组织、主次关系和平台自然度是否可以接受。320/360/600、横屏、真机、读屏、系统手势、最终视觉对比度和完整深色视觉仍为 Unknown，不得解释为已经实现或通过。

## 2. 固定输入与基线提交

固定输入：

- `docs/product/admin9-app-experience-baseline.md`
- `docs/audit/admin9-ui-experience-audit.md`
- `docs/design/admin9-reference-page-briefs.md`
- `docs/audit/admin9-phase-0ab-acceptance-report.md`
- `docs/architecture/admin9-ui-phase-0-acceptance-report.md`
- `docs/architecture/admin9-ui-implementation-plan.md`
- `docs/audit/evidence/admin9-registration-density/`，只作为密度观察

本轮开始前已创建两笔本地 docs-only 提交，未 push：

| 顺序 | 提交 | Subject |
| --- | --- | --- |
| 1 | `bf152fa51417b5eddd18481a05c0830e46e46d02` | `docs(ui): record Phase 0 discovery evidence` |
| 2 | `22848a3b98b3664f02ae614ca01e7321b1cc00ea` | `docs(ux): establish Phase 0A and 0B experience baseline` |

当前 HEAD 为第二笔提交。原 Phase 0 报告 SHA-256 仍为 `838a402b6369ce650edb203359cebb1340eb942cc1910d934ea5481dddfdae5d`，与 Phase 0A/0B 验收记录一致。

## 3. 唯一结构方向

- 克制、安静、偏生产力工具，不使用营销式大标题、渐变、装饰卡片或 Material 展示页构图。
- 信息顺序、业务真实性、主次和危险边界跨平台一致。
- Android 固定使用 Material 3 导航、输入、反馈、单选、Switch 和返回预期。
- iOS 固定使用 Cupertino 导航、分组列表、披露、checkmark 单选、CupertinoSwitch 和边缘返回预期。
- 点击区域与视觉容器分别标注；按钮和输入框不强制等高。
- 大字号内容驱动增长并整页滚动，不缩放整张标准稿。
- 结构构造数值不是 Token、API 或固定实现高度。

## 4. 六角色独立复查

| 视角 | 首轮结论 | 去重后的问题 | 最终状态 |
| --- | --- | --- | --- |
| 产品/信息架构 | 方向成立 | 登录身份必须注明派生项目数据；危险边界与账号注销职责分开 | 已修正 |
| 跨平台 UI | 方向成立 | 双端列表需体现平台差异；设置选择后停留并由用户返回 | 已修正 |
| iOS HIG | Revise | iOS 返回需包含上级名称；checkmark/selected trait、边缘返回预期需明确 | 已修正；设备结果 Unknown |
| Android Material 3 | Revise | Material 单选、48dp 命中区、predictive back 与状态保持需明确 | 已修正；系统手势 Unknown |
| 无障碍/响应式 | Revise | 大字号危险区、文字次操作命中区、进入公告与遍历顺序、返回语义、证据等级 | 已修正 |
| Flutter 3.44.1 可实现性 | Revise | 系统字号不可被总上限削弱；减少动态不得移除平台手势 Builder；输入保留范围和三态所有权需固定 | 已修正为后续实现契约 |

Flutter 可实现性复查确认：Material/Cupertino 组合、平台单选、Switch、动态行高、键盘避让、`FocusNode`、一级 Tab 状态和偏好持久化在 Flutter 3.44.1/Dart 3.12.1 中无 SDK 能力阻塞。当前源码与获批结构之间的差异属于后续 Phase 0D/实施任务，不在 Gate 1 修改。

## 5. 关闭的问题

| 严重度 | 问题 | 唯一收口 |
| --- | --- | --- |
| P1 | 大字号登录态未证明危险区可达 | 双端个人中心第三画布改为缺失身份字段的滚动终态，完整显示退出边界 |
| P1 | 认证文字次操作无命中区 | 返回登录、注册账号、找回账号逐项标注独立 48lp 命中区 |
| P1 | 初始焦点与遍历顺序混写 | 路由进入先公告标题且不强制键盘焦点；后续遍历从可见返回控件开始 |
| P1 | Android 返回无可核验名称 | 认证固定“返回我的”；设置主页“返回我的”、选择页“返回设置” |
| P1 | 系统与 App 偏好合并不完整 | 固定主题、字号、灰度、高对比度、减少动态的输入、所有权与有效规则 |
| P1 | 当前字号上限可能削弱系统设置 | 固定标准等同系统非线性结果，大号/特大只能单调放大且无低于系统结果的总上限 |
| P1 | 减少动态可能破坏平台返回手势 | 固定保留平台导航 Builder，只减少非导航动画和视觉运动 |
| P2 | 输入保留生命周期不唯一 | 仅当前路由内保留；完成 `pop`/replacement 后清除 |
| P2 | 设计建议被直接写成 Pass | 改为 `N/R/U` 与 `E1-E5` 证据语言，并分离结构结论和实现/设备结论 |
| P2 | Gate 1 与 Phase 0C 最终门禁关系不清 | 增加范围映射；Gate 1 不代替深色、全尺寸、视觉和设备门禁 |
| P2 | 旧 Phase 0 报告要求先修 v1.2 | 明确新路线只在执行顺序上取代该安排；Phase 0D 前仍不得修订 v1.2 |

## 6. 页面覆盖

| 页面 | Android/iOS Gate 1 状态 |
| --- | --- |
| 个人中心 | 游客、登录、身份字段缺失、大字号滚动终态、危险边界 |
| 认证表单 | 注册键盘打开、注册大字号错误、登录未接入、首错、次操作命中区 |
| 设置 | 当前值、大字号系统冲突、平台单选、即时生效、无保存按钮 |

两条连续任务已记录：

1. 首页 → 我的 → 设置 → 修改外观 → 返回 → 重启确认持久化。
2. 游客个人中心 → 注册 → 出错 → 首错 → 修正 → 服务未接入 → 返回登录 → 返回我的。

## 7. PNG 资产清单

| 相对路径 | 尺寸 | SHA-256 |
| --- | --- | --- |
| `wireframes/android/account.png` | 1800x1120 | `f46c9eba95a706c6b18bb61f59fb3cc60b50504bd6405f69fd71e3e9ebc9c3fd` |
| `wireframes/android/auth.png` | 1800x1120 | `68a88b47219d039ef7ea99d4e9b3e4b10dadd2bca046bb1556cb7529046e83ae` |
| `wireframes/android/settings.png` | 1800x1120 | `c804c0e79870397b990be79b95fca94b2ff252eac71e1b3ccea521ff9d444fab` |
| `wireframes/ios/account.png` | 1800x1120 | `6c2573e9cc31998c3858e113a211a9c754c63051c9f8f12c699cd963a758c943` |
| `wireframes/ios/auth.png` | 1800x1120 | `05869d5e7bfacf2e4dcd010c240ab13c41503eb72dc1f5ed8bb22dc0bb56319f` |
| `wireframes/ios/settings.png` | 1800x1120 | `acbd8722a0f50adfec27cf7ab0912222af16834e70a39a6301fb5b036b5332b1` |
| `wireframes/flows/appearance-persistence.png` | 1800x980 | `974899f0da53ce003f5701fc7f5c73c7bcf0b6c4449bbc94f2ef8512fde364b5` |
| `wireframes/flows/registration-boundary.png` | 1800x980 | `9d96fb6ed4263c4f23547c6cf5c1132750869a861c17357422e7c78d9a148361` |

对应 SVG 静态源均位于 `sources/`，通过 XML 解析；PNG 是设计审阅资产，不是当前 App、模拟器或真机截图。

| SVG 静态源 | SHA-256 |
| --- | --- |
| `sources/android/account.svg` | `96e800c7dcdd87e671e0e8735de9af66b95fd09bb2d9388ff881ad4a90f2655e` |
| `sources/android/auth.svg` | `f630d5eb8beedd3d10954edad2af03d6cde8590e9271cd5f0c3185de3aaa3538` |
| `sources/android/settings.svg` | `6ed8e42321f56c592218239f965900237d7f9e5187bf8370cfa76c0c2628d43f` |
| `sources/ios/account.svg` | `667aa48d9a78e9eaf0a6229880a33c1bdcb815d628564d8d7bc28ce1a57a086c` |
| `sources/ios/auth.svg` | `b72254498678ae1039912cdcfc9568f93d6400d3326ce739c515505019562047` |
| `sources/ios/settings.svg` | `e90b9d691fd3d08ac4039f161a39e82a63e6edc361835259181a21116d3c90ff` |
| `sources/flows/appearance-persistence.svg` | `f07625424071a5bf4e65b54b79b37424c22ca864a8dc8015ae81c58ec509de3f` |
| `sources/flows/registration-boundary.svg` | `f605da089b6155df34401ac654bb7337ef9fc940ba383ca2e04939efed03af06` |

## 8. 官方与项目来源

- Flutter, [General approach to adaptive apps](https://docs.flutter.dev/ui/adaptive-responsive/general)。
- Flutter, [Best practices for adaptive design](https://docs.flutter.dev/ui/adaptive-responsive/best-practices)。
- Flutter, [User input & accessibility](https://docs.flutter.dev/ui/adaptive-responsive/input)。
- Flutter 3.44.1 SDK：Material predictive-back 与 Cupertino route transition 源码。
- Android Developers, [Make apps more accessible](https://developer.android.com/guide/topics/ui/accessibility/apps#touch-targets)。
- Apple HIG, [Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons) 与 [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)。
- Admin9 Phase 0、Phase 0A/0B 报告、当前源码与测试，只用于现状和可实现性对照。

## 9. Unknown 与补证路径

| Unknown | 补证阶段 |
| --- | --- |
| 320/360/600 与手机横屏结构画布 | 用户接受 Gate 1 后的 Phase 0C 视觉阶段 |
| 完整深色、灰度、高对比度、减少动态视觉 | Phase 0C 视觉阶段 |
| 普通文字 4.5:1、大字/关键边界 3:1 实测 | 最终颜色确定后的 Phase 0C 视觉门禁 |
| Android/iOS 真机视觉与 IME | 实现后的设备门禁 |
| TalkBack、VoiceOver、Switch Control | 实现后的设备门禁 |
| Android predictive back、iOS 边缘返回取消/完成 | API 34+ Android 与当前 iOS 真机/模拟器人工硬门禁 |
| 最终 hit bounds 与非线性字号结果 | Widget 测试加设备测量 |

以上 Unknown 不阻止用户判断当前结构，但阻止宣称 Phase 0C 完成或进入源码实施。

## 10. Git 与范围边界

- 当前分支：`main`；HEAD：`22848a3b98b3664f02ae614ca01e7321b1cc00ea`。
- Phase 0C 文件全部位于 `docs/design/phase-0c/`，保持未跟踪、未暂存、未提交。
- 没有修改 `lib/`、`test/`、`integration_test/`、`pubspec*`、`android/`、`ios/`、主题、导航、依赖或业务行为。
- 没有修改 `docs/architecture/admin9-ui-implementation-plan.md`，没有执行 Phase 0D、declaration probe 或 Phase 1。
- 仓库未配置 Git remote；本轮没有 push。

## 11. 最终验证

| 检查 | 结果 |
| --- | --- |
| Markdown 尾随空白、表格、围栏和本地图片链接 | Pass |
| 8 个 SVG XML 解析 | Pass |
| 8 个 PNG 尺寸、命名和 SHA-256 | Pass |
| 8 张 PNG 人工可读性、重叠和裁切检查 | Pass（低保真结构） |
| `flutter analyze` | Pass，No issues found |
| `flutter test -r expanded` | Pass，5 tests passed |
| `git diff --check` | Pass |
| 暂存区 | 空 |
| 受禁源码、测试、依赖、平台工程和 v1.1 计划差异 | 无 |

## 12. 用户结构验收入口

唯一推荐是接受当前三页结构作为后续视觉校准起点。用户只需逐页判断：

- 个人中心：可以接受，或指出哪里感觉不自然。
- 认证表单：可以接受，或指出哪里感觉不自然。
- 设置页：可以接受，或指出哪里感觉不自然。

若出现“不舒服”的观察，继续按“观察原文 → 专业诊断 → 行业惯例 → Admin9 唯一推荐 → 严重度 → 处理阶段 → 验收证据”处理，不直接改成 Token、控件高度或实现缺陷。

Gate 1 到此停止。三页结构全部被用户接受前，不制作完整视觉稿，不修订 v1.2，不进入 Phase 0D 或 Phase 1。
