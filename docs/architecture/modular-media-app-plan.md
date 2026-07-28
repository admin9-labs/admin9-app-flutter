# 模块化地方融媒体 Flutter App 基座增量计划

## 文档状态

- 状态：Stage 0 文档基线已修订；Stage 1 需满足本文入口闸门后开始
- 日期：2026-07-29
- 适用仓库：`admin9-app-flutter`
- 产品与架构边界的 Source of truth：[`../../DESIGN.md`](../../DESIGN.md)
- 本文职责：描述从当前“西昌发布”静态原型演进为可配置地方融媒体 App 基座的增量实施路径，不改变当前代码行为。

## 目标

本项目是一个带有可复用基础设施的地方融媒体 App。“西昌发布”是默认实例；基础设施服务于产品持续交付和客户复用，不把项目扩展成通用 App 平台、插件市场或运行时多租户系统。

这不是把现有产品清空成通用 Flutter demo，也不是把所有业务改成 H5。目标是在保持默认西昌实例可运行、可回归的前提下，逐步建立明确的 App 身份、业务能力、交付载体、模块、状态、存储和轻应用边界。

## 交付模型澄清

本项目复用的是代码基座，而不是在运行期承载多个 SaaS 租户。同一代码基座可以为不同客户选择不同 `AppProfile` 并分别构建、签名和发行；每个生产安装包只绑定一个 `AppProfile`，运行期保持不变。

- 规范化的 `profileId` 是构建流程选择 App 身份的唯一输入；构建流程先将该 profile 与获批产品装配决策解析为面向目标平台的 `ResolvedBuildSpec`，再生成并验证产物。任何 flavor、入口、环境变量或生成文件都只能承载同一个规范化选择，不能形成互相覆盖的第二来源。
- `UserSession` 只表示当前登录用户及其授权，不参与 App 身份选择。
- 每次构建只能通过一个规范化输入选择一个 `profileId`。Flutter flavor、不同入口或 `--dart-define` 只是候选实现手段，Stage 0 不在它们之间作技术选型，也不允许多个来源互相覆盖。
- 不同 App 使用各自的 bundle/application ID 和平台沙箱自然隔离；单个 App 内的数据只需继续按账号、模块和数据 schema 隔离。

每项候选业务能力按四步落地：

1. **业务必要性**：该客户是否需要这项能力。
2. **唯一实现选型**：实施前确定采用 Flutter 原生、H5 轻应用、原生 + H5 混合还是受控外部系统；混合本身是一种确定实现，不表示长期维护两套可切换实现。
3. **构建包含**：只把已经取得唯一载体批准的能力纳入该客户的 `ProductAssemblyDecision`，再决定构建是否实际打包对应原生代码、SDK、平台权限和 Bridge 能力。
4. **运行启用**：`RemoteAppConfig` 是否在构建和 `AppProfile` 允许范围内启用该既定实现，或为已经确定采用 H5/混合的能力下发受控清单。

第 4 步不能改变第 2 步。当前 `live/report/services/points` 代码只是为保持西昌原型可回归而存在的**遗留原型兼容实现**，不构成产品或客户对包含关系、载体或正式交付的批准。凡作为产品能力进入某次 `ProductAssemblyDecision`、`ResolvedBuildSpec.approvedAssemblyCapabilities` 或待验收产物的运行时装配，都必须在 `resolveBuild` 前取得该版本唯一载体批准；未批准能力不得因为当前代码存在、默认西昌或历史五 Tab 而自动注册或启用。物理裁剪 ADR 触发前，遗留代码、插件或权限仍可能存在于二进制中，canonical manifest 必须如实记录这种打包事实，但物理存在不产生产品批准。后续若确需更换已批准载体，必须通过新的产品决策、代码迁移、测试、重新构建和发布完成，不能由远程配置切换。

可选业务能力不天然等同于 `AppModule`；`AppModule` 只代表安装包内的 Flutter 原生实现，已经确定采用 H5 或混合的能力由受控 MiniApp 清单与对应宿主代码承载。

## 产品装配决策与构建能力事实

在 Stage 1 代码开工前，先固定一条最小、可追溯的产品到产物链。它不是新的运行时平台，也不要求现在选择 flavor、多 package、独立 app target 或生成工程拓扑。

### ProductAssemblyDecision

`ProductAssemblyDecision` 是产品与交付共同批准的版本化决策记录，至少包含：

- `decisionId/revision`、适用 `profileId`、目标平台和批准人/日期。
- 行业核心与候选业务能力的包含关系；每项已选能力唯一获批的原生、H5、混合或受控外部载体。
- 顶层入口、Search/My Activity 等聚合入口在能力启用和禁用时的产品行为。
- 需要的插件、SDK、平台权限、原生网络例外和业务 Bridge capability；未批准项不得由构建或远程配置补开。
- 尚未决定的项目必须引用本文 Unknown 决策 ID，不得以默认原生、默认西昌或“以后再说”绕过。

这份记录决定“产品要装什么”，不声明产物已经物理包含或排除什么。

对本次构建选择运行装配的每个能力，记录必须在 `resolveBuild` 前给出唯一获批载体；仍引用 `D-01` 的能力只能保持在 `approvedAssemblyCapabilities` 和运行装配之外。canonical manifest 仍须记录产物内实际存在的代码、插件、SDK、权限及其 capability 映射，并明确它未被产品选择；不能靠从 manifest 隐去事实伪造物理裁剪。排除当前西昌可见遗留入口若会改变回归行为，仍需另有明确产品决定，构建工具不得自行用“保持默认行为”代替载体批准。

### ResolvedBuildSpec

构建入口必须把多个底层载体归一化成单一逻辑接口：

```text
resolveBuild(profileId, targetPlatform, buildMode, sourceRevision)
  -> ResolvedBuildSpec
build(resolvedBuildSpec)
  -> artifact + canonicalPackagedCapabilityManifest
verifyArtifact(artifact, resolvedBuildSpec, canonicalPackagedCapabilityManifest)
  -> ArtifactAttestation
```

`ResolvedBuildSpec` 是一次构建的不可变输入快照，至少记录：

- 唯一 `profileId`、profile schema/digest、`ProductAssemblyDecision` revision/digest、源码 revision、目标平台和构建模式。
- 该目标平台的 application/bundle ID、显示名、图标/启动资源、版本与 build number、URL scheme/associated domain、签名策略引用，以及 manifest/Info/entitlements、网络安全和隐私声明输入；凭据本身不得进入 profile 或日志。
- `approvedAssemblyCapabilities` 及其唯一载体，以及预期物理存在的原生模块、插件/SDK、平台权限、`trustedMiniAppOrigins`、`cleartextMediaHosts`、容器内部通道和业务 Bridge capability；批准集合与物理打包预期分字段记录，不能互相推导或冒充。
- 输出产物类型、验证器版本和需要回读的证明项。

显式指定的客户 profile 不存在、schema 无效、平台身份不完整、目标平台不兼容或装配集合越界时，`resolveBuild` 必须 fail closed；**不得回退到西昌默认 profile**。西昌默认值只在调用方明确请求默认西昌构建时生效。正式构建若缺少 `profileId` 同样失败，开发/测试便利默认也必须通过独立、显式的入口声明。

### PackagedCapabilityManifest 与 ArtifactAttestation

`packagedCapabilities` 不是 `AppProfile` 可填写的字段，而是构建系统所有的事实。构建流程从 `ResolvedBuildSpec` 和实际构建输入生成唯一 canonical `PackagedCapabilityManifest`，将它嵌入产物或以平台可验证方式与产物不可分割绑定，再由 verifier 同时核对 artifact、spec 与该 manifest 并生成 `ArtifactAttestation`。具体使用资源文件、生成代码、原生 section 或其他编码形式由 Stage 1 选择，不改变以下边界：

- Manifest 为每个稳定 capability ID 映射 Dart 入口、Flutter 插件、原生 SDK/framework、平台权限/entitlements、隐私资源、网络例外、容器内部 JavaScript channel 和业务 Bridge capability。
- 对每个采用原生或混合原生部分的稳定 `capabilityId`，Manifest 还必须给出唯一 owning `moduleId` 和导出的 `sectionId` 集合；H5/外部载体改为映射 owning `miniAppId/externalTargetId`，不得伪造 module。`AppModule` 静态描述声明同一映射，Registry 在工厂调用前校验一致。一个 module 只有在多个 capability 被产品明确批准为不可分的最小启用单元时才可共同拥有它们；否则拆成独立 module 描述，禁止启用一个 capability 时初始化另一个已禁用 capability 的状态或副作用。
- Attestation 回读最终 application/bundle ID、名称、版本、签名身份/策略结果、依赖/插件/SDK、merged manifest 或 Info/entitlements、隐私资源、网络例外、Bridge 清单和关键品牌资源摘要，并绑定 artifact digest、`ResolvedBuildSpec` digest、canonical manifest digest、源码 revision/digest、profile digest、产品决策 digest 和 verifier version。
- `verifyArtifact` 必须比较预期、canonical manifest 与实物；manifest 缺失、不能证明与产物绑定、digest 错配、缺项、越界项或身份错配均 fail closed。运行时只能读取产物内或与产物不可分割绑定的这一份已验证 manifest，不接受 profile、远程配置、手写 fixture 或另一份 sidecar 覆盖。只有 attestation 证明后，才能声称能力、SDK 或权限已从某产物物理排除。
- 在物理裁剪 ADR 尚未触发或产物验证器尚未覆盖某项时，只能声明“产品装配未选择/运行时未启用”，不得声明“客户安装包不包含”。

Stage 0 固定上述逻辑输入、输出、稳定 ID 和验证接口。Stage 1 必须选择一个可回滚、最小的身份绑定与产物验证实现，使西昌和非西昌测试 profile 能实际生成并回读目标平台产物；该实现不构成长期构建拓扑承诺。只有 flavor、多 package、独立 app target 等用于物理依赖分区的拓扑选择，继续由首个真实物理排除需求 `D-08` 触发的 ADR 决定。

## 当前事实与问题

当前仓库已经具备主题、外观偏好、页面壳、Provider 装配、本地存储、首页频道、稿件、直播、爆料、服务、积分、登录和设置等能力。Stage 0 固定以下事实口径，后续数量变化必须使用同一计数定义重新生成清单，不能把口径变化误报为架构进展：

