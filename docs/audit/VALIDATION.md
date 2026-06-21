# 审计文档验证裁决

> 验证时间：2026-06-16
> 验证对象：`docs/audit/` 全量与增量审计文档
> 验证方式：OMX team `validate-docs-audit-f-60bf5ebb`，5 个 verifier lane（事实核对、runtime、测试、架构、code-review）
> 代码范围：仅验证 `admin9-app-flutter/` 与 `admin9-app-flutter/docs/audit/`，未修改 Flutter 源码

## 验证结论

`docs/audit/` 的审计方向整体有价值，但不能直接作为最终修复清单使用。部分条目存在统计过期、行号过期、严重度夸大、验证文字与当前代码不一致的问题。后续排期和修复优先级以本文为准；原审计文档保留为历史审计输入。

## 必须修复（keep / must-fix）

| 问题 | 验证后裁决 | 依据 |
|---|---|---|
| `LiveStreamPlayer` 的 `Uri.parse()` 在 `try/catch` 外 | 保留，必须修 | `live_stream_player.dart` 中 URL 解析和 controller 构造发生在 `try` 之前，坏 URL 会绕过 `_error` 状态并抛出同步异常。 |
| `LiveStreamPlayer` 异步初始化缺 cancellation/generation guard | 保留，必须修 | builder 切换、dispose/reinit 期间可能创建后续不再渲染的 controller，风险集中在真实 `video_player` 生命周期。 |
| 底部 `IndexedStack` 隐藏 Tab 仍可能保留直播播放器 | 保留，生产化前必须修 | `admin9_shell.dart` 的 `IndexedStack` 保持 5 个顶层页 mounted；登录态 TV 直播预览会创建并 autoplay 默认播放器。 |

## 建议修复（keep / should-fix）

| 问题 | 验证后裁决 | 依据 |
|---|---|---|
| `QuickActionGrid` 网络图标缺 `cacheWidth/cacheHeight` | 保留但降级 | 44x44 图标使用 `Image.network`，事实成立；未提供 OOM、jank 或源图尺寸证据，不应标 critical。 |
| `MediaCover` 网络图缺 cache sizing | 保留但降级/按画像合同评估 | 缩略图场景事实成立，但同 URL 在详情页复用时可能需要更大解码尺寸，建议结合图片服务尺寸策略处理。 |
| `SpecialEntryCarousel` 缺描述性语义标签 | 保留但降级 | tappable hero 视觉 label 被隐藏，链路中未见 `Semantics`/`semanticLabel`；但“完全不可发现”的表述偏重。 |
| TV 直播详情 chat/input 是装饰性 UI | 保留但降级 | 静态消息、空 like 回调、无 controller/submission 的输入框是原型 scaffolding；产品化前需禁用标识或接入逻辑。 |
| `LiveStreamPlayer` 真实生命周期测试不足 | 保留 | 现有测试多使用 fake stream builder，不能覆盖真实 `VideoPlayerController` init/error/dispose。 |
| `LiveRepository` 数据完整性测试不足 | 保留 | 当前直接测试偏少，只有轻量数量检查，不覆盖频道/节目/URL 数据一致性。 |
| `ContentReportPage` 无测试 | 保留但低优先级 | 当前确实缺直接测试，但页面逻辑简单，风险低。 |

## 延期、降级或驳回（downgrade / defer / refute / stale）

| 原条目 | 验证后裁决 | 说明 |
|---|---|---|
| i18n 缺失标为 critical | 降级/延期 | 缺 `.arb`、`flutter_localizations` 等事实成立；但当前是中文静态原型，非生产多语言要求。 |
| `ServiceApplyPage has zero tests` | stale/refuted | 当前 `widget_test.dart` 已覆盖服务申请页和 `ServiceTargetType.internalPage` 路径。 |
| `activity_list_page.dart` 无 live import | refuted | 当前 `mine/views/activity_list_page.dart` 确实 import/use `live_detail_page.dart`。 |
| `ArticleContentTag` 无中文 label | stale/refuted | 当前 `domain/models/article.dart` 已定义中文 label。 |
| radio 子 Tab 首次就一定初始化播放器 | partial/refuted | 直播内部子 Tab 使用 `TabBarView`，未证明 inactive radio tab 首次构建即初始化播放器。 |
| “6 个 near-identical gradients” | partial/downgrade | 只有部分 gradient 匹配相同模式，其余用途/颜色结构不同。 |
| `LiveRepository` hardcoded mock/HTTP URL | defer | 静态原型边界内可接受；进入真实数据源/生产播放链路前再改。 |
| `_clampInt().toInt()`、`serviceQuickActionItems` public | defer | 事实成立但仅属低风险清理。 |

## 文档本身需要修正的过期点

