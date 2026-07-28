# Design

## Source of truth

- Status: Active draft
- Last refreshed: 2026-07-29
- Primary product surface: the local-media Flutter App in this repository, with reusable infrastructure serving product delivery. Go backend and Vue Admin live in `admin9-app-admin` and remain separate delivery surfaces.
- Evidence reviewed:
  - User-provided Sichuan Observer reference screenshots for profile, settings, login, messages, about, feedback, report, history, and community/activity layouts.
  - `lib/app/admin9_app.dart`, `lib/app/admin9_shell.dart`
  - `lib/core/theme/app_theme.dart`, `lib/core/theme/app_spacing.dart`
  - `lib/core/widgets/top_level_page_scaffold.dart`, `lib/core/widgets/app_search_entry.dart`
  - `lib/ui/features/mine/views/*`
  - User-provided 2026-06-08 and 2026-06-09 iPhone screen recordings covering top-level page scroll behavior in light and dark modes.
  - `README.md`
  - `docs/architecture/modular-media-app-plan.md`

## Project positioning

本项目是一个带有可复用基础设施的地方融媒体 App。“西昌发布”是默认实例；基础设施服务于产品持续交付和客户复用，不把项目扩展成通用 App 平台、插件市场或运行时多租户系统。

本文中的术语统一如下：

- **Flutter App 基座**：地方融媒体 App 内可复用的稳定宿主、设计系统、配置解析、模块装配、状态与存储基础设施；它服务于产品，不是独立的通用平台。
- **AppProfile**：由构建流程中唯一、规范化的 `profileId` 选定的独立 App 身份，集中定义名称、不可跨客户切换的品牌/合规资料、平台身份引用、允许能力和安全上限；它不自报安装包物理事实。
- **默认实例**：仓库当前可运行、可回归的“西昌发布”`AppProfile`。它是迁移兼容基线，不是可以散落到通用实现中的全局常量集合。
- **UserSession**：当前 App 内的登录用户、令牌状态和授权摘要，不参与 `AppProfile` 选择。
- **地方融媒体行业核心**：首页、频道、稿件及其必要的内容展示、检索入口和详情链路。这些能力定义产品类别，不视为待清除的历史演示页面。
- **可选业务能力**：直播、爆料、服务、积分等不定义产品类别、可按客户需要选配的能力；实施前另行选择原生、H5、混合或受控外部系统。当前代码只是遗留原型兼容实现，不构成产品对包含关系或载体的批准。
- **原生模块 / AppModule**：随安装包交付的 Flutter 实现，是业务能力的一种交付载体，不代表所有可选业务能力。
- **H5 轻应用**：运行在统一受控容器中的 Web 交付载体，可承载低频定制或频繁变化的业务主流程；只有获批需求确实需要宿主能力时，才使用声明并获授权的版本化 Bridge。
- **混合交付**：原生承载稳定入口、高体验或设备能力，H5 承载频繁变化的业务主流程；混合本身是一种确定的获批实现，不表示运行期可在原生与 H5 之间切换。第三方办事系统也可采用经过宿主策略校验的受控外部跳转。
- **核心基座**：`AppProfile`、最小原生模块装配、状态与存储拆分，以及全部活跃 WebView/调用入口的容器化和安全加固。
- **条件能力**：版本化业务 Bridge 和经可验证真实性签名的正式 `RemoteAppConfig` 拉取链路；只有对应产品、API、安全和运维条件成立时实施。

本项目的复用单位是代码基座；同一基座可为不同客户选择不同 `AppProfile` 分别构建；每个生产包对应一个独立 App。

详细目标架构和增量迁移步骤见 [`docs/architecture/modular-media-app-plan.md`](docs/architecture/modular-media-app-plan.md)。

## Architecture invariants