- 当前只有一个 `pubspec.yaml`，没有客户 flavor 或独立 app target；直接依赖包含 `provider`、`shared_preferences`、`path_provider`、`webview_flutter` 和 `video_player`。源清单不能代表最终 merged manifest、插件、SDK、隐私资源或 entitlements，现阶段不能证明物理裁剪。
- 应用根部一次性注册全部 Repository、Provider 和 ViewModel；底部导航固定构造 `首页 / 直播 / 爆料 / 服务 / 我的` 五页。五页各接收单调递增的重复点击/状态栏点击回顶请求；只有直播页额外接收由当前选中 Tab 计算的 `isPlaybackActive`。导航自身维护 selected index，没有向所有页面另传一套通用“活动态”对象。
- `AppStateController` 构造时即读取 push 开关、最近服务和积分状态；同时持有稿件阅读/收藏/点赞、来源关注、评论、直播预约、爆料、服务收藏/申请/最近使用、反馈、搜索、消息已读和积分状态。阅读、收藏、评论、直播预约、爆料、服务申请共六类跨能力行为会把积分任务标记为待领取；签到是 points 内部的第七类行为，不属于跨能力事件端口。
- 跨 feature 实现 import 在本快照中恰好为 **32 条**。计数定义为：导入方位于 `lib/ui/features/<A>/`，目标解析后位于 `lib/ui/features/<B>/`，且 `A != B`；相对 import 与 package import 归一化后按 import 指令逐条计数，不按目标文件去重。完整清单是 Stage 0 基线附件，阶段 3 完成前沿用此定义归零。
- `LocalStorageService` 声明 **18 个静态基础 key**，其中 **7 个积分 key** 会再拼接 `guest/手机号` 动态作用域；18 不包含动态后缀、文件缓存或 WebView 自有存储。
- 当前有两个实际创建 `WebViewController` 的实现：`ChannelH5Tab` 内嵌频道页面，以及通用 `InAppWebPage`。活跃调用路径包括频道页本身、频道子链接从 `ChannelH5Tab` 打开 `InAppWebPage`、首页内容块/专题入口打开 `InAppWebPage`；`services` 中的 H5 target 目前只是占位展示，不计为已加载 WebView。Stage 4A 必须覆盖上述全部实现和调用路径，不能只迁移频道 Tab。
- 当前 shared/core API 已泄露可选插件类型：`InAppWebPage.webViewBuilder` 暴露 `WebViewController`，`LiveStreamPlayer` 的公开回调暴露 `VideoPlayerValue`。这属于语义边界基线，不因为路径位于 `core/` 就视为共享抽象；对应能力迁移时必须收敛到 owning adapter 或不含插件类型的窄宿主契约。
- `lib/core/navigation/app_navigator.dart` 只是 `Navigator.push` 与 `MaterialPageRoute` 的薄封装；当前没有 `go_router`、命名路由、正式深链映射或多来源入口解析需求。
- 平台身份仍分别硬编码：Android 的 namespace/application ID/label，iOS 的 bundle ID/display name，macOS 的 product name/bundle ID，以及 Web 的 title/manifest 名称和图标；Dart `MaterialApp.title`、品牌资源、许可证与协议文本也尚未收敛。
- 当前直播源使用 `http://xcfb.screx.com.cn:18085/...m3u8`，Android network security 与 iOS ATS 对 `xcfb.screx.com.cn` 保留明文例外；服务 fixture 还有一个 `http://app.lsiptv.cn` 占位目标。Splash 图片为带非标准端口的 HTTPS 资源。MiniApp 可信来源、原生媒体明文例外和远程下载策略必须分别建模，不能共用一个“可信域”集合。
- 当前静态 Repository 和视图模型是原型边界，不能直接当作未来 CMS、会员、Bridge token 或远程配置 API 契约。

### Stage 0 可复核事实附件

以下清单绑定 Stage 0 修订输入快照：分支 `main`，HEAD `658d3816bd3baa09da8e943107357e62bbe03bc4`；输入工作区已有 `DESIGN.md`、`README.md` 和本文三份 tracked 修改；输入工作区文档 SHA-256 分别为 `DESIGN.md = 593308f2830c7eb62b1e30a6880846656c2cdaae318a9a5e0402d9c16dd47a52`、本文 `= 92100b7bde0c6eb8cadf828c919c0be477c94c26ba0fca6860a876a8e0c86fc9`。本轮只修改两份核心文档并保留既有 `README.md` 修改；代码/平台事实以该 HEAD 和未改代码工作区为准。代码变化后必须用上面的定义重算并在阶段记录中保存差量。

**32 条跨 feature import。** 表内路径均省略共同前缀 `lib/ui/features/`：

| # | 导入方 | 目标实现 |
|---:|---|---|
| 1 | `foundation/views/account_security_page.dart:10` | `mine/views/auth_page.dart` |
| 2 | `foundation/views/account_security_page.dart:11` | `mine/view_models/session_view_model.dart` |
| 3 | `home/views/article_detail_page.dart:13` | `foundation/views/content_report_page.dart` |
| 4 | `home/views/article_detail_page.dart:14` | `mine/view_models/session_view_model.dart` |
| 5 | `home/views/channel_content_blocks.dart:19` | `live/views/live_detail_page.dart` |
| 6 | `home/views/channel_content_blocks.dart:20` | `report/views/report_form_page.dart` |
| 7 | `home/views/channel_content_blocks.dart:21` | `services/views/services_page.dart` |
| 8 | `home/views/channel_content_tab.dart:7` | `services/views/services_page.dart` |
| 9 | `home/views/home_page.dart:18` | `search/views/search_page.dart` |
| 10 | `live/views/live_detail_page.dart:10` | `mine/view_models/session_view_model.dart` |
| 11 | `live/views/live_page.dart:16` | `mine/view_models/session_view_model.dart` |
| 12 | `live/views/live_page.dart:17` | `mine/views/auth_page.dart` |
| 13 | `mine/views/activity_list_page.dart:12` | `home/views/channel_content_blocks.dart` |
| 14 | `mine/views/activity_list_page.dart:13` | `live/views/live_detail_page.dart` |
| 15 | `mine/views/activity_list_page.dart:14` | `report/views/report_detail_page.dart` |
| 16 | `mine/views/auth_page.dart:10` | `foundation/views/agreement_page.dart` |
| 17 | `mine/views/mine_page.dart:13` | `foundation/views/about_page.dart` |
| 18 | `mine/views/mine_page.dart:14` | `foundation/views/account_security_page.dart` |
| 19 | `mine/views/mine_page.dart:15` | `foundation/views/message_center_page.dart` |
| 20 | `mine/views/mine_page.dart:16` | `points/views/points_pages.dart` |
| 21 | `mine/views/settings_page.dart:11` | `foundation/views/about_page.dart` |
| 22 | `mine/views/settings_page.dart:12` | `foundation/views/account_security_page.dart` |
| 23 | `mine/views/settings_page.dart:13` | `foundation/views/appearance_page.dart` |
| 24 | `mine/views/settings_page.dart:14` | `foundation/views/feedback_page.dart` |
| 25 | `mine/views/settings_page.dart:15` | `foundation/views/font_size_page.dart` |
| 26 | `mine/views/settings_page.dart:16` | `foundation/views/harmful_report_page.dart` |
| 27 | `points/views/points_pages.dart:18` | `mine/view_models/session_view_model.dart` |
| 28 | `points/views/points_pages.dart:19` | `mine/views/auth_page.dart` |
| 29 | `search/views/search_page.dart:18` | `live/views/live_detail_page.dart` |
| 30 | `search/views/search_page.dart:19` | `services/views/services_page.dart` |
| 31 | `search/views/search_page.dart:20` | `home/views/channel_content_blocks.dart` |
| 32 | `splash/views/launch_gate.dart:7` | `foundation/views/agreement_page.dart` |

**18 个 `LocalStorageService` 静态基础 key。** 动态 points 后缀不另计：

| 所有权/用途 | 基础 key | 数量 |
|---|---|---:|
| home | `home_channel_ids`, `home_channel_defaults_version` | 2 |
| appearance | `appearance_brand`, `appearance_theme_mode`, `appearance_font_level`, `appearance_grayscale` | 4 |
| settings/services | `settings_push_enabled`, `recent_service_ids` | 2 |
| points | `points_balance`, `points_last_check_in_date`, `points_claimed_task_ids`, `points_pending_task_ids`, `points_used_order_ids`, `points_orders`, `points_transactions` | 7 |
| launch/privacy | `privacy_guide_accepted`, `onboarding_completed`, `splash_cache_metadata` | 3 |
| **合计** | 不包含 `:guest/:手机号` 动态 scope、文件缓存与 WebView 存储 | **18** |

**活跃 WebView 面：**

| 控制器实现 | 活跃入口/调用路径 | Stage 4A 处置 |
|---|---|---|
| `home/views/channel_h5_tab.dart` 的 `ChannelH5Tab` | `HomePage` 选中 H5 频道后内嵌加载；内部注入 `Admin9H5LinkBridge` | 迁入统一容器策略；内部 channel 单独登记，不能算业务 Bridge |
| `core/widgets/in_app_web_page.dart` 的 `InAppWebPage` | `ChannelH5Tab` 的频道子链接 | 迁入同一容器、改受控外跳或移除 |
| 同一个 `InAppWebPage` | `channel_content_blocks.dart` 的首页内容块/专题入口 | 迁入同一容器、改受控外跳或移除 |
| 非活跃占位 | `services_page.dart` 展示 service H5 target，但当前不创建 WebView | 保持为 fixture 事实；不得计入已加固入口或直接放行 HTTP 占位 URL |

**平台身份与网络例外：**

| 面 | 当前事实 | 迁移要求 |
|---|---|---|
| Android | namespace/application ID 为 `com.admin9.app.flutter`，label 为 `西昌发布`；network security 对 `xcfb.screx.com.cn` 允许明文；当前 `release` 仍使用 debug signing config | 进入 `ResolvedBuildSpec` 并从最终 merged manifest/签名结果回读；媒体例外不传递给 WebView。当前签名只允许开发验证，不能作为正式发行证明 |
| iOS | bundle ID 为 `com.admin9.app.flutter`，display name 为 `西昌发布`；ATS 对 `xcfb.screx.com.cn` 允许明文；Runner 当前为 Automatic signing 并硬编码 development team | 进入平台身份/安全引用并从 archive 的 Info/entitlements/签名回读；正式签名责任由 `D-03` 对应发行决策关闭 |
| macOS | product name 为 `西昌发布`，bundle ID 为 `com.admin9.app.flutter`；工程含 Automatic/Manual signing 配置和独立 Release entitlements | 是否只预览或正式发行由 `D-03` 决定，不能假设与 iOS 共用身份、签名或发行结论 |
| Web | `index.html` title 与 manifest `name/short_name` 为 `西昌发布`，当前 manifest 没有显式 PWA `id/scope` | 是否只预览或正式发行由 `D-03` 决定；若批准正式发行，Stage 1 先固定 canonical origin、PWA `id/scope/start_url` 和图标/manifest 身份。移动 WebView 验收不能由 Web preview 替代 |
| Dart/资源/法务 | `MaterialApp.title`、品牌资源、协议/许可证文本仍有西昌静态来源 | 收敛到唯一 profile/受控资源；品牌身份与用户可选 palette 分开 |
| 明文 live | `http://xcfb.screx.com.cn:18085/...m3u8`，并依赖 Android/iOS host 级例外 | 登记为 `cleartextMediaHosts` 债务；正式发行前关闭 `D-07` |
| 明文 service fixture | `http://app.lsiptv.cn/5g/index.html`，当前未真正打开 | 不得进入 `trustedMiniAppOrigins`，不因占位生成平台例外 |
| Splash | `https://xcfb.screx.com.cn:18081/...jpg` | 属远程下载策略；逐跳校验，不能继承媒体明文例外 |

## 目标架构

### 1. 稳定宿主

稳定宿主负责与具体业务模块无关、但所有模块共同依赖的应用能力：

- Flutter 启动、异常边界和应用生命周期。
- `AppProfile`、bundled/local 配置源、未来 `RemoteAppConfig` 和 `UserPreferences` 的解析与合并边界。
- 仅面向原生实现的 `AppModule` 契约、`ModuleRegistry` 和模块装配顺序。
- 基于最小 `AppShellSection` 描述的顶层 Flutter 页面装配、入口排序和现有宿主信号传递。
- 主题、字号、深浅色、全局灰度、通用页面壳和基础可访问性。
- 顶层导航装配和入口策略。
- 网络、日志、可观测性、权限、本地存储等共享服务接口。
- 通用 `MiniAppContainer` 和可信域校验；业务 Bridge 只在条件成立时加入。

宿主组合根可以依赖模块公开入口和最小 section builder，但不导入模块内部 ViewModel、Repository 或其他实现文件。section builder 只接收当前已有真实消费者需要的宿主上下文，例如 `isActive` 和单调递增的 reselect/scroll-to-top 请求；不得扩展成万能生命周期或路由对象。跨 feature 协作由宿主注入少量类型明确的 open action、只读 read-model 端口或公开契约，不建立万能导航服务。

### 2. 地方融媒体行业核心

以下能力定义产品类别，应作为行业核心持续演进：

- 首页信息入口及其稳定页面壳。
- 频道列表、频道管理与频道内容编排。
- 稿件列表、详情、媒体展示和必要的内容状态。
- 与首页、频道、稿件紧密相关的搜索入口和内容跳转契约。

