# Admin9 地方融媒体 Flutter App

本项目是一个带有可复用基础设施的地方融媒体 App。“西昌发布”是默认实例；基础设施服务于产品持续交付和客户复用，不把项目扩展成通用 App 平台、插件市场或运行时多租户系统。

这里的“支持不同客户”是指使用同一代码基座，分别构建和发行多个独立的地方融媒体 App，而不是登录后切换客户身份的 SaaS 客户端。每个生产安装包在构建/发行时确定唯一的 `AppProfile`；登录仅建立当前 App 内的用户会话。

当前仓库仍处于静态数据驱动的产品化原型阶段。“西昌发布”是用于持续验证默认行为的默认 `AppProfile`；首页、频道和稿件属于地方融媒体行业核心能力，直播、爆料、服务、积分等是候选业务能力，是否需要由客户需求决定，交付载体不在本文预设为原生。每项已选能力应在产品方案中确定唯一的原生、H5、混合或受控外部实现；运行配置只能启停或调整该既定实现，不能切换技术载体。仓库不属于 `admin9-app-admin` 后端 + Admin 后台的正式交付基线，也不依赖 `/api/admin/*` 或已移除的 public-client API；接入真实新闻、CMS、会员或远程配置前，必须先补齐 API 契约、验收和部署文档。

## 文档导航

- [`DESIGN.md`](DESIGN.md)：产品、设计与架构边界的 Source of truth。
- [`docs/architecture/modular-media-app-plan.md`](docs/architecture/modular-media-app-plan.md)：模块化地方融媒体 App 基座的增量迁移计划。
- [`docs/audit/VALIDATION.md`](docs/audit/VALIDATION.md)：历史审计裁决及验证记录。
- [`docs/delivery/app-third-party-services-plan.md`](docs/delivery/app-third-party-services-plan.md)：工作区级第三方服务计划入口。

## 当前能力

- 底部导航：`首页`、`直播`、`爆料`、`服务`、`我的`
- 首页频道内容：搜索框、频道栏、按频道输出的页面装修区块、频道级背景色样式、真实图片、焦点轮播、图标导航、瓷片入口、媒体展示位、纯文字/图文/大图/多图信息流、视频角标
- 政声频道：以专题内容组和 `mediaFeature` 重点内容样式为示例，支持分类入口、关联内容、查看更多；分类、头像、内容列表为空或不可渲染时自动隐藏对应区域
- 首页频道自定义：添加、删除、长按排序、恢复默认、本地持久化
- 文章详情：点击频道内容进入详情页
- 直播：直播首页、预告、回放、直播详情
- 爆料：线索列表、我要爆料表单
- 服务：常用服务宫格、服务详情
- 我的：中文登录、注册、退出、设置页
- 开屏内容：启动时展示 5 秒，可跳过；当前使用真实图片并保留渐变兜底，模型已预留 GIF、视频扩展位

## 项目结构

```text
lib/
├── main.dart
├── app/
│   ├── admin9_app.dart
│   └── admin9_shell.dart
├── core/
│   ├── theme/
│   └── widgets/
├── domain/
│   └── models/
├── data/
│   ├── repositories/
│   └── services/
└── ui/
    └── features/
        ├── home/
        ├── live/
        ├── report/
        ├── services/
        ├── splash/
        └── mine/
```

## 架构说明

- `main.dart` 只负责初始化 Flutter 和启动 App。
- `lib/app/` 放应用根组件、依赖装配和底部导航壳层。
- `core/theme/` 放 Material 3 主题、颜色和文字风格。
- `core/widgets/` 放跨页面复用的卡片、空状态、视觉占位、状态标签。
- `domain/models/` 放业务模型。
- `data/repositories/` 放静态数据和数据访问入口。
- `data/services/` 放外部能力封装，目前是 `SharedPreferences` 本地存储。
- `ui/features/` 按业务模块放页面和 ViewModel。

当前使用 `provider` 管理 `ChangeNotifier` 状态。首页频道使用 `shared_preferences` 保存用户自定义结果。

## 一级页 Chrome 原型约定

5 个一级页统一使用 `TopLevelPageScaffold` 作为顶部 chrome 入口，结构为：

```text
系统 safe area
Page Toolbar（固定 56px）
内容区（可滚动，必要时包含 pinned sliver）
```