- “西昌发布”是明确请求默认实例时使用的 `AppProfile`。客户名称、Logo、许可证、协议和地址不得散落在通用代码中，必须由 `AppProfile` 或其引用的受控资源提供；用户可选 theme preset/accent palette 只改变允许范围内的外观，不能改变品牌、Logo、法务或平台身份。
- 一个生产安装包只绑定一个 `AppProfile`，且该身份在运行期不可切换；所有 flavor、入口或 `--dart-define` 只能承载同一个规范化 `profileId`。显式客户 profile 无效、生产 profile 缺失或平台身份不完整时必须 fail closed，不能回退西昌。
- `AppProfile` 不包含交付载体引用，也不按 profile 为同一能力选择不同实现；某产品版本完成载体批准后只实现并维护获批方案，当前遗留原型代码不因此获得批准资格。
- 首页、频道、稿件是地方融媒体行业核心能力，不因模块化迁移被降级为一次性演示内容。
- 直播、爆料、服务、积分等是候选业务能力，不保证每个客户包含，也不预设采用原生、H5、混合或受控外部跳转。
- 业务能力选择与交付载体选择是两个实施前决策；凡作为产品能力进入某次产品装配、构建规范的 approved set 或待验收产物的运行时装配，必须在 `resolveBuild` 前取得该版本唯一载体批准。未批准能力不得因默认西昌、历史五 Tab 或当前代码存在而自动注册/启用；在物理裁剪 ADR 前遗留代码或插件仍可能存在于二进制中，canonical manifest 必须如实记录这种打包事实，但物理存在不产生产品批准。
- 当前核心基座对原生能力的可验证保证是运行时裁剪：未选或禁用时不注册入口、Provider、状态、存储加载、订阅、后台任务及其他运行时副作用；仅隐藏入口不算裁剪。
- 代码、插件和第三方原生 SDK 不进入特定客户安装包属于更强的客户级构建目标，须由独立构建组织/打包 ADR 保证；当前单一 `pubspec.yaml`、无 flavor 的仓库不能据此宣称 SDK 或平台权限已物理排除。现在仍须固定 `resolveBuild -> artifact + canonical manifest -> verifyArtifact` 的输入输出边界，不等到 ADR 才补产物证明。
- `packagedCapabilities` 是构建所有的能力事实，不是 `AppProfile` 字段；唯一 canonical `PackagedCapabilityManifest` 必须嵌入产物或与产物不可分割绑定，由 verifier 与 artifact/spec 一起验证，attestation 绑定三者及源码/profile/产品决策 digest 和 verifier version。运行时只能消费该份已验证 manifest；最终身份、依赖/SDK、权限/entitlements、网络例外和 Bridge 必须从目标平台产物回读。配置集合必须满足 `defaultEnabledCapabilities ⊆ profileAllowedCapabilities ⊆ packagedCapabilities`。
- 宿主组合根可以依赖各 feature 的公开工厂、窄入口和稳定契约并负责装配；Feature 不得依赖另一个 feature 的实现文件，也不得经 `data/domain/core/shared` 或 re-export 绕道依赖候选能力实现。历史 32 条 import 与覆盖全 `lib/` 所有权表的语义违规必须分别归零。
- 跨 feature 跳转通过宿主注入的少量类型明确回调或公开契约完成，不建立包含所有页面方法的万能导航服务。
- 第一版 `AppModule` 只要求稳定 `moduleId`、延迟创建依赖的工厂、可选最小 `AppShellSection`，以及真实需要时的清理钩子；Registry 必须在任何工厂调用前完成 module/section ID 冲突校验和禁用过滤。section builder 只接收当前真实需要的 `isActive`、reselect/scroll-to-top 等窄宿主信号；不建设通用生命周期或热卸载框架。
- 已打包原生模块禁用后，其入口、内部路由、Provider、状态、存储加载、订阅和后台任务均不得注册或启动；隐藏 UI 不是禁用模块。
- 首页、稿件、直播、爆料和服务通过小而类型明确的 `EngagementEventSink` 上报已发生行为，不依赖 points 实现；任何首切片只要产生六类事件之一，就同步前移最小 `SessionAccess`、opaque `AccountScope`、sink、no-op 和必要的遗留 adapter。手机号只允许留在遗留 adapter 私有实现中，不能进入公共契约；这不关闭稳定 subject 与 guest 策略的 Unknown。points 禁用时不得初始化 points 状态。
- 远程配置只能启停或调整当前 `AppProfile` 允许、安装包已包含且产品方案已经确定的实现；必须使用可验证来源真实性的签名、单调 generation、防回放、原子应用、LKG 最大陈旧期和安全回滚，不能改变交付载体、执行新 Dart 或扩大安全上限。
- `ChannelH5Tab`、`InAppWebPage` 及全部活跃调用入口都属于 H5 安全边界，必须受 HTTPS、逐跳重定向/外链和明确生命周期约束；`trustedMiniAppOrigins` 与媒体 `cleartextMediaHosts` 分离。当前 `Admin9H5LinkBridge` 只是容器内部链接通道，不具备可信 frame/origin 证明，不能直接作为业务 Bridge；真实消费者出现后先证明 top-frame transport，再增加逐项授权、版本化 Bridge 和审计。
- 顶层导航由宿主根据已构建能力的公开入口装配；当前不建设通用 `AppDestination`、命名路由或统一深链分发层。
- 迁移期间默认西昌实例的可见行为和既有本地数据保持不变，除非另有明确产品决定和迁移说明。
- 核心迁移依次引入 `AppProfile` 与构建证明边界、最小 `AppModule` / `ModuleRegistry` 与导航边界、状态与存储拆分、全部现有 H5 入口加固；完整 Bridge 和正式远程配置属于条件阶段。
- Android/iOS 的正式发行范围，以及 macOS/Web 是仅预览还是真实发行，仍须由产品与 Release owner 决定；编译或浏览器预览不能自动升级为正式平台承诺。
- 当前阶段不先大规模移动目录，不立即拆分多个 package，不迁移路由框架，不把所有页面改成 H5，也不引入动态 Dart。