行业核心仍需遵守边界。首页不能直接导入直播、爆料或服务的实现页面；需要跨 feature 打开页面时，由宿主注入 `onOpenReportForm`、`onOpenLiveDetail`、`onRequireLogin` 等少量类型明确的动作，或依赖对方公开契约。

### 3. 候选业务能力

当前候选能力包括，且每个客户均可不选：

- `live`：电视、广播、互动直播、预告与回放。
- `report`：线索列表、爆料表单与处理记录。
- `services`：服务目录、详情、申请和最近使用。
- `points`：签到、任务、积分明细与兑换。

`Mine` 聚合壳、登录/会话、协议隐私、设置、消息和反馈的最终所有权仍由 `D-12` 决定；不能预设全部属于稳定宿主，也不能为了拆 import 全部包装成可选模块。决定后收敛到唯一所有者，其他 feature 只依赖公开入口/read-model/action，不能继续相互导入实现文件。

这些能力不预设为 Flutter 原生。选择载体时应综合交互频率、媒体和设备能力、离线与后台要求、性能、迭代频率以及外部系统所有权；业务是否需要与采用何种载体是两个独立的实施前决策。选型获批后，当前代码基线只实现并维护该既定方案。

### 4. 交付载体

业务能力确认后，在实施前按需求选择以下唯一实现；不因能力“可选”就默认原生，也不把所有业务改成 H5：

- **原生**：适合高频、高体验、稳定播放器、后台、离线或强平台能力场景。
- **H5**：适合规则、表单、活动、运营变化快、低频或已有 Web 系统承载的场景。
- **混合**：由原生提供稳定入口、摘要或设备桥接，H5 承载频繁变化的业务主流程。
- **受控外部跳转**：适合由第三方系统所有且不需要 App Bridge 的办事场景，目标仍须经过宿主策略校验。

所有 H5 轻应用统一通过 `MiniAppContainer` 打开，不允许 feature 自行创建无约束 WebView。核心容器负责可信域、导航策略、错误页、加载态和生命周期；登录态交换、设备能力、版本化 Bridge 与审计只在阶段 4B 触发后加入。

以下矩阵只列出实施前的非约束选择因素，不是默认答案、产品批准或运行时映射规则，也不代表所有业主单位都需要这些能力；实际答案只能由 `D-01` 对应的版本化 `ProductAssemblyDecision` 给出：

| 候选能力 | 非约束选择条件 |
|---|---|
| `live` | 客户可不包含。需要稳定播放器、DRM、横竖屏、画中画或后台音频时优先原生/混合；简单嵌入可评估 H5。 |
| `report` | 优先 H5/混合；相机、定位、大文件或断点上传、离线草稿要求高时增加原生能力。 |
| `services` | 优先 H5 或受控外部系统；仅高频、强交互且归 App 自有的流程评估原生。 |
| `points` | 优先 H5；积分账本和规则必须由服务端负责。可在“我的”原生显示余额与入口，任务、明细、兑换走 H5，扫码、分享等通过受控 Bridge。 |

## 三类配置

### AppProfile

`AppProfile` 表示在构建/发行时由唯一 `profileId` 选定、并在生产安装包运行期间保持不变的 App 身份、品牌/法律资料和安全上限。仓库可以保存多个 profile 供不同客户构建或自动化测试使用，但单个生产安装包只选择其中一个。它不承载完整业务数据，不决定物理构建事实，也不替代远程运营配置。

建议字段范围：

- `profileId`、`displayName`、简称、默认语言和目标平台身份引用。
- Android namespace/application ID、label、图标/启动资源、network security/manifest 与签名策略引用；iOS bundle ID、display name、图标/启动资源、URL/associated domain、Info/entitlements/ATS/隐私与签名策略引用；macOS 需独立的 product/bundle ID、entitlements 与签名策略引用；Web 正式发行时需 canonical origin、PWA `id/scope/start_url`、名称/图标/manifest 引用。macOS/Web 字段只在相应目标平台获批后成为必填，缺项 fail closed；凭据不进入 profile。
- Dart `MaterialApp.title`、App Logo、启动图、顶部视觉资源和不可由用户切换的品牌 token 引用。
- 许可证、备案号、协议、隐私政策、联系地址和举报信息引用。
- `profileAllowedCapabilities`：该 App 身份允许使用的业务能力集合。
- `defaultEnabledCapabilities`：无更高优先级有效配置时默认启用的能力集合。
- 默认导航顺序、默认首页频道策略与安全上限引用。
- API 环境标识、`trustedMiniAppOrigins`、`cleartextMediaHosts`、证书/安全策略引用；两个集合职责不同且 MiniApp 永远不得继承媒体明文例外。不得包含明文密钥。
- 配置 schema 版本和最低兼容 App 版本。

允许范围与默认启用状态是两个独立概念，不得用同一字段同时表达。配置加载和阶段 1 测试必须验证：

`defaultEnabledCapabilities ⊆ profileAllowedCapabilities ⊆ packagedCapabilities`

- 默认启用不得超过 `AppProfile` 允许范围。
- `AppProfile` 允许范围不得超过当前构建实际包含的 `packagedCapabilities`。
- H5/MiniApp 清单还必须同时落在可信域、安装包 Bridge capability 和兼容版本范围内。

运行时还必须满足 `effectiveEnabledCapabilities ⊆ approvedAssemblyCapabilities ∩ profileAllowedCapabilities ∩ packagedCapabilities`。`approvedAssemblyCapabilities` 来自本次 `ProductAssemblyDecision`/`ResolvedBuildSpec`；canonical manifest 中仅作为物理事实出现、但未获产品批准的能力必须保持未注册、未启用。

`AppProfile` 不包含 `packagedCapabilities`，不决定或切换能力的技术载体，也不记录载体映射。`packagedCapabilities` 来自构建所有的 `PackagedCapabilityManifest`；载体来自获批的 `ProductAssemblyDecision`。后续客户若要求更换载体，应按新的产品版本完成决策、代码迁移、测试和发布，而不是新增按 profile 选择实现的映射。

“西昌发布”是明确请求默认实例时使用的 `AppProfile`。客户名称、Logo、许可证、协议和地址不得继续散落在通用代码、通用 Widget 或其他模块 fixture 中。生产运行期不提供 profile 切换入口；显式客户 profile 校验失败时不得以西昌继续启动或出包。

App 的品牌身份与用户外观偏好必须分开：`AppProfile` 持有不可跨客户切换的名称、Logo、法务资料和品牌安全范围；当前 `AppBrandId` 等用户可选项属于 `UserPreferences.themePreset/accentPalette`，只能在 profile 允许的外观白名单内调整配色，不能改变 App 身份、Logo、法律文本或平台元数据。

### RemoteAppConfig

`RemoteAppConfig` 表示未来由正式服务端下发、且通过可验证来源真实性的签名、schema、generation、防回放和兼容性校验的运行时配置。它是条件能力，不是核心基线已经具备的事实。

建议字段范围：

- 配置版本、发布时间、过期时间、最低/最高兼容 App 版本。
- 已打包原生模块及其入口的启停、排序、入口文案和有限展示参数。
- 已批准采用 H5 或混合实现的轻应用清单、入口、可信域、Bridge 能力授权和版本要求。
- 运营时间窗、灰度条件、维护状态和紧急下线开关。
- 可被远程覆盖的主题/内容参数白名单。

约束：

- 只能在当前 `AppProfile` 允许范围内收窄或调整安装包中已注册的原生模块及入口；生产 bundled/remote 配置包含未知 module/capability/section ID 时，整份候选配置拒绝并记录，不做部分应用。
- H5 清单只能用于产品方案已经确定采用 H5 或混合实现的能力，并且只能在 `AppProfile` 可信域、安装包 Bridge 能力和兼容版本范围内下发。
- 配置 schema 不得包含可修改的 `deliveryType`，不得把原生能力切换为 H5、把 H5 能力切换为原生，或在获批方案之外临时启用另一套实现。
- 不能下载、解释或执行新的 Dart 代码，不能修改证书信任、平台权限或原生签名边界。
- 不能替换当前 `AppProfile`、修改 `profileId` 或将可信域和安全能力扩大到 `AppProfile` 给出的上限之外。
- 正式启用远程拉取后必须保留有最大陈旧期的 signed last-known-good；拉取失败、校验失败或版本不兼容时只能回退到仍可信、未突破安全 high-water mark 的 LKG 或 bundled 安全默认，不能重新启用已撤销能力。
- 配置应用必须可观测，记录版本、来源、校验结果和实际启用的模块、入口或 MiniApp，但不得记录令牌或敏感个人信息。

### UserPreferences

`UserPreferences` 只保存用户可自主决定的本地偏好，例如：

- 深浅色、字号、全局灰度和无障碍偏好。
- 频道排序、已读提示、搜索历史和最近使用入口。
- 用户主动授权的通知或个性化开关。

用户偏好只能在有效业务能力和入口范围内表达个人选择，不能启用 `AppProfile` 或远程配置禁用的能力，不能扩大 H5 Bridge 权限，也不能覆盖许可证、可信域和安全策略。用户数据 key 按 opaque `AccountScope + moduleId/miniAppId/feature-owned key` 的实际所有权分区，避免账号切换或能力禁用后串数据；不同独立 App 由各自的 bundle/application ID 和平台沙箱隔离，不在应用内模拟客户分区。

### 合并优先级

运行时有效配置按以下顺序求交集和覆盖：

1. 构建所有的 `PackagedCapabilityManifest` 声明逻辑能力硬上限；经 `ArtifactAttestation` 回读后，才证明实际包含的原生代码、插件、SDK、平台权限、网络例外和 Bridge 能力。
2. 构建时选定的 `AppProfile` 给出当前 App 的身份、默认品牌、法律信息、允许的业务能力与安全上限，以及独立的默认启用状态。
3. 已验证的 `RemoteAppConfig` 只能在前两层范围内启停已打包原生模块及入口，或为已经确定采用 H5/混合实现的能力下发符合可信域、Bridge 能力和兼容版本约束的清单。
4. `UserPreferences` 只能在前三层允许的范围内表达个人偏好。

任何后置层都不得扩大前置层的能力或安全边界。运行时只决定允许范围内哪些既定实现生效，不改变技术载体。`UserSession` 不属于配置合并层，它只提供当前 App 内的用户身份与授权摘要。

### 构建裁剪与验证边界

构建裁剪分为两层，不能混为同一保证：

1. **核心基座当前保证**：`ModuleRegistry` 依据有效配置不装配未选或禁用的原生能力；其入口、Provider、状态、存储加载、订阅、后台任务和其他运行时副作用均不启动。这一层不能证明依赖包、原生 SDK 或平台权限已从安装包物理移除，也不能宣称该客户未声明不需要的平台权限。
2. **客户级物理构建目标**：特定客户不需要的代码、Flutter 插件和第三方原生 SDK 不进入其安装包，相关平台权限不进入最终 manifest/entitlements。该目标需要独立的构建组织/打包 ADR 与产物检查保证，不由 `AppModule` 或 `ModuleRegistry` 自动实现。

当前仓库保持单一 `pubspec.yaml` 且没有 flavor。本计划现在固定 `resolveBuild(...) -> ResolvedBuildSpec`、`build -> artifact + canonical manifest`、`verifyArtifact(artifact, spec, canonical manifest) -> ArtifactAttestation` 的 CI 接口，以及稳定 capability/平台身份 ID；canonical manifest 必须与产物不可分割绑定且被 attestation 按 digest 证明。不预先决定多 package、独立 app target、具体 flavor 或 manifest 编码方案。当出现第一个“必须从某客户安装包物理排除第三方插件/SDK/权限”的获批需求时，立即触发构建拓扑 ADR；ADR 应比较可维护性、依赖解析、签名/发行、CI 矩阵和产物验证，再选定方案。