- `TopLevelPageScaffold.title` 保留语义、默认标题和调试 key；scroll-edge 页面未传 `toolbar` 时，Page Toolbar 默认渲染标题和 actions。
- `toolbar` 可传入任意页面级控件。首页将 `home-search-entry` 放入 Toolbar，搜索框高度固定 44px，并使用胶囊圆角。
- Page Toolbar 不绘制磨砂、半透明遮罩或分隔线；它只承载标题、actions 或自定义控件，顶部背景图在初始和上滑后都应保持可见。
- 首页频道 Tabs 不属于页面 chrome，作为内容区 pinned sliver 固定在 Toolbar 下方，继续保留 `home-pinned-channel-bar` 和 `channel-manage-button`。
- 首页仍按 `MediaChannelStyle.backgroundColor` 切换频道底色；普通频道顶部图使用 `AppAssets.topLevelJacarandaHeader` 且 `Alignment.topCenter` 对齐；暗色模式不渲染浅色顶部图。

该约定仅用于当前 Flutter 静态原型验证，不改变 Admin9 正式前台端使用 uni-app 的技术选型决策。

本轮质量提升仍保持静态原型边界：

- 频道区块会先过滤禁用、隐藏、时间窗未命中和无有效数据的 Block；如果过滤后没有可展示内容，会显示明确空状态，而不是留下空白页。
- 直播页不再假设一定存在“正在直播”数据；没有直播、预告或回放时会显示空状态，避免静态 fixture 调整后页面崩溃。
- 服务页宫格按可用宽度自适应列数，并保留足够卡片高度，避免宽屏预览时内容被挤压或溢出。

首页频道内容已经调整为“按频道输出页面装修区块，再由通用组件渲染”：

- `domain/models/home_block.dart` 定义静态原型视图模型 `PageBlock`、内容项、内容语义、条目布局、原型级启停时间窗和视觉外壳。
- `domain/models/media_channel.dart` 定义频道入口与频道级样式；当前只把背景色作为频道装修示例，不代表完整皮肤系统。
- `data/repositories/home_content_repository.dart` 是当前静态原型 fixture 源，通过 `blocksForChannel(channelId)` 输出页面区块；它不是后台/API 契约。
- `ui/features/home/views/channel_content_tab.dart` 承接单个频道 Tab 的滚动列表，并通过 `ChannelContentTab` 过滤、排序，再交给 `PageBlockRenderer` 分发区块。
- `ui/features/home/views/channel_content_blocks.dart` 按区块和内容项布局拆分 Widget。后续接真实接口时，应新增接口 DTO 到原型视图模型的适配层，不应把当前 `PageBlock` 直接当成后台/API 契约，也不要把某个业务频道写进组件名。
- “推荐”仍可作为真实频道名称和 channel id 存在，但通用渲染组件不再使用推荐频道语义命名。

频道装修模型的命名口径：

- `PageBlockType.noticeBar`、`imageCarousel`、`iconNavigation`、`tileGrid`、`mediaShowcase`、`specialEntry`、`specialContentGroup`、`contentFeed` 只对齐当前静态原型的 Block 展示需要。
- `MediaChannelStyle` 承载频道页级样式，当前仅支持 `backgroundColor`，用于表达某个频道进入后整块频道页的底色；默认可见的“专题”频道是当前示例。
- `ContentKind` 只表示内容语义，例如文章、专题、图集、视频、直播、回放；它不决定展示样式。
- `ContentItemLayout` 决定内容项的排列方式，例如 `text`、`sideImage`、`largeImage`、`imageGrid`、`mediaFeature`。
- `SurfaceStyle` 决定区块或内容项的视觉外壳，例如 `plain`、`card`、`separated`、`fullBleed`。
- `mediaFeature` 是一种媒体/重点内容展示样式，不是人物专用组件；当前政声频道只是使用这个样式的一个业务示例。

图片展示使用“真实图片优先、渐变占位兜底”的方式：

- `ArticleVisualAsset.imageUrl` 有值时，`ArticleVisual` 优先渲染网络图片。
- 图片为空或加载失败时，自动回退到原有渐变占位。
- 当前 demo 使用 Unsplash 静态图片 URL，不接 Unsplash API，也不需要 API Key；正式项目应替换为 CMS 或稿件接口返回的封面图。

轮播和频道内容区块按未来配置方向预留：