## Brand

- Personality: local media, practical, bright, trustworthy, service-oriented.
- Trust signals: clear account status, agreement links, report/contact surfaces, about/version information, predictable settings.
- Avoid: one-off page styling, hard-coded colors in feature pages, decorative visual noise that weakens readability, and business surfaces that imply real public APIs before a product decision.

## Product goals

- Goals:
  - Deliver a local-media Flutter App with reusable infrastructure, using “西昌发布” as the default app profile and regression instance.
  - Treat home, channels, and articles as industry-core capabilities while selecting one approved native, H5, hybrid, or controlled-external implementation for each optional capability before implementation.
  - Harden the current H5 surface first; add a versioned business Bridge only when an approved capability requires host access.
  - Support profile-allowed theme preset/accent palette switching, dark mode, app font-size levels, and one-tap global grayscale for memorial or public-event needs without changing App brand identity.
  - Keep static repositories replaceable by future API repositories without rewriting UI structure.
- Non-goals:
  - Do not create a generic blank Flutter starter that removes the local-media product category.
  - Do not perform a big-bang folder migration, package split, router replacement, or H5 rewrite as the first architecture step.
  - Do not download or execute dynamic Dart code; remote configuration only selects capabilities already present in the signed app package.
  - Do not add real public-client APIs, CMS contracts, SMS login, third-party OAuth, payment, mall, order, or activity business flows in this iteration.
  - Do not make the Flutter prototype part of backend/Admin formal acceptance until API, deployment, and acceptance contracts are explicitly added.
  - Treat third-party login, SMS, and push Admin configs as reserved placeholders only; they have no runtime App/API effect in this iteration.
- Success signals:
  - A new customer build resolves exactly one approved `AppProfile`; invalid explicit input fails before producing an artifact rather than falling back to Xichang.
  - An unneeded optional capability can be omitted from product assembly and runtime initialization; physical package exclusion is claimed only after target-artifact attestation, with build topology selected by a customer-level ADR when first required.
  - Host assembly and typed callbacks keep feature implementations independent without introducing an unproven universal destination system.
  - Disabled packaged native modules contribute no navigation, routes, providers, state, or background work.
  - Every active WebView entry stays within approved navigation and lifecycle policy; the existing internal JavaScript channel is not treated as a business Bridge, and any later Bridge exposes only explicitly authorized capabilities over a proven transport.
  - New pages use shared tokens/components instead of local visual decisions.
  - Theme, dark mode, grayscale, and font-size settings survive app restart.
  - Widget tests cover the core foundation settings and navigation flows.

## Personas and jobs

- Primary personas:
  - Local citizen using a news/service app repeatedly during the day.
  - Product/demo reviewer evaluating whether the app can be rebranded for another local-media customer.
  - Future implementer replacing static repositories with real API-backed repositories.
- User jobs:
  - Sign in or understand why signing in is optional.
  - Manage notifications, font size, theme, account bindings, cache, and app information.
  - Read system messages and submit feedback or harmful-information reports.
  - Recognize the app as trustworthy and locally branded.
- Key contexts of use: mobile-first, one-hand operation, outdoor reading, older users needing larger text, event-day grayscale requirement.

## Information architecture