无论拓扑 ADR 是否触发，每个目标平台产物都必须可回读其最终身份和安全声明。Android/iOS 是否为正式发行平台、macOS/Web 是仅预览还是也发行仍是产品/发行 Unknown；`ResolvedBuildSpec` 和 attestation 必须始终带 `targetPlatform`，不能用一个跨平台集合替代具体产物事实。

## AppModule 与 ModuleRegistry

### AppModule 契约

`AppModule` 只表示当前构建静态包含的 Flutter 原生实现，不代表所有可选业务能力，也不保证插件或 SDK 的物理裁剪；H5 不需要伪装成 `AppModule`。第一版必需公共契约只保留：

- 唯一且稳定的 `moduleId`。
- 不执行 feature 代码即可读取的静态描述，以及延迟创建 Provider/Repository/ViewModel 的模块工厂；注册表中不得放已经启动的全局实例。
- 静态描述中的 owning `capabilityId` 与导出 `sectionId`，必须和 `PackagedCapabilityManifest` 一致；module 是最小运行时启用单元，不能把独立启停能力隐藏在一个会整体初始化的工厂后面。
- 可选的最小 `AppShellSection`：稳定 `sectionId`、标题/图标和接收窄宿主上下文的 section builder。当前允许的宿主信号只有 `isActive`、单调递增的 reselect/scroll-to-top 请求，以及该 section 已有真实消费者需要的等价只读信号；它不包含 `deliveryType`、`targetRef`、通用路由解析、任意生命周期对象或动态载体切换。
- 仅在模块持有真实资源时提供最小清理/`dispose` 钩子；简单模块不实现空生命周期方法。

模块版本与依赖求解、通用 config schema/default/validator、诊断快照、安全热停和统一后台任务协议均不进入第一版必选契约。只有出现真实消费者时，再以 `AppLifecycleParticipant`、`BackgroundTaskContributor` 等独立小接口扩展。

模块对外只暴露公开入口、类型明确的 open action 或稳定的窄 read-model。Search、My Activity 等聚合页面读取的是诸如 `SearchResultSummary`、`ActivityItemSummary` 的不可变摘要，并通过 `openResult/openActivityItem` 等归属方动作打开；不得复用对方页面模型或 switch `moduleId` 后自行 import 实现。Feature 不得导入另一个 feature 的 `views/`、`view_models/`、`data/` 等实现文件。可选插件 package API 只允许出现在 owning module 的 platform/data adapter 或明确的宿主 adapter 中；shared core、read-model/open-action 和 `AppModule` 公共契约不得暴露插件类型。

### ModuleRegistry 职责

`ModuleRegistry` 只装配当前构建静态包含的原生模块，是其唯一装配入口；它不负责 pub 依赖解析、原生 SDK 裁剪或平台权限生成。注册表在一次 App boot 内解析一次并保持不可变，第一版不支持热增删模块：

1. 只收集安装包内静态注册的纯描述和工厂引用，尚不调用任何模块或 section 工厂。
2. 在过滤前校验全部 `moduleId` 与 `sectionId` 唯一；重复 ID 属于构建/装配错误，整次解析 fail closed，不采用 first-wins，也不调用冲突项或其他模块工厂。
3. 验证 `PackagedCapabilityManifest`、`AppProfile` 和有效配置的集合及未知 ID，并校验 `capabilityId -> moduleId -> sectionId` 与模块静态描述一致；越界或映射冲突拒绝并记录。
4. 在仍未调用工厂的前提下过滤未选/禁用模块；禁用模块的任何 Provider、Repository、Widget、订阅或清理钩子工厂都不得执行。
5. 发布不可变的已启用模块/section 目录；只有 section 首次挂载或模块公开能力首次被真实消费时，才原子创建该模块 scope。
6. 模块工厂创建成功后，section 实例按当前 Tab 行为保留至本次 boot 结束，避免切换 Tab 丢失状态；reselect 只通过窄宿主信号传递。需要热卸载时必须另有真实需求和 ADR，不在第一版假装支持。
7. 工厂失败不得发布半初始化 Provider/section；已创建资源按模块自己的最小清理钩子回收。可选模块被标记为本次 boot 不可用并呈现确定的宿主级失败状态，行业核心/宿主模块失败则阻止进入不完整 App；两者都记录去敏诊断且不自动换成其他载体。
8. 对生产 bundled/remote 配置中的未知 module/capability/section ID 拒绝整份候选配置并记录，不静默启用，也不忽略后继续部分装配；开发测试 fixture 也必须显式断言相同语义。

上述禁用语义仅适用于当前构建已包含的原生模块：入口不存在、内部路由不可进入、Provider 未创建、状态未加载、存储未打开、订阅和后台任务未启动。仅通过 `Visibility`、空页面或权限拦截隐藏入口不算完成。

H5 或混合能力禁用时，对应入口和已有外部入口映射不可用、MiniApp 不加载、Bridge capability 不授予，相关会话与缓存按策略回收。混合能力同时满足其原生部分和 H5 部分的禁用语义。

### 跨 feature 导航边界

- Feature 内部可继续使用 `Navigator.push` 打开自己的页面，不要求改成命名路由。
- 跨 feature 跳转由宿主组合根注入 `onOpenReportForm`、`onOpenLiveDetail`、`onRequireLogin` 等少量类型明确回调，或通过对方公开接口完成。
- 跨 feature 聚合由所有者提供窄 read-model + open action；Search/My Activity 在能力禁用后是隐藏该类结果、保留只读历史还是显示不可用状态，属于产品 Unknown，必须在迁移对应入口前决定，不能留下可点击的失效入口。
- 不创建包含所有页面方法的 god navigation service，也不为当前固定五 Tab 和薄导航封装迁移到 `go_router`。
- 只有真实出现“同一能力多实现必须并存”，或正式统一深链、推送、远程入口解析需求时，才通过 ADR 重新评估通用 `AppDestination`；当前不预建该基础设施。

### 语义依赖闸门

32 条 `ui/features/A -> ui/features/B` import 是不可改口径的历史进度指标，但不是完整的架构验收。Stage 2 开始前建立一份可复核的代码所有权表，覆盖 `lib/app/`、`lib/core/`、`lib/data/`、`lib/domain/`、`lib/ui/features/` 和 `lib/ui/shared/` 中与宿主、行业核心及候选能力有关的文件，并为每项标记 owner、公开入口/稳定契约和允许依赖方向。

- 禁止 feature、行业核心或其他候选能力通过 `data/repositories`、`domain`、`core`、`ui/shared` 或 barrel export 绕道依赖另一候选能力的 Repository、ViewModel、Widget、模型实现或插件类型；文件位于共享目录不自动成为共享契约。
- 宿主组合根只允许依赖模块公开工厂、静态描述、`AppShellSection`、窄 read-model/open-action 及明确的 host adapter。不得直接构造候选能力 Repository/ViewModel 或读取其内部状态。
- 真正跨能力共享的底层 platform service、无业务归属的值对象和宿主 adapter 可以列为显式例外；例外必须记录路径、owner、消费者、理由和复核阶段，不能包含候选能力业务实现，也不能用来逃避迁移。
- import/export 检查同时扫描直接 import、re-export 和公开类型签名。`WebViewController`、`VideoPlayerValue` 等可选插件类型不得从 shared/core、read-model/open-action 或 `AppModule` 公共契约泄露；只允许留在 owning module 的 platform/data adapter 或具名 host adapter。
- Stage 2 对首切片要求其全部入向实现依赖和越界导出归零；Stage 3 同时要求历史 32 条归零、所有权表中的语义违规归零、未批准例外为零。两类指标必须分别报告，不能用其中一个替代另一个。

## 状态与存储拆分

### 状态所有权

逐步拆分当前全局状态，目标所有权如下：

- 宿主状态：只读的当前 `AppProfile`、有效配置版本、模块目录、生命周期和全局错误边界。
- 外观与用户偏好：主题、字号、灰度及明确的跨模块用户设置。
- 会话状态：登录身份、令牌状态和授权摘要，通过稳定 `SessionAccess` 接口提供。
- 行业核心状态：首页频道偏好、稿件阅读/收藏等由对应核心能力所有。
- 原生能力状态：对应原生部分拥有自己的 Repository、ViewModel 和本地状态。
- H5/混合状态：H5 主流程不在 Flutter 内复制完整业务状态；混合模式只保留原生摘要、桥接和必要缓存。

不新建一个更大的全局 Controller 来替换旧 Controller。页面通过自己的 ViewModel 消费 Repository 或公开能力，Repository 继续作为其数据类型的单一事实来源。阶段 3 结束时，旧 `AppStateController` 必须被消除，或只保留一个名称与职责一致、没有候选能力状态和副作用的单一职责对象；不得把未拆完的状态继续归类为“全局”。

每个会产生持久化副作用的 mutation 只能由 owning Repository 执行，并返回可等待的显式 success/failure result；View/ViewModel 不直接写 key，也不得 fire-and-forget storage future。Repository 只有在必要持久化全部成功后才发布 committed state；采用 optimistic state 时必须显式暴露 pending/failed，并提供确定的 rollback/retry。多 key mutation 即使底层没有事务，也不得向消费者发布半成功状态，必须用 operation marker/补偿或可恢复结果说明剩余状态。

若 `points` 采用 H5 或混合交付，积分账本、任务规则和兑换状态必须由服务端作为事实来源，不得由 Flutter 本地状态维护另一套完整账本。

### SessionAccess 与 AccountScope

`SessionAccess` 是供宿主和 feature 读取的最小会话端口，不是通用账号服务：

- 只暴露不可变的 `AuthSummary`（匿名/已认证、opaque account scope、必要的角色/授权摘要）和可观察的单调递增 `sessionGeneration`；业务 feature 不读取原始长期 token，也不以手机号判断身份。
- 登录、退出、账号切换、凭据撤销或会改变授权边界的刷新都产生新的 `sessionGeneration`。异步结果、MiniApp 文档和未来 Bridge grant 必须绑定取得时的 generation，提交结果前再次比较；过期结果丢弃。
- `AccountScope` 是不透明值：已登录态最终使用服务端提供的稳定、非 PII、不可复用 subject ID；手机号不能进入 `AuthSummary`、`AccountScope`、事件、read-model/open-action 或日志，也不能哈希后冒充稳定 ID。迁移期间只有 `LocalPointsCompatibilityAdapter` 可在内部读取手机号以定位既有 points key，并把它封装在 adapter 私有映射中；公共调用方只看到本次会话的 opaque scope。该兼容不构成稳定 subject，也不关闭 `D-04/D-05`；服务端 ID 未确定前，账号级 key 不得进入 `shadowWrite`、`verified` 或 `committed`。
- guest scope 也必须是不透明且不含 PII；其安装生命周期、登录后合并还是丢弃、退出后是否恢复，保持 Unknown。该决定只阻断账号/guest 数据迁移和依赖合并语义的功能，不阻断非账号 key 或其他无关切片。
- 需要 H5 token 时由阶段 4B 的专用 scoped-token 契约消费 `SessionAccess`，不能把长期 token 加回基础端口。

### 积分跨能力事件边界

当前阅读、收藏、评论、直播预约、爆料和服务申请会直接触发 `AppStateController` 的积分任务。最迟在首个产生这些事件的垂直切片内，必须先引入小而类型明确的 `EngagementEventSink`（也可在代码评审时采用同等职责名称）、最小 `SessionAccess`/opaque `AccountScope`、禁用 no-op，以及保持西昌原型行为所需的 `LocalPointsCompatibilityAdapter`；不能等 points 成为首切片，也不建设通用事件总线：

