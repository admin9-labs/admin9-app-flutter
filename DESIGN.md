# Design

## Source of truth

- Status: Active draft
- Last refreshed: 2026-06-09
- Primary product surfaces: Flutter mobile prototype in this repository; Go backend and Vue Admin live in `admin9-app-admin`.
- Evidence reviewed:
  - User-provided Sichuan Observer reference screenshots for profile, settings, login, messages, about, feedback, report, history, and community/activity layouts.
  - `lib/app/admin9_app.dart`, `lib/app/admin9_shell.dart`
  - `lib/core/theme/app_theme.dart`, `lib/core/theme/app_spacing.dart`
  - `lib/core/widgets/top_level_page_scaffold.dart`, `lib/core/widgets/app_search_entry.dart`
  - `lib/ui/features/mine/views/*`
  - User-provided 2026-06-08 and 2026-06-09 iPhone screen recordings covering top-level page scroll behavior in light and dark modes.
  - `README.md`

## Brand

- Personality: local media, practical, bright, trustworthy, service-oriented.
- Trust signals: clear account status, agreement links, report/contact surfaces, about/version information, predictable settings.
- Avoid: one-off page styling, hard-coded colors in feature pages, decorative visual noise that weakens readability, and business surfaces that imply real public APIs before a product decision.

## Product goals

- Goals:
  - Turn the Flutter app into a reusable mobile foundation prototype with stable design tokens and user-foundation pages.
  - Support brand-color swapping, dark mode, app font-size levels, and one-tap global grayscale for memorial or public-event needs.
  - Keep static repositories replaceable by future API repositories without rewriting UI structure.
- Non-goals:
  - Do not add real public-client APIs, CMS contracts, SMS login, third-party OAuth, payment, mall, order, or activity business flows in this iteration.
  - Do not make the Flutter prototype part of backend/Admin formal acceptance until API, deployment, and acceptance contracts are explicitly added.
  - Treat third-party login, SMS, and push Admin configs as reserved placeholders only; they have no runtime App/API effect in this iteration.
- Success signals:
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

- Primary navigation: five-tab bottom navigation remains `首页`, `直播`, `爆料`, `服务`, `我的`.
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
  - Additional presets should include government red and service green to prove brand flexibility.
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
  - Theme/brand swatch selector.
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
- Selection/readability: selected tabs, bottom navigation, chips, quick actions, and service grids must remain distinguishable by luminance, font weight, shape, or structure when global grayscale is active. Brand color alone is not an acceptable state signal.
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
  - Build themes from brand presets and `ColorScheme`.
  - No feature page should hard-code a brand color when a token exists.
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

## Iteration gates

- Gate 0: Design source and Flutter prototype boundary are documented.
- Gate 1: Theme tokens and appearance state exist and are persisted.
- Gate 2: Foundation pages consume shared components and route through a consistent navigation helper.
- Gate 3: Widget tests cover core user-foundation behavior.
- Gate 4: `$code-review` runs clean or all blocking findings are fixed.

## Iteration model

- Treat the Flutter mobile app as an iterative foundation, not a one-shot page fill.
- Each gate should be independently verifiable and committed separately when possible.
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