- Primary navigation for the default Xichang profile remains the five-tab `首页`, `直播`, `爆料`, `服务`, `我的` layout during migration; builds for other customers derive optional entries from selected capabilities and signed-package host/module assembly. Runtime configuration may hide or reorder permitted entries but cannot change their implementation.
- Top-level page roles:
  - `首页` is the information-feed entry and uses fixed search plus channel navigation, without a visible `首页` title.
  - The home top Chrome still participates in PageSurface: the brand backdrop is clipped to the fixed search and channel container, and scrolling must not move the backdrop into feed content.
  - Top-level function pages do not render page titles in the active prototype; the bottom tab state and page content identify the section.
  - Current `直播`, `爆料`, `服务`, and `我的` do not render a fixed top surface strip. They keep only the real status safe area, then page content.
  - Top-level utility actions should live in page content when the top strip is absent; `我的` exposes settings and messages from its function grid.
- Core foundation routes/screens:
  - `我的`: profile/login state, account status, common actions, message and settings entries.
  - `登录`: phone login mock, one-tap phone login mock, third-party login mock entries, agreement links.
  - `设置`: account, font size, appearance, push, report, cache, about, logout.
  - `账号与安全`: phone, mock bindings, account cancellation entry.
  - `消息中心`: comment, likes, followers, system messages with tab-style filtering.
  - `意见反馈`: text input, counter, submit state.
  - `有害信息举报`: phone cards, email, official report-center links.
  - `关于`: app mark, slogan, agreements, version, license/permit copy.
  - `协议/隐私`: local static document pages.
- Content hierarchy: foundation pages should prioritize account state and actions first, then secondary legal/support information.

## Design principles

- Foundation before feature: build reusable theme, settings, and components before adding business-specific screens.
- Familiar mobile patterns: large top spacing, centered titles on detail pages, back button at top left, rounded white groups, clear chevrons and switches.
- Brandable restraint: the app should feel bright and local-media friendly while staying easy to recolor from tokens.
- Progressive commitment: use static data first; adding real APIs requires repository replacement plus documented contracts.
- Accessibility is part of the token system: large text, contrast, touch targets, and reduced motion are validation criteria.
- Visual smoke must include theme combinations, not only default light mode. At minimum verify light, dark, dark + global grayscale, and large-font dark mode on dense foundation/content pages.

## Visual language

- Color:
  - Default brand follows the references: fresh blue primary with green secondary accents.
  - Additional theme presets should include government red and service green to prove palette flexibility within the active `AppProfile` allowlist.
  - Page background is light cool gray; cards and list groups are white in light mode.
  - Accent yellow/orange is reserved for focused status, warning, or call-to-action states.
  - Dark mode must be explicit, not a tinted light theme.
  - Global grayscale is a top-level rendering state and must affect the whole app.
  - Top-surface imagery is configured by `PageSurface`/`PageBackdrop`, not by normal content blocks. Prefer a configured image when available; fall back to `PageBackdropPreset.softBrand`, a restrained blue, blush, and warm tint that fades quickly into the page background.
  - 首页频道级沉浸皮肤是独立的 `MediaChannelStyle.surfaceMode` 能力：普通频道仍只使用固定搜索和频道栏，配置为 `immersive` 的频道才在内容区背后渲染首屏运营背景。
- Typography:
  - Use platform/system Chinese fonts.
  - Page titles: strong 22-26sp.
  - Navigation/detail titles: 18-20sp, semibold.
  - Section/module titles: 20sp medium; avoid using heavy weight alone to create hierarchy.
  - Card-internal group titles: 17sp medium; keep them quieter than page-level section titles.
  - List rows: 17-18sp.
  - Secondary/meta text: 13-15sp.
  - Font-size levels: standard, medium, large. They stack with system accessibility scaling rather than replacing it.
- Spacing/layout rhythm:
  - Page horizontal padding: 16px.
  - Card/group gap: 12-16px.
  - Row height target: 56-64px.
  - Top safe-area breathing room should match mobile app references.
- Shape/radius/elevation:
  - Main cards/list groups: 8px radius, flat white surface, minimal shadow.
  - Buttons: pill shape for primary actions.
  - Image thumbnails: 8-10px radius.
  - Avoid nested cards; sections are grouped surfaces, items are rows.
- Motion:
  - Keep transitions native and simple.
  - Avoid decorative animation in foundation pages.
  - For top-level function pages, avoid decorative top-surface motion while this layout is being re-evaluated.
- Imagery/iconography:
  - Use simple line icons for foundation actions.
  - Brand imagery belongs in app logo/about/profile surfaces, not scattered page backgrounds.

## Design-token contract