- 事件集合冻结为六类：`articleRead`、`articleFavorited`、`commentPublished`、`liveReserved`、`reportSubmitted`、`serviceApplied`。签到属于 points 内部行为，不进入该跨能力端口。事件不携带客户端计算的积分值、余额或兑换结果。
- 每个事件包含事件类型、归属业务对象的 opaque ID、`AccountScope`、发生时间和可重试的稳定 `eventId/idempotencyKey`；不得包含手机号、页面任意参数或客户端奖励数值。
- 调用方只依赖 `EngagementEventSink`，不得 import points 的 ViewModel、Repository 或状态实现。
- points 采用 H5/服务端时，由对应 Repository/API 适配该端口；服务端积分账本、任务规则和兑换状态仍是事实来源。
- 事件接收采用 **pending-once**：同一 `AccountScope + eventId` 只能把对应任务从未发生推进为 pending 一次；重复提交返回 `alreadyRecorded`，不得重复奖励、重复写交易或重复触发 UI。失败后的重试使用同一 key，因此是幂等重试而不是新事件。
- 内容收藏、评论、预约、爆料或服务申请等主业务操作的成功不依赖积分接收成功。sink 返回 `accepted/alreadyRecorded/unavailable/failed` 等显式结果；`failed` 记录去敏诊断并允许有界重试，但不得回滚或伪造主业务失败。
- 迁移期间可由具名 `LocalPointsCompatibilityAdapter` 适配旧本地逻辑，保持默认西昌原型行为；它不具备生产积分事实源资格。只有正式 points 服务/API 契约存在时才宣称服务端 SSOT。
- points 未选或禁用时，注入不触发初始化的显式 no-op sink 或不装配实现；返回 `unavailable` 对主业务为非致命结果，并且不得创建 points Provider、状态、存储或后台任务。

### 存储边界

- 共享存储服务只提供底层 key-value、文件或数据库能力，不理解业务字段。
- 每个模块通过 Repository 拥有自己的序列化、迁移和清理策略。
- 新 key 必须包含 schema 版本和模块/feature 所有权；用户数据还需使用 opaque `AccountScope` 区分账号或匿名态，不增加运行期客户维度。
- 不同客户 App 通过不同 bundle/application ID 对应的平台存储沙箱隔离；同一代码基座不等于共享同一份本地数据。
- 迁移按数据风险分级，不用一次全局布尔值表示全部迁移完成。账号作用域、多 key、非原子写、积分/会话/隐私等高风险或回滚代价高的 key family 使用以下完整、独立且可恢复的状态机：
  1. `legacyRead`：旧 key 为唯一读取/写入来源，先记录所有权、类型、默认值和损坏数据语义。
  2. `shadowWrite`：读取仍以旧 key 为准；每次业务写入同时写新旧 key，后台/启动迁移也只补写新 key，不删除旧值。
  3. `verified`：按规范化值比较新旧数据、scope、数量和反序列化结果；校验失败留在/退回 `shadowWrite` 并以同一迁移 operation ID 幂等重试。
  4. `committed`：只有完整校验后才原子写入带 schema、scope 和迁移 generation 的 commit marker；此后读取新 key 优先，回滚窗口内旧 key 作为有日志的有界 fallback，并继续必要的双写。
  5. `rolledBack`：发现回归时用 marker 将读取优先级恢复到旧 key，保留新数据供诊断和再次迁移，不删除任一侧。
  6. `cleanupEligible`：跨过至少一个明确兼容版本/回滚窗口，且 telemetry/测试证明无旧读取后，另行批准清理；清理不是迁移成功事务的一部分。
- App 在任意步骤崩溃后必须能由 marker 和数据校验恢复到上一个可读状态；失败不得留下“marker 已提交但新值未完整写入”的半状态。
- 对单值、非账号作用域、底层原子写且可由安全默认恢复的低风险外观/开关偏好，可使用较轻的版本化 read-through：旧 key 兼容读、写新 key 后读回校验、失败继续读旧值、跨过明确回滚窗口后再清理。所有权、schema、失败 fallback 和清理闸门仍必需，但不强制伪造六个状态或独立 marker。风险等级和选用路径必须记录在 key 所有权表并由测试证明，不能仅以“偏好”名称降级。
- 禁用模块默认不删除用户数据；是否清理由产品策略和隐私要求另行决定。
- 日志、远程配置缓存和 Bridge 审计数据设置明确保留期，不与用户偏好混存。

## MiniAppContainer 与条件 Bridge

### MiniAppContainer

Stage 4A 必须覆盖当前两个 `WebViewController` 实现及全部活跃调用链：内嵌的 `ChannelH5Tab`、频道子链接打开的 `InAppWebPage`、首页内容块/专题入口打开的 `InAppWebPage`。每个入口只能迁入同一策略容器、改成受控外部跳转，或在发行前被明确移除；不能留下一个无约束通用 WebView。`services` 的 H5 target 当前只是占位展示，不得误报为已受容器保护的活跃页面。

通用容器至少负责：

- 仅加载配置清单中的 HTTPS 初始 URL，开发环境例外必须显式且不可进入生产 profile。
- 以 `miniAppId + canonical HTTPS origin + allowed path scope + navigation policy` 标识一个轻应用；origin 和 path 职责分开，不能用字符串前缀/包含判断。
- 对初始加载、每一跳 HTTP 重定向、JS/meta/form 导航、主 frame、子 frame、新窗口、下载和外部 Scheme 分别执行策略判断。
- 每次跨 origin 后重新计算信任；没有获批 Bridge 的页面不获得任何宿主 capability。
- 提供统一加载、错误、离线、超时、返回、标题和关闭行为。
- 按 Cookie、HTTP cache、Web storage、临时文件和 scoped token 的真实平台能力分别定义隔离与清理；在 POC 证明前不得承诺通用的 `miniAppId` 硬分区。
- 在退出、切后台、对应 H5/混合能力禁用或账号切换时执行明确的生命周期回收。
- Splash 图片文件当前位于 Application Support 下的 `admin9-splash-cache`，并以 `splash_cache_metadata` 记录元数据；它不是系统临时缓存目录。Stage 4A 必须为文件与 metadata 定义一致的枚举、大小统计、保留期、删除顺序、部分失败恢复和隐私文案，不能只清一侧或继续声称使用“临时缓存目录”。

导航基线矩阵如下；业务例外只能在 `AppProfile` 安全上限内由获批 MiniApp manifest 明确收窄/放行，并为 Android/iOS 各自测试：

| 场景 | 默认处理 | 必须证明 |
|---|---|---|
| 初始主文档 | 仅 exact HTTPS origin + allowed path；HTTP、IP、未批准端口拒绝 | 规范化、端口、path traversal 和编码绕过测试 |
| 30x / JS / meta / form 导航 | 每一跳按新 URL 重新校验，不继承初始信任 | 中间跳、最终跳、循环和降级到 HTTP 均可阻断 |
| 同 origin 主 frame | 仅 allowed path 内留在容器 | 前进/后退/刷新仍执行同一策略 |
| 跨 origin 主 frame | 默认拒绝；获批外链转系统浏览器且不携带 App 会话 | URL 去敏、用户可辨认、返回 App 后不恢复旧授权 |
| 子 frame/iframe | 默认拒绝未列来源；获批子 frame 永不自动获得业务 Bridge | 能区分 main/subframe；不能区分时按更严格策略处理 |
| `window.open`/弹窗 | 默认拒绝；获批目标作为新的受控导航或外部跳转处理 | 不复用原文档授权，不产生不可见窗口 |
| 下载 | 默认拒绝；真实需求出现后定义 MIME、大小、落盘、扫描和打开策略 | 不把下载 URL 交给任意外部 Scheme，不暴露 Cookie/token |
| `tel/mailto/maps` 等外部 Scheme | 默认拒绝；逐项获批并在调用前做参数校验/必要确认 | 非允许 Scheme 和嵌套 URL 参数被拒绝 |
| TLS/证书错误 | 不可绕过，显示统一失败并允许安全重试 | 不提供“继续访问”；重试重新校验完整链 |

生命周期与数据处理矩阵如下；Stage 4A 的现有页面不注入登录 token：

| 事件 | 页面/控制器 | 会话与授权 | 数据处理 |
|---|---|---|---|
| 用户返回/关闭 | 销毁非保留页面；保留策略必须由 manifest 明确 | 撤销该 document 的临时授权 | 按数据分类清临时文件，不谎称已清全局 Cookie |
| App 进入后台 | 暂停媒体/敏感任务，拒绝新宿主调用 | 4B 若存在则暂停 grant | 恢复时重验当前 URL、配置 generation 和 session generation |
| 登出/账号切换 | 关闭并重建所有可能接触会话的 controller | 撤销 token，递增 `sessionGeneration` | 执行 POC 证明可用的 Cookie/Web storage 清理；失败则保持页面关闭并上报 |
| 能力禁用/信任收窄 | 立即关闭受影响页面，清除入口和历史恢复句柄 | 立即撤销 capability | 清理该能力临时数据；持久数据按隐私/产品策略，不把禁用等同删除 |
| App 终止/下次冷启动 | 不恢复未重新获批的页面 | grant 不跨 boot | 缓存/LKG 只按明确保留期读取 |

进入 Stage 4A 实现前必须用最小原型在 Android/iOS 分别证明：导航 delegate 对上述主/子 frame、重定向、新窗口和下载事件的可见性；Cookie/Web storage/cache 的实际清理粒度；controller 重建后的数据残留；同 origin 多 MiniApp 是否可隔离。POC 结论只能在“独立 origin”“临时 data store/平台 profile”“账号切换时全局清理并禁止共享 SSO”等可证明方案中选择；若均不满足需求，Stage 4A 停在闸门，不以文档承诺代替平台能力。

### 可信域

- `trustedMiniAppOrigins` 由 `AppProfile` 给出 MiniApp HTTPS 硬上限，MiniApp manifest/`RemoteAppConfig` 只能选择或收窄，并另外声明 allowed path 与导航策略。
- `cleartextMediaHosts` 只描述播放器等非 WebView 媒体栈的临时平台明文例外，不授予 MiniApp、Splash 下载器或通用 HTTP 客户端信任；它与 `trustedMiniAppOrigins` 不得交集。
- 域名匹配使用规范化 host 和明确的子域规则，不使用字符串前缀或包含判断。
- MiniApp 的 IP、未批准非标准端口、明文 HTTP、证书错误和未批准重定向默认拒绝，即使操作系统 network security/ATS 因媒体源允许该 host 明文也不例外。
- 可信主文档不自动意味着所有 iframe、弹窗、下载和外部跳转都可信。

当前 `http://xcfb.screx.com.cn:18085/...m3u8` 及 Android/iOS 对该 host 的明文例外登记为 live 媒体债务；`http://app.lsiptv.cn` 仍是不可加载的 service fixture 占位。前者是否存在 HTTPS/CDN 替代、是否进入正式发行包保持 Unknown；正式、带登录态或付费媒体不得以现有 HTTP 链路通过验收。Splash 和其他远程下载必须逐跳复核 scheme/host/port，不能因首跳 HTTPS 自动跟随到 HTTP。

### 版本化业务 Bridge（条件能力）

只有获批 H5/混合能力确实需要登录态、相机、定位、分享等宿主能力时，才建设业务 Bridge、逐项授权和审计；纯浏览或无需 App 能力的第三方系统不为此提前增加 Bridge。

当前 `Admin9H5LinkBridge` 只把频道页面中的链接字符串交给容器打开 `InAppWebPage`，属于 `container-internal` 导航通道：它没有可信发送 frame/origin、document generation、授权或 token 语义，**不能直接作为阶段 4B 的可信业务 Bridge**。Stage 4A 必须把其名称、注入 frame、输入 schema、处理器、导航约束和销毁时机记入 `PackagedCapabilityManifest`，并决定在统一容器中保留、收紧或移除。

Stage 4B 开工的技术前置不是“已有 JavaScriptChannel”，而是先用获批消费者证明 transport 能从平台可信地取得并绑定 top-frame security origin、document generation、`miniAppId`、`sessionGeneration` 和 Bridge/build version。不能从消息 payload、页面自报 origin 或回调时的 `currentUrl` 推断发送者；若现有插件通道无法证明，必须改用平台 WebMessage/原生 handler 或另选受审 WebView transport，再定义业务 API。

