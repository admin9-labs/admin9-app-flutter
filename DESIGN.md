# Admin9 App Foundation Design

## Product Boundary

Admin9 App Foundation 是面向 Android/iOS Flutter 业务 App 的可派生工程基线。它集中维护平台适配、无障碍、品牌身份、通用 App Host 和升级门禁，但不是客户产品、行业模板、媒体基座、多租户运行时、动态模块平台或独立 UI package。

项目使用 **Core、Brand、Business 三类治理边界 + App Host 组合宿主 + feature-first Business 扩展**。这三类边界描述所有权、允许变化和依赖方向，不是传统 UI/Data/Domain 运行时分层：

| 边界 | 责任 | 变化方式 |
| --- | --- | --- |
| Admin9 Core | Token、公共 `App*` 组件、平台映射、无障碍、页面模式、公共 API 和质量门禁 | 只通过受审查的 Design System 版本变化 |
| Brand Theme | 品牌色、Logo、启动资源、获批字体和有限视觉特征 | 只通过派生 manifest 和固定 Brand 入口变化 |
| Business Layer | 真实路由、内容、字段、状态、服务、权限和危险操作条件 | 在派生项目的 feature-first 目录中变化 |
| App Host | 启动、组合根、隐私门禁、导航、账户边界、设置和法务入口 | 组合三类边界，不成为客户随意改写的平台适配层 |

规范性规则以 [Design System](docs/design-system/README.md) 和[派生项目合同](docs/design-system/05-derived-project-contract.md)为准；本文说明当前仓库如何落地这些边界。

## Dependency Rules

- `lib/core/design_system/**` 是 Core 内部实现，`lib/admin9_ui.dart` 是唯一公共 barrel。
- Business 访问 Core 只能导入 `lib/admin9_ui.dart`，不得导入或重新导出 Core 内部文件。
- Business 可以使用本 feature 的实现、`lib/ui/shared/**`，以及 App 白名单中的只读 `lib/app/app_identity.dart` 和 `lib/app/app_route_names.dart`。
- 不允许跨 feature 导入实现；同一派生 App 内第二个相同职责的消费者可先移到 `lib/ui/shared/**`，但它仍属于 Business，不能导出到 `admin9_ui.dart`。
- Brand 的唯一数据入口是 `lib/app/brand/app_brand_theme.dart`。Business 不直接导入 Brand 入口，也不在页面内散落品牌色和平台样式。
- Core 不读取客户内容、Feature ViewModel、Repository、Service、Session 或业务模型。
- App Host 只有 Design System 合同明确允许的少量 Core internal seam；这些 seam 不对 Business 开放。

## Runtime Architecture

- `main.dart` 初始化 Flutter、安装全局错误边界、取得 `SharedPreferences` 并启动 App。
- `Admin9App` 是 Provider、主题、反馈、交互、路由、系统 UI 和隐私门禁的组合根。
- `AppPreferences` 是当前唯一持久化入口，只保存 App 外观、辅助设置和隐私同意。
- 一级导航固定由 `AppBottomNavigation` 映射 Android/iOS 控件；二级页面通过静态命名路由装配。
- 当前没有独立 lifecycle owner。App Host 只在真实需要的位置观察系统无障碍特征变化，并重新解析有效外观状态。
- Gallery 只允许出现在 debug/profile，不进入公共 barrel，也不成为 release 业务路由。

## Business Extension

Business 在 `lib/ui/features/<feature>/**` 内按 feature-first 扩展。默认选择最小充分结构：

1. 简单页面状态和命令可由 ViewModel 管理；View 保持声明式。
2. 出现真实远端、本地数据库或其他数据源后，才在拥有该职责的 Business Feature 内引入 Repository/Service。
3. 只有复杂、稳定且需要跨用例复用的业务规则，才增加 Domain 层。
4. 首个业务组件留在 feature；第二个同客户、同责任消费者可移入 Business shared；跨业务域或跨派生项目出现相同通用责任后，才申请进入 Core。