- Color roles:
  - `brand.primary`, `brand.secondary`, and `brand.accent` drive brandable UI; feature pages must not hard-code brand blue, red, or green when a token exists.
  - `pageBackground`, `cardBackground`/`surface`, `softFill`, and `divider` define the shallow gray background and white-card structure.
  - `textPrimary`, `textSecondary`, and `textTertiary` define hierarchy; body copy must not rely on opacity-only black/white values.
  - `danger`, `warning`, `success`, `info`, `pressed`, `selected`, and `unread` define semantic states.
- Type roles:
  - `AppTypography.pageTitle`: top-level page titles such as `直播`, `爆料`, `服务`, and primary foundation page leads.
  - `AppTypography.sectionTitle`: 20sp / `w500` meaningful module/group titles such as `热门线索`, `直播预告与回放`, `办理提示`, and settings section labels. Do not repeat the selected channel label as an in-feed section title.
  - `AppTypography.cardSectionTitle`: 17sp / `w500` card-internal group titles such as `便民服务`; these group actions inside a card and must not compete with feed or page-level titles.
  - `AppTypography.feedTitle`: normal news/feed titles. Text-image, large-image, and three-image article cards use the same role instead of changing size by layout.
  - `AppTypography.feedTitleCompact`: compact feed/list titles such as live strips, politics article rows, report rows, service tiles, message titles, and empty-state titles.
  - `AppTypography.feedMeta`: source, time, status explanation, location, secondary row text, and other metadata.
  - `AppTypography.feedSummary`: article/detail summaries and readable explanatory copy that is more prominent than metadata.
  - `AppTypography.heroTitle`: profile names, article/detail titles, live hero titles, and app/about brand marks.
  - `AppTypography.coverTitle`: carousel cover titles and operation/banner titles.
  - `AppTypography.tabLabel`: channel/filter tab labels in app-owned tab bars.
  - `AppTypography.settingsTitle` and `AppTypography.settingsValue`: settings/list-group row titles and right-side values.
  - `AppTypography.bodyText`: long readable body paragraphs outside of intentionally document-like pages.
  - `AppTypography.actionLabel`: bottom/module navigation labels such as function grids, quick actions, service shortcuts, and other tap targets that represent a destination.
  - `AppTypography.label`: badges, status pills, compact auxiliary labels, and small controls. Do not use it for module navigation text.
  - Feed and section hierarchy should come from semantic role, placement, spacing, and color. Do not compensate for unclear hierarchy by scattering heavier ad hoc font weights through pages.
  - Article `contentTag` is optional and typed as `ArticleContentTag`; it only represents a real content taxonomy label such as `时政`, `直播`, `视频`, `文旅`, `体育`, or `政声`. It is not a channel name, block title, recommendation reason, or distribution label. This closed enum is a static-prototype contract; a real CMS/API should map remote taxonomy through a repository/DTO layer before widening the domain model.
  - `ThemeData.textTheme` remains the base scale for Material widgets, not a second app design system. Feature pages should consume the semantic `context.typography` roles for standard content; direct `fontSize` is allowed only inside Material primitives, reusable components, protocol/document pages, splash/media overlays, or documented visual exceptions.
- Spacing roles:
  - Base scale: 4, 6, 8, 12, 16, 20, 24, 32.
  - Page horizontal padding: 16.
  - Section gap: 14.
  - Card padding: 16.
  - Row minimum height: 56.
  - Bottom navigation height: 72.
  - Wider preview content should cap at a comfortable width instead of stretching full-screen rows.
- Radius, line, and shadow roles:
  - Cards/list groups: 8.
  - Image thumbnails: 8-10.
  - Large brand/app marks and avatars: 20-24.
  - Chips/badges/buttons/status labels: pill / 999.
  - Divider thickness: 1 physical logical pixel with token color.
  - Default cards remain flat; shadow is reserved for temporary draggable/editing affordances.
- Size roles:
  - Default icon: 24.
  - Foundation action icon: 28.
  - Function-grid icon container: 44.
  - Minimum touch target: 44.
  - Top-surface image design reference: 216 logical px remains the default upload/display reference, but visible height is owned by each page shell's top container rather than forced across every page.
  - Top-surface image uploads should target 1440 x 800 px, with 1080 x 600 px as the minimum acceptable size. The app displays the image inside the active top container using `BoxFit.cover` and `Alignment.bottomCenter`, so images are cropped while preserving aspect ratio. They must not stretch or tile.
  - Home immersive channel skin uploads should target 1440 x 1440 px, with 1080 x 1080 px as the minimum acceptable size. The app displays the image behind the channel content using `BoxFit.cover` and `Alignment.topCenter`, with a default visible height around 320 logical px and a larger channel content top inset around 56 logical px.