Bridge 采用显式版本，例如 `admin9.bridge.v1`，消息必须包含 `requestId`、`method`、`version` 和结构化参数。

能力按轻应用逐项授权，例如：

- `navigation.openApprovedNativeAction`
- `session.requestScopedToken`
- `device.getSafeInfo`
- `media.pickImage`
- `share.openSystemSheet`

默认拒绝未声明方法，并对关闭 unknown fields 的参数 schema、嵌套深度/字符串长度、消息大小、并发/调用频率、可信 top-frame origin、document/session generation 和前台生命周期进行校验。授权是安装包 capability、`AppProfile`、已签名 MiniApp manifest、当前 session/角色、系统权限和用户确认的交集。Bridge 不暴露任意 Dart 方法、任意文件路径、原始长期令牌、任意网络代理或动态代码执行能力。敏感操作需要用户确认或系统权限时，必须由原生侧完成确认。

Bridge 返回结构化成功/错误响应，`requestId` 在当前 document generation 内防重放。scoped token 必须短时、单用途、服务端可撤销，并绑定 audience、account、`miniAppId`、origin、request/document/session generation、jti 和 expiry；不得进入 URL、Cookie、localStorage 或日志。限流同时在原生端和 token/API 服务端执行。审计只记录事件 ID、MiniApp ID、canonical origin、capability、结果码、耗时、配置/Bridge 版本和伪名会话关联，不记录参数、token、完整 URL 或个人信息。版本不兼容时显示明确升级/降级提示，不静默放宽权限。

## RemoteAppConfig 条件生命周期

只有存在正式 `RemoteAppConfig` 服务/API、可验证来源真实性的非对称签名方案，以及明确的密钥、发布、回滚、监控和运维责任契约时，才实施远程生命周期。普通 checksum、无密钥 hash 或只依赖 TLS 不能替代配置签名。

签名对象是 canonical envelope，至少包含 `profileId`、environment、schema version、单调递增 `generation`、issued/expiry time、min/max build、payload digest、`keyId` 和签名算法标识。App 内置受控公钥信任锚；密钥轮换必须有双钥过渡或新版本预置，吊销必须有可持久化的安全 generation/策略，不能因回滚重新信任已吊销密钥。

应用流程必须全量、原子且防回放：

1. App 以 `PackagedCapabilityManifest`、构建时绑定的 `AppProfile` 和 bundled defaults 启动，不因远程不可用切换 profile。
2. 读取本地 envelope、payload、digest、已接受最高 generation、安全收窄/吊销 high-water mark 和 LKG；全部重新验签、验 schema、profile/environment/build、有效期与能力上限。
3. 后台拉取新 envelope；只有签名有效、generation 严格前进、未过期且不来自未来容忍窗之外、配置全集合法时才进入 staging。跨 profile/env/build 或回放旧 generation 一律拒绝。
4. 先把完整 envelope/payload 写入 staging 并校验持久化结果，再以原子 marker 切换 active generation；随后一次性计算并发布有效配置。验证或持久化任一步失败都保持旧 active 配置，不暴露半应用状态。
5. 只有完成启动/健康确认的签名配置才能成为新的 LKG。LKG 有明确 maximum staleness；过期后不得继续启用远程新增的 MiniApp、Bridge grant 或其他扩大面，只能使用 bundled 安全默认及已持久化的收窄/吊销 high-water mark。
6. 普通产品回滚必须发布 **更高 generation 的新签名配置**，不能重新接受旧 envelope。启动失败自动回滚只允许选择仍有效、签名可信且不突破当前安全 high-water mark 的前一 LKG；否则 fail closed 到 bundled 安全默认并关闭远程增加项。
7. 未知字段、未知 capability、越界 origin/permission 或不兼容 schema 按 schema 固定的拒绝策略处理并去敏上报；不能“尽量应用”其余字段后形成服务端/客户端理解不一致。

冷热边界必须显式：安全收窄、MiniApp 下线、origin/Bridge grant/令牌撤销立即生效并关闭受影响文档；展示文案等明确白名单可安全热更；能力增加、Provider/路由/后台任务变化默认下次冷启动生效，Bridge grant 增加至少要求新 top-frame document generation。新增原生能力、修改 Dart 逻辑、增加平台权限、升级 Bridge 原生实现或改变安装包安全上限始终需要重新构建、签名和发布。

在上述条件成立前，核心基线只提供 bundled/local config source 和可替换的配置读取接口；签入 fixture 或本地 mock 只能验证读取边界，不能宣称 RemoteAppConfig、签名、LKG 或回滚已经完成。日志只记录 config ID/generation、key ID、digest、验证结果码和生效摘要，不记录 payload、请求 header、完整 URL 查询或用户数据。

## 增量迁移阶段

以下阶段适用于现有静态原型持续可运行、产品/设计可及时确认的迁移过程；不包含真实 CMS/BFF、第三方 SDK、应用商店审核和多客户正式交付。

阶段 1 至 4A 是核心迁移顺序；阶段 4B 和阶段 5 仅在各自触发条件成立后实施。阶段只表达依赖顺序、任务边界和完成标准，不作时间承诺。

### 阶段 0：文档与基线

- **Input**：冻结的分支/HEAD/工作区状态，两份核心文档 hash，`DESIGN.md` 上位边界，六角色审查报告，以及当前代码/平台配置的只读事实清单。
- **Work**：完成目标、术语、不变量、产品装配/构建证明链、候选公共契约、阶段闸门和 Unknown 决策表；记录默认西昌行为、32 条跨 feature import、18 个基础 key、语义依赖基线、全部 WebView/调用入口、插件类型泄露、平台身份/签名与 HTTP/明文例外。不修改运行时代码。
- **DoD**：全部审查 P1 有明确关闭文字和后续可执行验收；P2 已落入对应阶段/Unknown；文档链接与术语无冲突；`ProductAssemblyDecision`、`ResolvedBuildSpec`、canonical `PackagedCapabilityManifest`、`ArtifactAttestation` 的职责和 digest 证明链清楚但未预选构建拓扑/编码；修订前后除获批核心文档外无新增工作区变化，`git diff --check` 通过。
- **Failure recovery**：若核心文档或代码快照漂移，只重核受影响事实和结论；若某 P1 仍依赖未决产品信息，将其写为有 owner/期限/阻断范围的 Unknown，而不是填默认答案。文档失败不进入代码阶段。
- **Next gate**：Stage 1 只能在 Stage 0 DoD 通过后开始；目标平台相关实现还需该次构建明确 `targetPlatform`，正式发行范围仍由 `D-03` 决定。

### 阶段 1：AppProfile

- **Input**：Stage 0 DoD；一个明确的 `profileId + targetPlatform + buildMode + sourceRevision`；该构建对应的 `ProductAssemblyDecision`；其中每个进入 `approvedAssemblyCapabilities` 的能力都已在 `resolveBuild` 前关闭该版本 `D-01` 并给出唯一载体，仍未批准的能力明确不进入运行装配；目标平台完整身份字段与安全声明来源。若遗留代码/插件仍物理存在，spec 和 canonical manifest 必须单独列为打包事实而非批准。若要产出正式客户包，还必须先有发行平台和签名责任决定。
- **Work**：定义最小 `AppProfile`、西昌 profile、唯一 resolver、`ResolvedBuildSpec`、build-owned canonical capability manifest 和 artifact verifier 接口；选择一种可回滚编码把 canonical manifest 嵌入产物或与产物不可分割绑定，并让运行时只读取该份 manifest。先迁移名称、Logo、许可证、协议、联系地址、品牌身份与各目标平台元数据引用。提供 bundled/local config source，不接假远程配置。
- **DoD**：显式未知/无效客户 profile、缺失生产 profile、平台身份缺项、未批准运行装配和集合越界全部 fail closed，测试证明不会回退西昌或根据遗留代码自动注册/启用；`defaultEnabledCapabilities ⊆ profileAllowedCapabilities ⊆ packagedCapabilities`，且 `effectiveEnabledCapabilities ⊆ approvedAssemblyCapabilities ∩ profileAllowedCapabilities ∩ packagedCapabilities`；`packagedCapabilities` 不由 profile 自报。verifier 同时校验 artifact、spec 和 canonical manifest，attestation 绑定 artifact/spec/manifest、源码/profile/产品决策 digest 与 verifier version；运行时 manifest 缺失、错配、越界或被另一来源覆盖时拒绝启动对应装配。manifest 必须如实报告未获批准但仍物理存在的遗留依赖，且测试证明其 Provider、入口、状态和副作用不注册；只有 `D-08` 物理裁剪并验证后才能声明其不在安装包。至少用西昌和一个非西昌测试 profile 对每个本阶段实际支持的目标平台回读名称、ID、图标/启动资源、版本、网络/权限/entitlement/Bridge 清单并生成 attestation。通用代码不新增客户硬编码，用户 theme/accent palette 不会改变品牌/法务身份，导航与任何已获产品批准保留的默认西昌行为不变。
- **Failure recovery**：resolver/产物验证失败即停止出包，不生成“部分客户化”产物；在迁移提交可回滚前保留原西昌资源路径，但只能由明确西昌 profile 选择，不能作为错误 fallback。fixture/mock 只验证读取接口，不标记 RemoteAppConfig 完成。
- **Next gate**：进入 Stage 2 前必须决定首个原生垂直切片 `D-02`，并完成其全部入口、入向实现依赖、状态/key 和禁用行为清单。该能力若已进入 Stage 1 产物，其 `D-01` 已在 resolve 前关闭；若是 Stage 1 后首次加入的新能力，则仍须先关闭该版本 `D-01` 并重新构建/验证产物。

### 阶段 2：AppModule / ModuleRegistry / 导航边界

- **Input**：Stage 1 DoD；已批准为原生或混合原生部分的首个切片；覆盖 `app/core/data/domain/ui/features/shared` 的所有权表与 import/export 基线；该能力全部顶层/首页/Mine/Search/My Activity/直接 push 入口和入向实现依赖；其 read-model/open-action、状态、存储 key、后台/播放器/权限以及禁用后产品行为。若该切片产生六类事件之一，还须给出最小 `SessionAccess`/opaque scope、sink、no-op 和遗留 adapter 的迁移测试输入；这不要求预先关闭 `D-04/D-05`。
- **Work**：实现最小 `AppModule`、boot 内不可变的 `ModuleRegistry` 和带窄宿主信号的 `AppShellSection`；让现有顶层入口逐步由过滤后的 section 列表装配。**同一首个切片内**迁移该能力的全部入口、公开 read-model/open-action、Provider/Repository/ViewModel、状态、存储加载、订阅和后台副作用；不能只改 Tab 后把状态留给 Stage 3。只要切片产生阅读、收藏、评论、直播预约、爆料或服务申请事件，就在同切片前移最小 `SessionAccess`、opaque `AccountScope`、`EngagementEventSink`、禁用 no-op 和保持原型行为所需的 `LocalPointsCompatibilityAdapter`，禁止只改调用方或引入临时反向依赖。手机号只能由遗留 adapter 私有读取，不进入公共契约。
- **DoD**：重复 module/section ID 在任何工厂调用前 fail closed；禁用过滤前无工厂执行；首挂载只创建一次、切 Tab 保留、reselect 信号和工厂原子失败均有测试。首个切片禁用后所有入口/内部路由不可达，Provider/状态/key/订阅/后台任务未初始化；该能力在所有权表中的全部入向实现依赖、越界 re-export 和插件类型泄露清零，Search/My Activity 只依赖窄摘要和 open action。事件生产切片还须证明公共事件/session 契约不含手机号，points 禁用时 no-op 不初始化 points，adapter 仅保持既有原型行为且不把账号 key 迁入 shadow。默认西昌行为不变，没有通用 destination、命名路由、热卸载或生命周期框架。运行时证明不得被描述为物理裁剪。
- **Failure recovery**：切片在发布前可把组合根切回旧路径并回滚其未 commit 的 key migration；模块工厂失败时只按既定核心/可选失败语义处理，不自动换载体或调用禁用模块。任何半初始化 scope 必须清理。事件边界迁移失败可恢复旧调用路径，但不得把手机号泄露进新公共类型、留下部分 adapter 注册或误标 `D-04/D-05` 已关闭。
- **Next gate**：记录剩余跨 feature import 与状态/key 所有者；首个切片 DoD 通过后进入 Stage 3。若首个切片或禁用行为仍 Unknown，Stage 2 不开工。