- `PageBlockType.imageCarousel` 支持轮播数据，模型预留 `indicatorStyle`、`indicatorPosition`、`titlePlacement`。
- 当前轮播先实现大图、底部标题叠加、右下角数字指示器 `1/3`。
- `PageBlockType.specialEntry` 只展示专题入口，`PageBlockType.specialContentGroup` 只展示专题内容组，两者不混用。
- `PageBlockType.contentFeed` 配合 `ContentItemLayout.mediaFeature` 可以表达媒体重点内容项；内容语义仍由 `ContentKind` 决定。
- `channelId`、`moreTarget`、`startAt/endAt` 是原型级装修元数据，用来验证频道归属、更多入口占位和启停时间窗；它们不是正式接口字段。
- 区块 `enabled/visible` 为 false、启停时间窗不命中、依赖的数据为空或排序后不可渲染时，`ChannelContentTab` 会隐藏该区块。

开屏内容按业务能力拆成独立模块：

- `domain/models/splash_content.dart` 定义开屏内容模型和媒体类型：`image`、`gif`、`video`。
- `data/repositories/splash_repository.dart` 提供当前有效开屏内容，后续可以替换为接口返回。
- `ui/features/splash/` 负责开屏内容的倒计时、跳过和展示。

当前先实现图片型开屏内容，`mediaUrl` 有值时优先展示真实图片，图片为空或加载失败时显示渐变兜底。后续扩展 GIF 时可以继续走图片类展示；扩展视频时建议增加视频播放器依赖，并把播放、静音、首帧、加载失败等状态放进 `splash` 模块，不影响底部导航和首页结构。

## 动态 Block 原型边界

当前动态 Block 对齐只覆盖 Flutter 静态原型里的布局行为：多个公告条 Block、单行公告轮播、区块排序/启停/时间窗过滤、频道归属和更多入口占位。`PageBlock` 仍是视图模型，不是后台配置器、CMS DTO 或移动端正式 API。

暂不在本原型内承诺：正式 API、后台配置器、视频播放 SDK、埋点、弱网策略、广告/魔方/热区、富文本、Spacer/Divider，以及任何 `/api/app` 路径。后续接真实接口时，应先补契约、验收和部署文档，再通过 DTO adapter 映射到当前视图模型。

## 清理边界、计划与兜底说明

本次 AI slop 清理只覆盖 Flutter 原型，保留现有静态数据、Provider 状态、本地存储和页面交互行为；不触碰 Admin 后端、Admin 前端或新的 App API 契约。

已执行的清理计划：

1. 先用 `flutter analyze` 和 `flutter test` 锁定现有行为。
2. 盘点 fallback-like 代码，先区分原型级 UI 兜底、本地偏好兼容和 masking fallback。
3. 只删除低风险噪音：Flutter 模板注释和 carousel 里的无效 padding 包装。
4. 复跑 `dart format --set-exit-if-changed lib test`、`flutter analyze`、`flutter test` 后再交付。

清理前已用 `flutter analyze` 和 `flutter test` 锁定行为。代码中的图片加载失败占位、开屏渐变背景、频道本地配置恢复默认、非法外观偏好回到默认值，均属于原型 UI 或本地偏好的明确兜底；它们不是吞错、绕过校验或隐藏契约失败的 masking fallback。后续如接入真实接口，应先新增接口契约和 DTO adapter 测试，再决定是否保留这些原型兜底。

## 运行

```bash
cd ./
flutter pub get
flutter run -d macos
```

Android debug 打包：

Android 打包前先确认 `flutter doctor -v` 的 Android toolchain 为通过状态，并使用 JDK 17。`android/local.properties` 会由 Flutter 按本机 Flutter SDK / Android SDK 路径生成，已被 `.gitignore` 忽略。

```bash
flutter build apk --debug
```

Android release 打包：

```bash
flutter build apk --release
```

当前 release APK 仍使用 debug key 签名，仅用于原型和本地验证；正式分发前需要改为真实 keystore 签名配置。

生成产物在：

```text
build/app/outputs/flutter-apk/app-debug.apk
build/app/outputs/flutter-apk/app-release.apk
```

iPhone 真机 release 运行：

```bash
flutter run --release -d 00008150-000268290C44401C
```

## 验证

```bash
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
```

清理类改动至少执行：

```bash
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```

## 后续可扩展方向

- 把静态仓库替换为真实新闻接口
- 增加图片资源或接入真实封面图
- 增加评论、收藏、搜索、消息通知
- 真实深链或推送入口需求出现后，经 ADR 演进现有导航边界
- 根据地方融媒体业务补运营位、专题、问政、活动报名等模块