## Page templates

- Top-level tab pages:
  - Use `SafeArea(bottom: false)` with single-column vertical structure.
  - Use token page padding and section gaps.
  - Bottom content padding must account for the navigation bar.
  - `首页` keeps search and channel tabs pinned; the search copy remains `搜索新闻、服务`, and no `首页` title is rendered.
  - Home uses the active PageSurface top-surface image configuration for its fixed search and channel container. Normal first-level function pages do not render that top-surface image in the active scaffold.
  - The normal home Top Surface pattern is not an immersive channel skin. 首页频道级沉浸皮肤仍是频道样式的显式能力，但当前默认频道先回到普通场景背景切换，不把沉浸皮肤作为「专题」默认验证样例。
  - `直播`, `爆料`, `服务`, and `我的` do not render top page titles or top-surface strips in the active scaffold. Both the expanded large-title collapse and the centered compact-title version are backed up on separate recovery branches.
  - Status bar safe area remains device-driven; Web preview does not add fake iOS status-bar height.
  - In this document, Top Chrome means the fixed top UI controls and their surface treatment, not the Chrome browser.
  - The Top Surface backdrop belongs to the page shell's top Chrome, not to the scrolling content. In the active scaffold it is rendered only by `首页`, inside the status safe area plus search/channel rows.
  - Top-surface containers use bottom-center image alignment, overflow clipped, no page-level backdrop behind announcements, cards, or feed rows.
  - Home channel content starts after the pinned search/channel container with a tokenized gap, so announcements and first cards do not visually stick to the Tabs.
  - Scrolling must not make the home backdrop fall into content or fade out as a page background. When a top-surface image is configured, the normal light-mode home top surface renders the image plus the bottom divider only; it does not add a transparent page-color overlay. Readability should come from choosing a suitable configured image and from the controls' own surfaces.
  - If the light-mode configured asset or URL fails to load, the home shell uses the `softBrand` gradient fallback rather than leaving the top empty.
  - Dark mode should use a dedicated dark top-surface image when configured. If no dark image is configured, the app hides the image backdrop and keeps only the dark page background plus home top Chrome; it must not reuse or auto-dim a light image as a dark-mode substitute.
  - Immersive home channel skins follow the same theme rule: a dark theme renders only a configured dark immersive image. If no dark immersive image exists, the app disables the immersive background and uses normal dark page spacing instead of showing the light image or leaving a large empty opening.
  - PageBlock remains a content renderer only. It may render carousels, notices, entry grids, special groups, and feeds, but it must not own page-shell background, search, channel tabs, status-bar treatment, or channel-level skin behavior.
- Detail and settings pages:
  - Use `FoundationPage` unless the page has an explicit immersive visual reason not to.
  - App bar title is centered and 18sp semibold.
  - Content is capped on tablet/desktop preview.
- Form pages:
  - Use the same `FoundationPage` rhythm.
  - Inputs use theme `InputDecorationTheme`; primary actions use pill buttons.
  - Validation errors use snackbars or concise inline text.
- Message pages:
  - Filtering tabs use the shared tab treatment.
  - Message cards show unread through dot/state token, not color alone.
- Home recommendation pages:
  - Channel labels such as `推荐`, `政声`, and `视频` belong to tabs or channel management only.
  - `HomeBlock.title` belongs to non-feed module titles such as `便民服务` and `正在关注`; `HomeBlock.feedHeaderTitle` is the only article-feed header source.
  - The default recommendation feed keeps `feedHeaderTitle == null` and does not render another standalone `推荐` title inside the stream because the selected channel already provides that context.
  - Real named article feeds may use `feedHeaderTitle` values such as `本地关注`; generic distribution words such as `推荐`, `热门`, or `置顶` must not be used as feed headers.
  - Article `contentTag` may appear on detail pages only through `ContentTagPill`; cards hide it and prioritize title, visual, source, and time.
  - Content cards prioritize title, visual, source, time, and useful media state before any distribution reason.
  - `StatusPill` is reserved for decision-making status such as `直播中`, `预告`, `回放`, `已提交`, or moderation/report status.
  - `MediaBadge` is reserved for media/overlay badges such as cover labels, video duration, play markers, or compact corner badges like `新`.
  - Generic distribution labels such as a standalone `推荐` must not appear inside a single content card or as a duplicate in-feed heading.
- Login pages:
  - May use larger top whitespace, but must keep text roles, button roles, and agreement links consistent.