### 阶段 3：全局状态与存储拆分

- **Input**：Stage 2 DoD；剩余 32 基线 import 的可复核差量清单，以及所有权表中剩余语义违规、re-export、插件类型泄露和显式例外清单；宿主、会话、偏好、行业核心和候选能力所有权表（关闭 `D-12`）；各能力获批载体。任何账号 key shadow migration 还需要稳定服务端 user ID `D-04` 和 guest 策略 `D-05`。
- **Work**：按垂直切片完成剩余 open-action/read-model 边界和状态所有权；对尚未由 Stage 2 首切片前移的消费者补齐最小 `SessionAccess`/opaque `AccountScope`、六事件 `EngagementEventSink`、`LocalPointsCompatibilityAdapter` 与禁用 no-op；按所有权表为高风险 key family 执行完整可恢复状态机，为符合条件的低风险偏好执行版本化 read-through。不为 H5 主流程复制完整原生状态。
- **DoD**：按 Stage 0 相同口径，跨 feature 实现 import 从 32 降为 **0**；同时所有权表中的跨能力实现依赖、越界 re-export、未批准例外和 shared/public 插件类型泄露均为 **0**，组合根只依赖公开工厂/稳定契约/具名 host adapter。旧 `AppStateController` 被删除或缩成无候选能力状态/副作用的单一职责对象；Repository 仍是各数据类型 SSOT。持久化 mutation 均可 await、返回显式结果，不存在 fire-and-forget storage 写入或向 UI 发布半成功状态；optimistic mutation 的 pending/failure/rollback/retry 可测试。六事件满足 pending-once、幂等重试和主业务失败独立，签到保持 points 内部；本地 adapter 只标记为原型兼容，生产 points 必须有服务端 SSOT。高风险 key 有 scope/schema/marker、崩溃恢复、校验、回滚窗口和旧数据读取测试；低风险偏好有版本化读回校验、fallback 和清理闸门。账号/guest Unknown 未关闭时，相关 key 不得进入 shadow 或假装 committed。
- **Failure recovery**：高风险 key family 校验失败退回 `shadowWrite/rolledBack`，低风险偏好校验失败继续使用旧 key；旧数据均不删除。单个 feature 切片可恢复旧公开入口，但不得恢复跨 feature 实现 import、共享目录绕道或越界 export。事件 sink 失败不回滚内容/预约/提交等主业务。
- **Next gate**：**历史 32 条 import 或语义边界违规任一不为 0 时禁止进入 Stage 4A**。所有活跃 WebView 清单、MiniApp manifest 草案、H5/SSO决定边界和 Android/iOS POC 计划准备齐后进入 4A。

### 阶段 4A：现有 H5 基线加固

- **Input**：Stage 3 DoD；两个 WebView 实现及全部活跃调用链；每个页面的 canonical origin/path/导航/外链/生命周期需求；`trustedMiniAppOrigins` 与 `cleartextMediaHosts` 清单；Android/iOS 导航回调和数据隔离 POC。若 H5/SSO `D-06` 未决，本阶段按无 App 会话注入基线实施。
- **Work**：把 `ChannelH5Tab` 和所有 `InAppWebPage` 调用迁入 `MiniAppContainer`、改为受控外部跳转或移除；实现导航和生命周期矩阵、真实清理结果、配置/账号变化回收。把 `Admin9H5LinkBridge` 作为 container-internal 通道盘点/收紧，不建设业务 Bridge。同步把 Splash Application Support 文件、`splash_cache_metadata`、保留期和隐私文本纳入真实缓存清单。
- **DoD**：仓库不存在绕过容器策略的活跃 WebView；初始/每跳重定向、main/subframe、JS/meta/form、`window.open`、下载、外部 Scheme、TLS 错误在 Android/iOS 有定向测试和 smoke。账号切换、退出、后台恢复、能力禁用/信任收窄可关闭并重建 controller；数据隔离承诺与 POC 结果一致，不把全局清理伪装为单 MiniApp 清理。设置页“清理缓存”必须显示实测的数据范围、大小和实际成功/失败；Splash 文件与 metadata 的大小、保留期、删除/部分失败结果一致，隐私文本准确说明 Application Support 持久文件而非“临时缓存目录”。未执行或部分失败不得硬编码大小、提示“缓存已清理”或暗示已清除 Cookie/个人数据。MiniApp 永远不使用 HTTP 或媒体明文例外；默认西昌 H5 行为的任何获批变化有产品记录。
- **Failure recovery**：平台无法证明拦截或数据隔离时，受影响入口关闭或降级为受控系统浏览器，不能保留 unrestricted WebView 例外。清理失败保持页面关闭、授权撤销并去敏上报。
- **Next gate**：没有宿主 capability 消费者时 4B 保持“边界已准备、触发条件未满足”。出现首个消费者时，必须先关闭 `D-06/D-10` 并证明可信 top-frame transport；Stage 5 可独立按自身条件触发，不因 4B 未实施被阻塞。

### 阶段 4B：版本化业务 Bridge（条件触发）

- **Input**：至少一个获批 H5/混合垂直消费者；产品范围、权限用途、数据分类和用户文案；可信 top-frame origin/document-generation transport POC；稳定 session/scoped-token API；App/H5/API/安全/运维 owner 和限流/审计保留策略。当前 `Admin9H5LinkBridge` 本身不满足输入。
- **Work**：只为该消费者定义版本化消息、关闭 unknown fields 的参数 schema、逐项 capability、token、原生+服务端限流、权限确认和去敏审计；授权绑定 MiniApp/origin/document/session/build generation，不提供任意 Dart、文件或网络代理。
- **DoD**：恶意 iframe/origin、导航竞态、旧 document/session、重放 requestId、未授权 capability、超限参数/消息/频率和版本不兼容均被拒绝；登出、后台、配置收窄和页面销毁立即撤销。scoped token 短时、单用途、可撤销且不落 URL/Cookie/Web storage/日志；产物 attestation 能证明 Bridge 清单。业务成功/错误响应及审计可被 App/H5/API 联调验证，不执行动态 Dart。
- **Failure recovery**：任一端版本、token 或安全校验失败时 capability fail closed；页面只能继续无该能力的获批路径或显示确定错误，不降级到长期 token、payload 自报 origin 或旧 JavaScriptChannel。
- **Next gate**：每新增 capability/消费者都重新走产品、安全和 API 契约评审；没有新消费者时不扩建通用 Bridge 框架。

### 阶段 5：RemoteAppConfig（条件触发）

- **Input**：正式配置 API；非对称签名 envelope 和可信公钥/轮换/吊销方案；generation/可信时间策略；发布审批、回滚、监控告警和 on-call owner `D-11`；Stage 1 artifact attestation 与当前产品装配决策。
- **Work**：实现 canonical signed envelope、anti-replay high-water mark、原子 staging/apply、maximum-staleness LKG、安全回滚、冷热边界和去敏诊断；只接入已打包原生能力/入口和已批准 H5/混合 manifest，schema 不含可变 `deliveryType`。
- **DoD**：伪签名、未知/吊销 key、跨 profile/env/build、过期/未来时间、旧/重复 generation、越界 capability/origin/Bridge 和半写入全部 fail closed；普通回滚使用更高 generation 的新签名配置。启动失败只回到仍可信且不突破安全 high-water mark 的 LKG，否则使用 bundled 安全默认并关闭远程增加项；安全收窄立即生效，扩大面遵守冷启动/新文档规则。配置不执行新 Dart，签名/LKG/回滚/断电恢复有自动化和受控发布演练。
- **Failure recovery**：拉取、验签、持久化或 apply 失败保持旧 active generation；过期 LKG 不继续启用远程新增项；撤销/下线不能被默认值或旧 LKG 反向恢复。无法确认 owner 或密钥责任时不启用远程拉取。
- **Next gate**：Stage 5 仅在上述输入齐备时判定实施完成；未触发时状态为“边界已准备、触发条件未满足”，不阻止 Stage 1-4A 收口。

## Unknown 决策登记表

Unknown 不是默认值。每项决策必须在对应触发点形成有版本、批准人和证据的 decision record；未决定时只阻断表中范围，不扩大为整个计划停摆，也不得由工程师擅自选择最低成本答案。

| ID | 当前 Unknown | Owner | 触发/最晚决定阶段 | 未决定时阻断范围与安全默认 |
|---|---|---|---|---|
| `D-01` | `live/report/services/points` 各自最终是否包含及唯一原生/H5/混合/受控外部载体 | 产品负责人 + 客户交付负责人 + Flutter/系统架构 | 该能力首次进入任何 `ProductAssemblyDecision.approvedAssemblyCapabilities` 前，且必须早于对应 `resolveBuild`；若该能力本次不装配，可延至首次纳入后续构建前 | 阻断该能力进入 approved set、运行时 module/MiniApp 装配和客户承诺；当前遗留原型实现与默认西昌均不能代替批准，也不得默认原生、默认 H5 或同时保留两套。canonical manifest 仍如实记录未裁剪的物理事实，但不得据此注册/启用；若移除入口会改变西昌回归行为，另需产品明确批准该变化 |
| `D-02` | 首个原生垂直切片 | 产品负责人 + Flutter 架构 owner | Stage 2 Input 前 | Stage 2 不开工；Stage 1 身份/构建边界不受阻 |
| `D-03` | Android/iOS 是否正式发行；macOS/Web 是编译预览还是真实发行 | 产品负责人 + Release owner | Stage 1 做目标平台产物验收前；最迟正式发行计划前 | 未获批平台只能标为开发/预览，不能以编译或浏览器 smoke 宣称正式支持；当前明确只记录为 Unknown |
| `D-04` | 会员服务端稳定、非 PII、不可复用 user subject ID | 会员/API owner + 安全/隐私 owner | Stage 3 首个账号 key shadow migration 前 | 阻断账号 key 的 `shadowWrite/verified/committed` 和 4B session token；手机号只能由遗留 adapter 私有定位旧 key，不得进入公共 scope、事件或日志，也不得以手机号或其 hash 作为最终 scope |
| `D-05` | guest scope 生命周期，以及登录后合并/丢弃、退出后恢复策略 | 产品负责人 + 会员/API owner + 隐私 owner | Stage 3 首个 guest/账号数据迁移前 | 阻断相关 key commit 和需要合并语义的验收；非账号 key 可继续 |
| `D-06` | 当前/未来 H5 是否需要 App 登录态、SSO、持久 Cookie 或跨 MiniApp 会话 | 产品负责人 + 会员/API owner + 安全 owner | Stage 4A POC 输入；若需要宿主 token，最迟 Stage 4B 前 | 未决定时 4A 只能按无 App 会话注入实施；阻断 SSO、token 和持久会话承诺 |
| `D-07` | `xcfb.screx.com.cn:18085` HTTP 直播的 HTTPS/CDN 替代、期限和正式包资格 | 媒体服务 owner + 基础设施 owner + 安全/Release owner | 任一正式产物包含 live 前 | 阻断带 live 的正式发行/安全验收；不得把 `cleartextMediaHosts` 加入 MiniApp 信任 |
| `D-08` | 首个客户是否要求物理排除某插件、SDK、权限或代码 | 客户交付负责人 + Build/Release owner | 需求被批准时立即触发构建拓扑 ADR | 不阻断核心运行时模块化；阻断“产物不包含”声明和相应客户交付验收 |
| `D-09` | 某能力禁用后 Search/My Activity 是过滤、保留只读历史还是显示不可用 | 产品负责人 + 对应能力 owner | 迁移该能力的聚合入口前 | 阻断该垂直切片 DoD；不得留下失效可点击入口或由工程自行删除用户历史 |
| `D-10` | Stage 4B 的 H5 SDK/API、scoped-token、权限审核、审计和运行运维责任主体 | 产品负责人 + H5/API owner + App 安全 owner + 运维 owner | 首个业务 Bridge 消费者获批时 | Stage 4B 保持未触发；禁止复用当前 JavaScriptChannel 暴露业务能力 |
| `D-11` | Stage 5 配置 API、签名密钥/轮换、发布审批、回滚、监控和 on-call 责任主体 | 配置平台/API owner + 安全密钥 owner + Release/运维 owner | Stage 5 触发前 | Stage 5 保持未触发，只允许 bundled/local source；fixture 不得冒充远程能力 |
| `D-12` | `Mine` 聚合壳、认证/session、协议隐私、设置、消息、反馈各自归稳定宿主、行业核心还是独立能力 | 产品负责人 + 隐私/法务或安全 owner + Flutter 架构 owner | 首个触及这些入口的 Stage 2 切片前；最迟 Stage 3 Input | 只阻断相关跨 feature 切片、session/key 迁移和最终 import 归零；无关能力可继续。未决时保持西昌现状，不复制状态，也不默认归宿主/模块 |

