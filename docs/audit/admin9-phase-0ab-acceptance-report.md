# Admin9 Phase 0A/0B 验收报告

> **历史记录：** 本文保留 Foundation 阶段当时的验收结论，不是当前 Starter 规范，
> 也不构成对任何 fork 的认证、兼容或支持承诺。

> 日期：2026-07-29
> 代码基线：`main@606938f3b0d1287a3ec3c7fe9791f8e737e52707`
> 最终判断：**Go，仅允许进入 Phase 0C**
> 授权边界：本报告不授权修订 v1.2、实现组件、迁移页面或进入 Phase 1

## 1. 结论

Phase 0A「产品体验定位」与 Phase 0B「当前 UI/UX 审计及参考页面任务书」已达到退出门禁。

Admin9 App Foundation 可以继续作为 Android/iOS 派生项目的通用 Flutter App 基础骨架。其首版体验方向已固定为可靠、克制、高效、平台自然、可扩展、无障碍；当前页面被明确界定为能力边界样本，不是获批的最终产品页面。

本轮没有把用户对注册页比例和个人中心布局的观察直接升级为视觉参数或实现需求。注册页只形成“表单节奏/控件密度待验证”信号，严重度 Unknown；个人中心则被确认是身份、入口和危险操作的信息架构问题，P1，不能交给列表组件解决。

下一步只允许 Phase 0C：制作个人中心、认证表单、设置页的低保真与 Android/iOS 视觉参考，由用户逐页给出接受或不接受判断。Phase 0C 通过后，才能在 Phase 0D 修订 v1.2、处理 static façade 门禁并完成 declaration probe。

## 2. 交付物

| 交付物 | 内容 | SHA-256 |
| --- | --- | --- |
| `docs/product/admin9-app-experience-baseline.md` | 产品角色、六项体验原则、信息层级、页面模式、视觉/平台策略和治理流程 | `5bf7eb7941a404b3b9546b46cb7fcaf514a1283c32161b7ae217359bfbe0fd17` |
| `docs/audit/admin9-ui-experience-audit.md` | 全页面/关键状态盘点、20 条唯一分层审计、两项侧边观察收口和 Unknown | `ff2825ac4c76aac2a0978dc0f743efc48a1fa6f775feb60c828376cc950366b3` |
| `docs/design/admin9-reference-page-briefs.md` | 三张参考页、两条完整任务、平台映射、响应式/无障碍和设计完成门禁 | `d27467fb8243d0bb8b732f1bb86a543ec676fce1b348d7321cff7f9cb044af7a` |
| `registration_large.png` | 用户提供的注册页较大密度观察证据，1320x2868px | `ac4014b91c9873cd444e55e0037867559d10d98694c24eda2c27c2255eec3f47` |
| `registration_standard.png` | 用户提供的注册页标准密度观察证据，1320x2868px | `ba494980a41ff024056c9638260a6741262775ae7a9b048d6efb656753102491` |

截图副本位于 `docs/audit/evidence/admin9-registration-density/`。副本与 `/Users/fengqiyue/Downloads/IMG_1676.PNG`、`IMG_1677.PNG` 的尺寸和 SHA-256 分别一致，原文件未修改。

## 3. 退出门禁

| 门禁 | 结果 | 证据 |
| --- | --- | --- |
| 产品定位与项目边界明确 | Pass | 明确仅服务 Android/iOS 派生 App，不连接后端、不伪造会话、不预设客户业务 |
| 六项原则可执行 | Pass | 每项均有业务定义、规则、正反例、验证和偏离治理 |
| 当前全部页面与关键状态已盘点 | Pass | 隐私、首页、我的两态、六类认证、资料/安全/注销、设置、法务/关于/联系、未知路由及外观/辅助状态均在清单中 |
| 每个问题具有唯一层级与阶段 | Pass | UX-01 至 UX-20 分别落入 A-F 唯一主层级，并提供唯一推荐、严重度、影响和验收方法 |
| 用户观察未直接变成实现要求 | Pass | 注册比例保持 Unknown 且不规定等高；个人中心按 A 层信息架构处理 |
| 三张参考页任务书可执行 | Pass | 个人中心、注册/登录、设置均含目的、层级、状态、双端差异、大字号、页面特例、证据和完成门禁 |
| 完整任务可验证 | Pass | 固定外观设置/重启持久化任务和注册错误修正/未接入任务 |
| v1.2 输入边界清楚 | Pass | 原则与门禁可进入；页面度量、布局和 Token 等待 Phase 0C |
| 没有提前进入 Phase 1 | Pass | 仅新增 Markdown 与截图证据；没有实现、Gallery、页面迁移或测试变更 |

## 4. 审计覆盖与唯一汇合结论

### 4.1 产品与信息架构

- 个人中心固定为“身份摘要与主行动 → 账号能力 → 应用设置 → 法务/关于 → 危险操作”。
- 游客只呈现当前真实可用的登录、注册、找回和公开应用信息；不显示资料、改密、退出或注销等必然失败入口。
- 登录态必须依赖派生项目的真实会话与身份信息；基础骨架不生成模拟用户。
- 空状态、未接入、加载、错误和成功各自只承担一种职责。

### 4.2 页面模式与 Design System

- 当前页面是能力样本，不能从现状 Material 外观直接抽取正式组件。
- 页面信息架构由产品体验层决定；`AppListTile`、`AppSection` 只渲染获批结构。
- 视觉容器与点击区域分别验证。按钮与输入框不要求等高，尺寸使用 minimum constraints 与内容驱动增长。
- 个人中心、认证表单和设置页通过参考设计后，只有稳定且重复出现的共性才能进入 Token 或公共组件。

### 4.3 平台与无障碍