- Splash, news cover, and operation banner exceptions:
  - These may use custom composition, image overlays, and larger display type.
  - Use named roles such as `heroTitle` or `coverTitle` before introducing local type.
  - Local `TextStyle(fontSize: ...)` is acceptable for indicator counters, media overlays, and one-off splash controls only inside the owning component.
  - They must still use token colors where practical and must preserve font-size, dark-mode, and grayscale behavior.

## Components

- Existing components to reuse:
  - `AppCard`, `ArticleVisual`, `EmptyState`, `StatusPill`, `ContentTagPill`, `MediaBadge`.
- New/changed components:
  - Foundation page scaffold with safe-area header.
  - Settings group and settings row with chevron/switch/value variants.
  - Function grid item.
  - Message card with unread dot.
  - Primary pill button and danger text button.
  - Agreement text/link row.
  - Theme preset/accent palette selector; it changes appearance only, not App brand identity.
- Variants and states:
  - Loading, empty, error, disabled, selected, unread, destructive, logged-in, logged-out.
- Token/component ownership:
  - `core/theme` owns colors, text styles, spacing, radii, and appearance state.
  - `core/widgets` owns foundation components.
  - Feature pages consume tokens/components; they should not define new visual systems.

### Component contract

- `FoundationPage`: default shell for settings/detail/form pages; owns app bar, page padding, content width cap, and bottom breathing room.
- `AppCard`: default grouped surface; owns radius, padding, click state, and disabled click behavior.
- `SettingsGroup` and `SettingsRow`: default list group; own row height, divider, chevron, switch/value alignment, danger color, and icon sizing.
- `FunctionGrid`: default action grid; owns responsive column count, icon container, badge placement, and single-line labels.
- `MessageCard`: default notification item; owns card padding, unread dot, title/time hierarchy, and selected/pressed state.
- `SectionHeader`: default section label used above groups and cards.
- `CardSectionHeader`: default card-internal group header, including service grids inside a card; it owns `cardSectionTitle` consumption. Page-level list or feed sections use `SectionHeader` or `sectionTitle`.
- `StatusPill`: status-only label for live, report, workflow, or moderation state. Do not use it for article taxonomy, cover labels, or distribution reasons.
- `ContentTagPill`: article-detail taxonomy label backed by `ArticleContentTag`; do not pass arbitrary strings.
- `MediaBadge`: cover/media overlay badge for video duration, play affordances, banner labels, and compact visual badges.
- Pill components are intentionally separated by semantic role even when their geometry is similar; do not collapse them into a generic badge unless the caller semantics stay explicit.
- `PrimaryPillButton`: default primary command when a plain `FilledButton` would repeat local style.
- `AppTabBar`: default channel/filter tab treatment before reaching for custom `TabBar` styling.
- Exceptions must be local and named: if a feature needs custom spacing, radius, color, or type, keep it in the component that owns the visual pattern rather than scattering values through pages.

## Accessibility

- Target standard: practical mobile accessibility suitable for large Chinese text and touch use.
- Keyboard/focus behavior: form fields and buttons must have predictable traversal; no hidden required action.
- Contrast/readability: light and dark modes must keep body text and buttons legible; grayscale must not rely on color alone.
- Selection/readability: selected tabs, bottom navigation, chips, quick actions, and service grids must remain distinguishable by luminance, font weight, shape, or structure when global grayscale is active. Accent color alone is not an acceptable state signal.
- Screen-reader semantics: icon-only controls need tooltips/labels; login and setting rows should expose intent.
- Screen-reader semantics: search entry surfaces are buttons with explicit labels, not decorative gray bars.
- Reduced motion and sensory considerations: keep motion minimal; do not depend on animation for state understanding.

## Responsive behavior

- Supported breakpoints/devices: phone-first; tablet/desktop should remain usable for Flutter preview but is not the main design target.
- Layout adaptations:
  - Phone uses single-column scroll pages.
  - Wider screens cap content width or keep comfortable padding rather than stretching rows.
- Touch/hover differences: touch targets should be at least 44px; hover states are optional for desktop preview.

## Interaction states

- Loading: use native progress indicators or skeleton-like placeholders only when data is actually pending.
- Empty: use short Chinese explanation and one useful action when available.
- Error: show concise recovery copy; static prototype should avoid fake server errors unless demonstrating state.
- Success: use snackbars or inline confirmation.
- Disabled: disabled controls must look disabled and remain readable.
- Offline/slow network: future API-backed repositories should surface repository-level states; current static data may document this as a future hook.