- `INDEX.md` 原始范围写 `99 个 .dart 源文件 + 2 个测试文件`；复核时当前为 `lib` 103 个 Dart 文件、`test` 2 个 Dart 文件，排除 `.dart_tool`/`build` 后 app 合计 105 个 Dart 文件。
- `INDEX-INCREMENTAL.md` 写 `f753d6c..749489e` 为 7 commits；复核命令 `git rev-list --count f753d6c..749489e` 为 8。
- `code-quality.md` 中 `services_page.dart:444` 行号过期；当前 `serviceQuickActionItems` 在 `services_page.dart:326-340` 附近。
- `test-coverage.md` 的 `AppearancePage` 验证段落混入了 QuickActionGrid/ServiceNavigation 的重构审查内容，主题不匹配。

## 验证命令证据

- `cd admin9-app-flutter && flutter analyze`：通过，`No issues found`。
- `cd admin9-app-flutter && flutter test`：通过，207 tests。
- worker 补充覆盖率：`flutter test --coverage` 通过，LCOV 约 87.30%。
- 文档编辑范围：仅 `docs/audit/`。

## 使用规则

1. 后续修复优先级以本文为准。
2. 原 `INDEX.md` / `INDEX-INCREMENTAL.md` 保留原审计统计与发现数量，用于追溯 finder/verify 过程。
3. 当原审计条目的严重度、行号或裁决与本文冲突时，以本文的验证后裁决为准。

## 2026-06-17 修复状态更新

> 执行范围：仅 `admin9-app-flutter/` 与本文档状态追加；未触碰 `admin9-app-admin/backend`、`admin9-app-admin/frontend`，未新增 public/mobile/backend API，未重开真实上传、真实聊天、真实直播 API 或 i18n 基础设施。

### 已完成修复

- `LiveStreamPlayer`：将 `Uri.parse()` 与 `VideoPlayerController.networkUrl` 构造纳入错误处理链路；坏 URL / 构造异常进入组件内错误兜底与“重试”，不再同步逃逸。
- `LiveStreamPlayer`：增加 generation/cancellation guard；URL 切换、builder 切换、dispose/reinit、初始化失败路径均会丢弃 stale completion 并释放过期 controller。
- 底部 `IndexedStack`：保留页面状态，但由 `Admin9Shell` 向 `LivePage` 传入 active playback gate；隐藏直播 Tab 时 TV / radio 播放器不实例化、不播放。
- `QuickActionGrid`：网络图标按 44x44 逻辑尺寸与当前 DPR 设置 `cacheWidth/cacheHeight`。
- `MediaCover`：网络图仅在有限渲染约束下按实际展示尺寸与 DPR 设置 cache sizing；无界约束不强行降采样，避免同 URL 大图复用清晰度风险。
- `SpecialEntryCarousel`：补充明确 `Semantics(button: true, label: ...)`，包含当前专题标题与位置提示。
- TV 直播详情：聊天室明确标注“互动功能即将开放，当前仅展示模拟评论”；输入框只读，点赞按钮禁用并标注 coming soon；未接入真实聊天。
- 低风险清理：移除 `_clampInt().toInt()` 冗余调用；`serviceQuickActionItems` 可见性保持 defer，不在本轮扩大 diff。

### 新增 / 补强测试

- `test/live_stream_player_test.dart`：覆盖坏 URL、controller 构造异常、URL 切换 stale init、builder 切换取消、dispose during init、初始化失败释放与错误 UI。
- `test/live_playback_gate_test.dart`：覆盖登录后隐藏直播 Tab 不构建播放器、进入直播 Tab 才构建、切走后隐藏播放器。
- `test/audit_ui_quality_test.dart`：覆盖 QuickActionGrid cache sizing、MediaCover cache sizing、SpecialEntryCarousel semantics、TV 详情只读/coming soon UI。
- `test/live_repository_test.dart`：覆盖直播静态数据数量、唯一 ID、非空字段、TV/radio URL 可解析、节目单与互动直播 label/kind 一致性。
- `test/content_report_page_test.dart`：覆盖举报页渲染、原因切换、补充说明、提交 snackbar 与返回。
- `test/widget_test.dart`：同步既有 QuickActionGrid 网络图断言以接受 `ResizeImage` 包装。

### 验证命令证据

- `cd admin9-app-flutter && flutter analyze`：通过，`No issues found!`。
- `cd admin9-app-flutter && flutter test`：通过，`All tests passed!`，当前 220 tests。
- `cd admin9-app-flutter && flutter test test/live_stream_player_test.dart test/live_repository_test.dart test/content_report_page_test.dart test/live_playback_gate_test.dart test/audit_ui_quality_test.dart`：通过，13 个 targeted tests。

### 保留裁决

本文上方 `延期、降级或驳回（downgrade / defer / refute / stale）` 表保持原裁决：i18n、大规模 live 页面拆分、后端/真实 API/真实上传/真实聊天、设备 profiling / 图片服务尺寸合同相关优化，以及 stale/refuted 条目均未作为本轮必须修复项处理。