- 品牌语义和状态含义跨平台统一，导航、返回、输入、选择、开关、反馈与系统手势平台原生。
- 设置页 Phase 0C 映射已固定：Android 使用 Material 单选列表和 Switch；iOS 使用带 checkmark 的单选列表和 CupertinoSwitch。
- Android hit target 至少 48x48dp，iOS hit region 至少 44x44pt；普通文字对比度至少 4.5:1，大字与关键非文字边界至少 3:1。
- 系统辅助设置与 App 偏好必须合并，App 选项不得削弱系统要求；具体布局等待参考页验证。

## 5. 对 v1.2 的输入边界

以下结论已稳定，可在 Phase 0D 写入 v1.2：

- 产品定位、公共层/派生项目职责和当前页面的样本属性。
- 六项体验原则、状态职责和观察治理流程。
- 品牌语义统一、平台行为原生的总体策略。
- 视觉容器与点击区域分离、对比度、读屏、键盘和按约束响应式门禁。
- 系统辅助设置与 App 偏好合并、保留非线性字号增长的方向。
- 页面信息架构不能下沉到通用列表组件的边界。

以下内容必须等待 Phase 0C 获批，不得现在写入 v1.2：

- 按钮、输入框、列表行的高度、间距、圆角和最终字号。
- 注册表单的视觉节奏和按钮/字段比例。
- 个人中心最终分组视觉、身份摘要密度和危险区表达。
- 设置行布局、当前值布局和由三张参考页推导的 Token。
- 参考页面尚未证明的公共组件能力、例外参数和平台视觉细节。

本轮不机械修订 `docs/architecture/admin9-ui-implementation-plan.md`。上述两类输入仅在 Phase 0C 验收后由 Phase 0D 一次性收口。

## 6. 引用来源

本轮行业对照使用以下官方来源，回读日期为 2026-07-29：

- Flutter, [General approach to adaptive apps](https://docs.flutter.dev/ui/adaptive-responsive/general)。
- Flutter, [Best practices for adaptive design](https://docs.flutter.dev/ui/adaptive-responsive/best-practices)。
- Flutter, [User input & accessibility](https://docs.flutter.dev/ui/adaptive-responsive/input)。
- Flutter, [Accessibility](https://docs.flutter.dev/ui/accessibility-and-internationalization/accessibility)。
- Flutter API, [MaterialTapTargetSize](https://api.flutter.dev/flutter/material/MaterialTapTargetSize.html)。
- Flutter API, [FilledButton.defaultStyleOf](https://api.flutter.dev/flutter/material/FilledButton/defaultStyleOf.html)。
- Flutter API, [InputDecoration](https://api.flutter.dev/flutter/material/InputDecoration-class.html)。
- Android Developers, [Make apps more accessible](https://developer.android.com/guide/topics/ui/accessibility/apps#touch-targets)。
- Apple HIG, [Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons)。
- Apple HIG, [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)。

证据使用边界：官方硬要求或建议记为 E1，Flutter 当前默认行为记为 E2，仓库现状记为 E3，截图只记为 E4，Admin9 产品判断记为 E5。Material 默认视觉尺寸不是 Apple 视觉规范，截图观感也不是 hit target 或逻辑尺寸证据。

## 7. Unknown 与后续补证

以下 Unknown 不阻止制作 Phase 0C 参考方案，但阻止宣称体验已实现或通过：

- Android 全页面视觉、edge-to-edge、IME、predictive back、TalkBack、Switch Access 和真机大字号。
- iOS 最大 Dynamic Type、VoiceOver、Switch Control、Bold Text、系统高对比度和真实边缘返回取消/完成。
- 两张注册截图的逻辑窗口、系统/App 字号、显示缩放和实际 hit bounds。
- 登录态真实身份内容、账号权限、正式法务/联系方式和后端完成结果。
- 320/360/390/600、横屏、键盘 traversal、Semantics 和对比度的实现证据。

Phase 0C 只需在明确假设下设计这些状态并列出验证路径，不得伪造设备结果。真机与自动化证据在对应实现阶段取得。

## 8. 工作区与变更边界

本轮开始与结束均以 `main@606938f3b0d1287a3ec3c7fe9791f8e737e52707` 为代码基线。开始时已有且未修改的 Phase 0 产物为：

- `docs/architecture/admin9-ui-phase-0-acceptance-report.md`，SHA-256 `838a402b6369ce650edb203359cebb1340eb942cc1910d934ea5481dddfdae5d`。
- `docs/architecture/evidence/admin9-ui-phase-0/` 下六张 iOS 截图；其 SHA-256 与原 Phase 0 报告第 8.2 节一致。

本轮只新增本报告、第 2 节列出的三份文档和两张截图副本。没有修改 `lib/`、`test/`、`integration_test/`、`pubspec*`、平台工程、主题、导航、业务行为、v1.1 计划、原 Phase 0 报告或原 evidence。所有新增内容保持未跟踪、未暂存、未提交；没有 push。

只读验证结果：

- `flutter analyze`：通过，`No issues found`。
- `flutter test -r expanded`：通过，5 项测试全部完成。
- 新增 Markdown 尾随空白检查：通过。
- Markdown 表格列数一致性检查：通过。
- `git diff --check`：通过；已跟踪文件差异为空，暂存区为空。
- 原 Phase 0 报告和六张 evidence 的 SHA-256 与本轮开始时一致。

## 9. 最终判断

**Go：允许进入 Phase 0C，且只允许制作三张参考页面的结构与双端视觉方案。**

本判断不是 Phase 1 的 Go，也不是 v1.2 修订授权。Phase 0C 必须使用本轮固定任务书，由用户只判断参考页接受或不接受；专业参数、Token、API 和测试方法仍由产品、设计和工程责任人收口。