## Content voice

- Tone: concise, clear, service-oriented Chinese.
- Terminology:
  - Use `我的`, `设置`, `账号与安全`, `字体大小`, `外观主题`, `系统消息`, `意见反馈`, `有害信息举报`, `关于`.
  - Use `原型` or `本地模拟` when describing fake login or static data.
- Microcopy rules:
  - Avoid promising real delivery for mock actions.
  - Legal/support entries should sound formal and trustworthy.
  - Button labels should be direct verbs, not explanations.

## Implementation constraints

- Framework/styling system: Flutter 3.44, Material 3, `provider`, `ChangeNotifier`, `SharedPreferences`.
- Design-token constraints:
  - Build themes from profile-allowed theme presets/accent palettes and `ColorScheme`; reserve “brand identity” for `AppProfile` name, Logo, legal copy, and platform metadata.
  - No feature page should hard-code a profile brand or user accent color when a semantic token exists.
  - Global grayscale should be applied near `MaterialApp.builder`.
- Architecture constraints:
  - Preserve UI / ViewModel / Repository / Service separation.
  - Static data lives in repositories; page widgets should stay thin.
  - Do not introduce a new routing or state-management dependency unless a concrete future requirement needs it.
- Performance constraints:
  - Avoid rebuilding the full app except for appearance changes.
  - Keep foundation pages lightweight and image-light.
  - Watch the home feed header rebuild range once static lists are replaced by real content; the current prototype behavior is acceptable for v0.
- Compatibility constraints:
  - Keep one Git root; no nested `.git` under `app`.
  - Do not reintroduce removed public-client APIs or backend content/page/statistics surfaces.
- Test/screenshot expectations:
  - Run `dart format lib test`, `flutter analyze`, and `flutter test` after Flutter changes.
  - Add widget tests for theme, font-size, grayscale, settings navigation, login agreement, messages, and feedback limits.
  - For visual smoke, explicitly cover `首页`, `我的`, `设置`, `外观主题`, and `频道管理` in dark + global grayscale. Check for low-contrast text, color-only selected states, clipped labels, and horizontal overflow before calling smoke complete.

## Historical UI foundation verification checklist

- Historical check 0: Design source and Flutter prototype boundary are documented.
- Historical check 1: Theme tokens and appearance state exist and are persisted.
- Historical check 2: Foundation pages consume shared components and route through a consistent navigation helper.
- Historical check 3: Widget tests cover core user-foundation behavior.
- Historical check 4: `$code-review` runs clean or all blocking findings are fixed.

## UI iteration model

- Treat the Flutter mobile app as an iterative product with reusable infrastructure, not a one-shot page fill.
- Each UI change should be independently verifiable and committed separately when possible; these historical checks are not the architecture migration stages in the modular-media plan.
- Keep static data behind repository/model boundaries so future API integration replaces data sources instead of rewriting UI.
- Use widget tests as the first regression layer for foundation behavior: login agreement gating, settings navigation, appearance switching, font levels, grayscale, messages, and feedback limits.
- Use integration tests later when real device capabilities, public APIs, deep links, or third-party login/SMS SDKs are introduced.
- Do not add new routing/state/dependency layers unless a later gate proves a concrete need.

## Design audit checklist

- Typography hierarchy:同类标题使用同一语义角色；卡片内组标题不能抢页面级模块标题。
- Information noise:每个可见标签必须帮助用户判断内容、状态或动作；泛化分发词不得进入单条卡片，也不得在当前频道的信息流里重复出现。
- Label semantics:频道、模块标题、状态、来源、时长、推荐理由是不同语义，不能互相复用。
- Color intensity:高饱和品牌/警示色只用于状态、选择或明确行动，不用于普通分组标题。
- Shape density:卡片、图片、头像、胶囊按语义圆角阶梯使用，不按页面临时感觉散写。
- Theme resilience:新增组件必须在浅色、暗色、暗色 + 全局灰、大字体下仍保持层级和可读性。

## Open questions

- [ ] Replace placeholder app mark and legal/permit text when a real brand package is chosen.
- [ ] Decide whether a future formal mobile client should connect to new public APIs or a separate BFF.
- [ ] Decide whether deep links or web URL support justify introducing `go_router`.
- [ ] Decide whether additional top-surface presets are needed beyond `softBrand` when more real brands are introduced.
- [ ] Add a dedicated large-font/small-screen visual pass for pinned home headers and first-level pages without top strips.