Foundation 不预设客户 DTO、Repository、Service、Domain、权限模型或模块注册表。缺少这些空层是复杂度控制，不是对未来真实数据架构的禁止。

## Session And Authentication

App 默认且真实地处于游客状态。`SessionController` 表达游客与已认证会话边界，但当前 App 启动和认证表单没有任何路径能创建已认证会话。所有认证和账户敏感操作：

- 执行本地必填、格式、长度和确认值校验；
- 校验通过后进入确定的“服务尚未接入”状态；
- 不发送网络请求、验证码、短信或邮件；
- 不保存用户、密码、Token 或模拟会话；
- 不显示成功结果。

测试可以注入已认证状态验证账户页分支，这不是产品运行时的真实登录能力。

## Appearance And Accessibility

Core 同时解析 Android Material 3 与 iOS Cupertino 公共组件行为。主题支持系统、浅色和深色模式；App 偏好包括字体级别、全局灰度、增强对比度和减少动态。

- App 字体缩放与系统文字缩放相乘，不覆盖系统设置。
- 系统 Bold Text 始终生效。
- 有效高对比度和减少动态为系统设置与 App 设置的逻辑或。
- 灰度只控制 App 自身滤镜，不能抵消操作系统显示调整。
- 响应式布局、语义、对比度、焦点和点击目标由自动化门禁负责；真实读屏、系统手势、IME、安全区和安装/冷启动必须由对应设备证据负责。

缺少当代设备证据时必须记录为 `Unknown`，不能从 Widget 测试或旧版本设备记录推断为通过。

## Privacy And Legal

首次启动显示隐私门禁；只有隐私同意成功持久化后才能进入主页面，写入失败时保持锁定。未同意时不能进入主页面。

用户协议和隐私政策页面有稳定资源标识，但正式文本为空时只显示明确空状态，不编造主体、备案号、地址、电话或条款。客户派生项目必须由真实业务/法务 owner 提供并审核这些内容。

## Brand And Platform Identity

Foundation 只支持 Android 和 iOS。派生项目根 `admin9-foundation.yaml` 是 Foundation 来源、Design System 版本、App identity、Brand evidence、工具链、ownership、compatibility、deviation 和 provenance 的机器记录。

校验通过后，生成器从同一 manifest 写入 Dart Brand/App identity、`pubspec.yaml` 版本与资源列表、Android application ID/namespace/label/icons/launch image，以及 iOS bundle ID/display names/icons/launch images。生成输出不得手工漂移；修改 manifest 后应重新生成并审查。

Foundation 源仓库本身刻意没有根 manifest。源仓库中的 Admin9 identity 是基线默认值；派生项目必须通过 manifest 替换自己的 identity 和 Brand，许可边界以 `LICENSE` 的实际条款为准。

## Version And Evidence Model

- 当前 Design System 为 `v1.0.3`，表示规范和公共合同版本。
- Foundation source 表示 compatibility registry 批准的精确实现 commit。
- Foundation Tag 指向单独 provenance commit，既有 Tag 不移动、不重打。
- App version 位于派生项目 manifest/`pubspec.yaml`，不随 Design System 自动变化。
- 客户业务版本由客户仓库独立管理。
- `flutter build ios --release --no-codesign` 只证明无签名构建；不证明签名、安装、冷启动或设备无障碍结果。

既有 `design-system-v1.0.0` 至 `design-system-v1.0.3` Tag 不包含根 `LICENSE`，并继续保持不可移动、不可重打。派生时应选择 compatibility registry 批准且 checkout 实际包含 `LICENSE` 的来源。

## Non-Goals

Foundation 当前不提供真实后端认证、OIDC、Token、消息、推送、反馈、收藏、历史、媒体频道、稿件、搜索、直播、爆料、服务、积分、活动、商城、H5、WebView、远程 Splash、远程配置、flavor、多 package、macOS、Web 或 Desktop。

这些能力若由真实派生项目需要，应先归入相应 Business Feature；只有出现跨业务或跨派生项目的通用责任与升级证据，才评估 Core 或独立 package。