## 总体验收矩阵

| 维度 | 必须满足 |
|---|---|
| 默认实例 | 西昌发布现有可见行为和本地数据保持不变，差异均有产品决定和迁移说明 |
| App 身份 | 唯一 `profileId` 解析为完整目标平台身份；显式无效客户 profile/缺失生产 profile fail closed 且不回退西昌；生产运行期不可切换，通用代码无新增客户硬编码 |
| 品牌与外观 | 名称、Logo、法务和平台元数据属于 `AppProfile` 品牌身份；用户 theme preset/accent palette 只在允许白名单内改变外观，不改变 App 身份 |
| 构建事实 | canonical `PackagedCapabilityManifest` 由构建所有并嵌入产物或与产物不可分割绑定；artifact attestation 绑定 artifact/spec/manifest、源码/profile/产品决策 digest 与 verifier version，并回读身份、依赖/SDK、权限/entitlements、网络例外、Bridge 与资源；运行时只消费该份已验证 manifest，profile 不自报物理事实 |
| 配置集合 | `defaultEnabledCapabilities ⊆ profileAllowedCapabilities ⊆ packagedCapabilities`；H5/MiniApp 同时满足 exact HTTPS origin/path、Bridge capability 和兼容版本约束 |
| 行业核心 | 首页、频道、稿件持续可用；跨 feature 协作只依赖宿主注入动作或公开契约，不导入候选能力实现文件 |
| 业务能力/交付载体 | 任一候选能力可从该 profile 的产品装配和运行时注册中省略；当前遗留原型实现不算批准，凡进入 approved set/运行装配的能力先关闭该版本 `D-01`，批准后只维护一种实现；canonical manifest 如实记录尚未物理裁剪的遗留事实但不能授予批准，载体变更必须经过新产品决策、代码迁移、测试和重新发布 |
| 核心运行时裁剪 | 未选或禁用原生能力不注册入口、Provider、状态、存储加载、订阅、后台任务或其他运行时副作用；不据此宣称 SDK/权限已物理移除 |
| 客户级物理构建 | 首个强制排除代码/插件/SDK/权限的需求触发独立构建拓扑 ADR；只有 ADR 实施且 attestation 回读通过后才允许声明“未进入该安装包” |
| 原生模块禁用 | 当前构建包含模块的入口、内部路由、Provider、状态、存储加载、订阅和后台任务均不启动 |
| H5/混合入口禁用 | 对应入口和已有外部入口映射不可用，MiniApp 不加载，Bridge capability 不授予，相关会话和缓存按策略回收 |
| Feature 边界 | 历史 32 条直接 import 为 0；覆盖 `app/core/data/domain/ui/features/shared` 的所有权表中，跨能力实现依赖、越界 re-export、共享目录绕道、未批准例外和公共插件类型泄露也均为 0；组合根只依赖公开工厂/稳定契约/具名 host adapter |
| 最小装配 | Registry 在工厂前完成冲突校验和禁用过滤；`AppShellSection` 只有真实宿主信号，跨 feature 使用窄 read-model/open-action；无通用目的地、命名路由、热卸载或生命周期框架 |
| 积分事件 | 既有六类行为通过 pending-once/幂等 `EngagementEventSink` 上报；调用方不依赖 points；points 禁用时不初始化。本地兼容 adapter 仅用于原型，正式 points 账本/规则必须由服务端所有 |
| H5 核心基线 | `ChannelH5Tab`、全部 `InAppWebPage` 及其调用链统一受 HTTPS、逐跳导航、外链、错误、数据和生命周期策略；Android/iOS POC 证明实际隔离能力，不要求业务 Bridge |
| 条件 Bridge | 当前 JavaScriptChannel 不算业务 Bridge；只有获批消费者和可信 top-frame transport 才实施，逐项授权、session/document generation、参数、token、双端限流和去敏审计有自动化覆盖 |
| 条件远程配置 | 只有正式服务/API、签名/密钥、安全和运维契约齐备才实施；signed generation 防回放、原子应用、LKG 最大陈旧期和安全回滚可验证，不能切换载体 |
| 存储 | App 之间由平台沙箱隔离；App 内 opaque account/guest scope 与模块命名空间明确；高风险 key family 的 shadow/commit/rollback 可恢复，低风险偏好有版本化读回/fallback/清理闸门，旧数据不被半迁移破坏 |
| 平台范围 | Android/iOS 正式发行与 macOS/Web 预览或发行以 `D-03` 为准；预览编译、Web 浏览器 smoke 或移动 POC 不能替代对应平台正式产物验收 |
| 质量 | Flutter 代码阶段通过格式化、静态分析和相关/完整测试；移动 WebView/模块启停在获批 Android/iOS 目标做原生 smoke，可见 Web 预览使用浏览器 smoke，但只声明其真实覆盖范围 |

## 风险与控制

| 风险 | 控制措施 |
|---|---|
| 模块化同时改变 UI 行为 | 每阶段以默认西昌实例为回归基线，结构迁移与产品改版分开提交 |
| 隐藏入口但后台仍运行 | 以注册表创建边界为准，测试 Provider、订阅、播放器和后台任务未实例化 |
| Registry 先执行工厂再过滤 | 静态描述先做 ID 冲突/集合校验和禁用过滤；工厂只在已启用模块首次真实消费时原子调用 |
| 把运行时禁用误当成 SDK/权限物理裁剪 | 分开验收运行时无副作用与客户级物理构建；首个强制排除需求触发构建 ADR 和产物检查 |
| 在确认客户需要前就把候选能力统一实现为原生 | 先确认业务必要性，再依据非约束选择因素形成 `D-01` 的版本化批准；构建清单和运行配置分层 |
| `AppProfile` 变成无边界万能配置 | 固定 schema 和所有权，只放构建/发行身份、品牌、法律信息、默认能力及安全上限 |
| 无效客户 profile 静默变成西昌 | 唯一 resolver 对显式无效/缺失生产 profile fail closed，artifact verifier 回读平台身份 |
| 手写 `packagedCapabilities`、孤立 sidecar 与产物漂移 | canonical manifest 由构建所有并与产物不可分割绑定；verifier 同时验证 artifact/spec/manifest，attestation 绑定三者 digest，运行时拒绝其他来源 |
| 远程配置扩大原生权限或被旧包重放 | 安装包能力清单是硬上限；签名 envelope、单调 generation、安全 high-water mark 和冷热边界共同限制 |
| 在正式服务和运维责任缺失时把 fixture 当作远程配置完成 | 核心只交付 bundled/local source 与可替换接口；阶段 5 满足触发条件后才实施远程生命周期 |
| H5 Bridge 泄露会话或设备能力 | 不把当前 JavaScriptChannel 当业务 Bridge；触发后证明 top-frame transport，并使用 scoped token、document/session generation、逐项授权、双端限流和去敏审计 |
| 拆分积分状态后其他能力仍直接调用 points | 先引入类型明确的 `EngagementEventSink` 和旧逻辑适配器；禁用 points 时使用 no-op 或不装配实现 |
| 32 条归零但仍经 shared/data/core 绕道依赖候选能力 | 另设全目录所有权表与 import/export/public-type 检查；首切片和 Stage 3 分别要求语义违规归零 |
| 状态拆分丢失历史数据 | 兼容读、验证写、版本化 key、回滚窗口和迁移 fixture 测试 |
| WebView 宣称按 MiniApp 隔离但平台只支持全局清理 | Stage 4A 前做 Android/iOS POC；承诺按真实 data store 能力收缩，不满足则独立 origin、全局清理或关闭入口 |
| 大规模移动导致 review 失真 | 先建立契约和装配点，再按模块小批迁移，不先重排全部目录 |
| 为假设中的多载体切换提前建设通用目的地系统 | 先为每项能力选定唯一实现，以最小入口和类型明确回调装配；真实触发条件出现后再通过 ADR 演进 |
| 多客户需求污染行业核心 | 新需求先判断属于宿主、行业核心还是可选业务能力，再为已选能力确定唯一的原生、H5、混合或受控外部实现 |

## 非目标

本计划明确不包含：

- 不先大规模移动现有目录。
- 不引入动态 Dart、脚本解释器或远程代码执行。
- 不把所有页面改为 H5；高频、强交互、媒体播放和系统能力优先保留原生。
- 不立即拆成多个 Dart/Flutter package。
- 不在首个物理排除需求前决定 flavor、多 package 或独立 app target 拓扑；但不推迟唯一构建输入、平台身份、capability ID、产物输出和验证接口。
- 不建设通用 `AppDestination`、通用深链分发或命名路由；不迁移到 `go_router` 或其他路由框架。
- 不在没有契约的情况下接入真实 CMS、会员、支付、短信、推送或第三方登录。
- 不把当前静态 `PageBlock`、Repository fixture 或 `RemoteAppConfig` 草案直接当作后台正式 API。
- 不在本阶段改动 `admin9-app-admin`、`admin9-app-uniapp` 或工作区级交付边界。

## 每阶段交付纪律

- 每阶段先列出默认西昌实例行为清单和涉及的存储 key，再开始代码修改。
- 多人或多任务并行前先拆清文件和模块所有权，不并行修改应用装配、全局状态等共享入口。
- 优先新增契约和测试，再迁移一个最小垂直切片；禁止同时重写导航、状态、存储和页面视觉。
- 跨端正式业务 API、Admin 配置器、生产凭据、第三方 SDK 接入、多客户商店发行和应用商店审核不属于核心迁移阶段验收；但构建选择、签名策略引用、目标平台身份、产物 attestation 接口和 fail-closed 行为属于 Stage 1，不得一并后置。
- 提交保持单一目的，结构迁移与产品行为变化分离。
- Flutter 代码阶段至少执行 `dart format --output=none --set-exit-if-changed lib test`、`flutter analyze`、相关定向测试和完整 `flutter test`。
- 涉及可见 UI、H5 或模块启停时，补充默认西昌构建与至少一个测试 profile 的真实目标平台 smoke。H5/WebView 验收使用 Android/iOS 原生载体；Flutter Web 或 macOS 只按 `D-03` 已批准的预览/发行范围声明结果，浏览器预览不能替代移动 WebView 行为。
- 每阶段完成后更新本文状态、已知风险和下一阶段入口条件。
