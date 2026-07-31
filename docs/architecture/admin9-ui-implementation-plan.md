# Admin9 Design System Flutter 实施计划

> 状态：v1.2 下游实施基线；Phase 0D-6 已实施并通过验收
> 版本：v1.2
> 建立日期：2026-07-29
> 修订日期：2026-07-31
> 适用范围：Admin9 App Foundation Flutter（Android / iOS）
> SDK 基线：Flutter 3.44.1、Dart 3.12.1、Android min SDK 24 / target SDK 36、iOS 13.0

## 1. 文档目的与授权边界

本文是 [Admin9 Design System v1.0.2](../design-system/README.md) 的下游 Flutter 实施计划。Design System 决定产品语义、Token、平台映射、公共合同和质量门禁；本文只决定在当前 Foundation 中如何分阶段实现。两者冲突时以 Design System v1.0.2 为准，本文不得成为竞争规范来源。

本文已经关闭首期架构和产品表现的选择题。实施者不得在 feature 页面自行改用另一套 Material、Cupertino、自绘控件、路由转场、反馈形式或页面容器。发现 Flutter SDK 限制时，应先记录复现、影响范围和候选修正，经计划变更评审后再调整本基线。

本文本身不构成新的运行时修改授权。Phase 0D-6 已在明确 Goal 内完成；任何新增产品能力、依赖、后端、假会话、push、发布或部署仍需单独授权。

## 2. 固定架构决策

1. 整套体系命名为 **Admin9 Design System**；“Admin9 UI”仅指其 Flutter 实现层，公共组件继续使用 `App*` 命名。
2. 应用根节点固定使用 `MaterialApp`，不切换为 `CupertinoApp`，也不按平台维护两棵应用树。
3. Android 交互控件使用 Material 3；iOS 交互控件使用 Flutter Cupertino 控件。品牌颜色、内容层级和业务语义保持一致，平台手势、控件结构、系统反馈和导航行为保持原生。
4. 平台分支只存在于 Admin9 UI、主题桥接和 App Shell。feature 页面不得使用 `Platform.isIOS`，也不得直接选择 Material/Cupertino 实现。
5. 页面路由固定保留 `MaterialPageRoute` 与 Flutter 默认 `PageTransitionsTheme`。首期不创建自定义路由类。
6. 不引入 `flutter_platform_widgets` 等全局第三方 UI 套件。图表、富文本和媒体能力按独立需求评估。
7. Core 实现固定保留在当前应用仓库的 `lib/core/design_system/`，只经 `lib/admin9_ui.dart` 导出；品牌只经 `lib/app/brand/app_brand_theme.dart` 输入。首期不拆独立 package。
8. 只封装具有平台差异、统一状态、无障碍或稳定复用价值的组件，不包装 `Row`、`Column`、`Text`、`Icon`、`Padding`、`SizedBox`、`Expanded` 和 `Flexible`。
9. App Shell 固定持有一级导航、Tab 页面实例和页面保活；各 feature 固定持有本页滚动控制器、表单状态、业务状态和页面级资源。只有真实资源 owner 才观察系统生命周期；当前无后台资源的 Foundation 不创建空转全局 controller。公共组件只接收值、展示数据和回调。
10. 媒体、频道、直播、积分、客户身份、Logo、法务资料和构建配置不进入 Admin9 UI。
11. v1.2 首期只支持中文简体界面，固定配置 `zh_CN` 和 Flutter 的 Material、Cupertino、Widgets 本地化代理；日期、时间和 24 小时制尊重系统设置。
12. 首期不启用 Android 动态颜色。两端使用 Design System 默认语义主题；派生项目只可通过 Brand Theme 覆盖已批准的 primary/secondary 对、品牌资产、批准字体和受限圆角性格。

## 3. 产品视觉基线

### 3.1 视觉气质

Admin9 是通用业务 App 骨架，视觉固定为安静、清晰、克制、适合重复操作的信息界面。首期不使用装饰渐变、玻璃拟态、悬浮大卡片、营销式大标题和无业务含义的动效。

Android 保留 Material 3 的状态层、波纹、NavigationBar 和标准表单行为；iOS 保留 Cupertino 的导航栏、Tab Bar、按压反馈、弹层结构和边缘返回。不得通过给 Material 控件换颜色来冒充 iOS 适配。

### 3.2 颜色

颜色角色、默认浅深色值、对比度与 Brand 覆盖边界只以 [Foundations](../design-system/01-foundations.md#ds-clr-001) 为准。旧 `ColorScheme.fromSeed(#263238)`、旧 warning/info 配对和固定 Admin9 客户品牌色已废弃。实现可用 `ColorScheme` 作为 Flutter 载体，但不得让 seed 推导结果覆盖已冻结语义角色。

### 3.3 字体、间距、圆角与密度

- 两个平台都使用系统字体，不引入字体文件，不强制 `.AppleSystemUIFont`。
- 文字语义以 `TextTheme` 为公共入口；Cupertino 组件从相同语义角色生成 `cupertinoOverrideTheme`，业务页面不写平台字号。
- Core 间距刻度固定为 `4 / 8 / 12 / 16 / 24 / 32 / 48`；390lp 页面内边距 `20` 是页面测量，不是可复用 Token。
- 输入框/inline notice 圆角为 `6`，按钮/Dialog/sheet/Android 分组面圆角为 `8`；iOS 分组列表使用系统形状。
- 页面水平内边距：320/360 为 `16`、390 为 `20`、600 为 `24`；可读内容最大宽度 `640`，表单最大宽度 `480`。
- 控件只设 minimum constraints 并按内容增长。按钮与输入框不要求等高；列表与底栏不得使用通用固定 56/72 高度。
- Android hit bounds 至少 `48 x 48dp`，iOS 至少 `44 x 44pt`；visual bounds 与 hit bounds 分别测量。

### 3.4 响应式范围

首期 Widget 窗口固定覆盖 320/360/390/600 logical pixels 和手机横屏；真实设备只记录实际型号、runtime/API 与逻辑宽度。组件不得依赖固定屏幕宽度；空间不足时尾值先下移、横排转纵排、页面保持可滚动，文字不得缩小。完整组合只使用 [A-L 唯一自动化矩阵](../design-system/06-accessibility-quality.md#ds-rsp-001)。

### 3.5 动效

- 自定义动效只使用 `instant 0ms`、`state 120ms easeOutCubic`、`enter 200ms easeOutCubic`、`exit 160ms easeInCubic`。
- 有效减少动态效果开启时，非导航 state/enter/exit 变为 `0ms`。
- 页面转场不读取上述 Token，始终使用 Flutter 的平台默认 builder 和时长。
- 首期不实现弹跳、弹性、循环缩放、Hero 和视差自定义动画。

## 4. 目标结构与公共 API

```text
lib/
├── admin9_ui.dart
├── app/
│   └── brand/
│       └── app_brand_theme.dart
├── core/
│   └── design_system/
│       ├── foundations/
│       ├── platform/
│       └── components/
│       ├── app_button.dart
│       ├── app_switch.dart
│       ├── app_dialog.dart
│       ├── app_text_field.dart
│       ├── app_segmented_control.dart
│       ├── app_select.dart
│       ├── app_list_tile.dart
│       ├── app_section.dart
│       ├── app_notice.dart
│       ├── app_feedback.dart
│       ├── app_page.dart
│       ├── app_bottom_navigation.dart
│       ├── app_action_menu.dart
│       ├── app_progress_indicator.dart
│       └── internal/
│           └── app_platform_icons.dart
└── debug/
    └── admin9_ui_gallery_page.dart
```

`lib/admin9_ui.dart` 是 feature 唯一允许导入的 Admin9 UI 出口，只导出稳定组件、公共枚举、只读 Token，以及 `AppThemePreference`、`AppFontScale`、`AppAppearance`、`AppAppearanceController` 外观偏好合同。它不导出 `ThemeMode` 映射、系统偏好合并、`AppTextScaler`、持久化实现、Gallery、平台图标表、主题构建器内部实现和迁移兼容层。

`BrandMark` 继续属于应用 branding 层，不从 `admin9_ui.dart` 导出。`AppNotice` 只接收调用方文案和 tone，不内置“服务尚未接入”等业务文字。

Phase 1 必须增加 analyzer AST 导入边界测试及正反 fixtures：公共出口、feature 禁止直引 Core、feature 禁止自行选择 Material/Cupertino 交互控件、Core 禁止依赖业务层、跨 feature 禁止实现文件引用。纯文本 `rg` 只能辅助排查，不作为硬门禁。

## 5. 固定平台组件映射

平台识别固定使用 `Theme.of(context).platform`。下表是首期唯一实现映射：

| Admin9 能力 | Android 实现 | iOS 实现 | 固定行为 |
| --- | --- | --- | --- |
| `AppButton.primary` | `FilledButton` | `CupertinoButton.filled` | 单次提交、加载时禁用并保留尺寸 |
| `AppButton.secondary` | `OutlinedButton` | `CupertinoButton.tinted` | 不使用 elevation |
| `AppButton.tertiary` | `TextButton` | `CupertinoButton` | 只用于低优先级命令 |
| `AppButton.destructive` | error 配色 `FilledButton` | destructive red `CupertinoButton` | 必须由确认流程保护不可逆操作 |
| `AppSwitch` | Material `Switch` | `CupertinoSwitch` | 受控值，禁用态不触发回调 |
| `AppDialog` | `AlertDialog` | `CupertinoAlertDialog` | 信息型 1 个动作；确认型固定取消和确认 2 个动作 |
| `AppTextField` | `TextFormField` | `FormField<String>` 桥接 `CupertinoTextField` | 统一 controller、focus、validator、autofill、错误语义 |
| `AppSegmentedControl` | `SegmentedButton<T>` | `CupertinoSlidingSegmentedControl<T>` | 2 至 5 项、单选、即时生效 |
| `AppSelect` | `DropdownMenuFormField<T>` | `FormField<T>` 桥接 `showCupertinoModalPopup` + `CupertinoPicker` | 仅处理 2 至 20 个无需搜索的单选项 |
| `AppSingleChoiceList<T>` | `RadioGroup<T>` + `RadioListTile<T>` | 推入带 checkmark 与 selected trait 的列表 | 设置页主题/字号唯一映射；即时提交，用户主动返回 |
| `AppListTile` | `ListTile` | `CupertinoListTile` | 平台原生按压反馈和尾部箭头 |
| `AppSection` | `Column` + section title + unframed children + row `Divider` | `CupertinoListSection.insetGrouped` | 只负责标题、footer 和 children |
| `AppPage` | `Scaffold` + `AppBar` | `CupertinoPageScaffold` + `CupertinoNavigationBar` | 标题栏固定使用平台原生结构 |
| `AppBottomNavigation` | `NavigationBar` | `CupertinoTabBar` | Shell 持有 index 和页面实例；资源 owner 持有所需生命周期 |
| `AppFeedback` | 瞬时态固定使用 `SnackBar`；持久态固定使用 `MaterialBanner` | 顶部 `OverlayEntry` 通知条；持久态增加关闭控件 | 无操作且未启用无障碍导航时 info/success 3 秒、warning/error 5 秒；其余情况持久显示并即时公告 |
| `AppActionMenu<T>` | Material modal bottom sheet | `CupertinoActionSheet` | 只用于 2 至 6 个离散命令，不承担字段/设置选择；取消不提交 |
| `AppProgressIndicator` | `CircularProgressIndicator` / `LinearProgressIndicator` | 未知进度使用 `CupertinoActivityIndicator`，确定进度使用 Core semantic bar | 必须有可读标签；确定值为 0...1；不伪造百分比 |
| Checkbox | Material `Checkbox` | `CupertinoCheckbox` | 出现首个真实消费者后进入公共层 |
| 日期选择 | `showDatePicker` | modal popup + `CupertinoDatePicker` | iOS 固定取消/完成；尊重 locale 和系统制式 |
| 页面路由 | `MaterialPageRoute` 默认 Android builder | `MaterialPageRoute` 默认 Cupertino builder | 禁止替换默认 builder 破坏返回手势 |

`AppSelect` 的取消和提交规则固定如下：Android 选择后立即提交；iOS 滚轮先写临时值，点“完成”后只回调一次，点“取消”不回调。超过 20 项、需要搜索、远程加载或多选的场景固定使用独立选择页面，不扩张 `AppSelect`。

平台通用品牌组件固定为 `AppNotice`、空状态和业务卡片；它们在两端使用相同结构，只由主题提供平台适配后的字体和颜色。

系统语义图标只采用 [Design System 权威映射表](../design-system/02-platform-adaptation.md#21-authoritative-icon-mapping)。`home/homeSelected` 与 `account/accountSelected` 是不同角色，由 `AppBottomNavigation` 按当前 index 选择。业务品牌图标和内容图标保持跨平台一致；feature 页面不得自行替换系统语义图标。

## 6. Token 与主题所有权

Token 采用三类所有权，具体值只引用 Design System Foundations，不在本文复制第二套数值：

1. Primitive：原始颜色、间距和圆角刻度，仅供主题实现内部使用。
2. Semantic：`ColorScheme`、`TextTheme`、`warning`、`info` 和动效语义，是公共组件的主要输入。
3. Component/platform：Android 度量写入 `NavigationBarThemeData`、`FilledButtonThemeData`、`OutlinedButtonThemeData`、`TextButtonThemeData`、`InputDecorationTheme`、`DialogThemeData` 和 `DividerThemeData`；Cupertino 与 Admin9 自定义度量写入对应组件实现文件，不开放给 feature 覆盖。

固定消费顺序为：Core primitive → Admin9 semantic roles → component/platform resolution。Flutter `ColorScheme`、`TextTheme`、`ThemeExtension` 和 `CupertinoThemeData` 是实现载体，不是 feature 逃生口。只读 `AppDesignTokens` facade 的查找机制在 Phase 0D 以真实实现 probe 冻结，不预先伪造 static method。

Cupertino 主题固定从同一套 semantic Token 生成 `cupertinoOverrideTheme`，映射 `brightness`、`primaryColor`、`primaryContrastingColor`、`scaffoldBackgroundColor`、`barBackgroundColor`、`selectionHandleColor` 和 `textTheme`。iOS 保留 Cupertino 的禁用交互行为，但最终禁用前景与容器必须解析 Design System `disabled` semantic roles，并对实际合成背景重新验证 4.5:1/3:1 门禁；不得直接固定 `CupertinoColors.inactiveGray` 或由组件接收硬编码颜色。

## 7. 无障碍与系统偏好

### 7.1 有效设置合并

- 有效高对比度固定为 `MediaQuery.highContrast OR AppAppearance.highContrast`。
- 有效减少动态效果固定为 `MediaQuery.disableAnimations OR AppAppearance.reduceMotion`。
- 主题模式继续由 `AppThemePreference.system/light/dark` 控制。
- 灰度只由 App 内偏好控制。
- 系统辅助功能在运行期间变化时，主题和组件必须立即重建，不要求重启 App。

实现固定在 `MaterialApp.builder` 内读取 `MediaQuery`，生成不可持久化的 `EffectiveAppearance`，再用包含 `cupertinoOverrideTheme` 的 `ThemeData` 包住 Navigator child。亮度取 `MaterialApp` 已按 `themeMode` 选中的 ambient `ThemeData.brightness`；高对比度和减少动态效果按上面的 OR 规则合并。系统派生值不得写回 `SharedPreferences`。

### 7.2 字体缩放

系统 `TextScaler` 是基础，App 字号固定为 Standard `1.00`、Large `1.12`、Extra Large `1.24`。解析公式为 `systemTextScaler.scale(baseSize) * appFactor`，删除当前 `2.0` 硬上限，不对组合结果设置最大值。静态视觉证据只证明系统标准字号乘 `1.24`；A-L Widget 矩阵证明合成与压力布局，Android 200% 和 iOS 最大 Dynamic Type 仍由真实设备验收。

### 7.3 减少动态效果与返回手势

减少动态效果开启时：

- 主题切换和非必要组件动画使用 `Duration.zero`。
- 加载、进度和焦点反馈继续显示，但不使用循环缩放、弹跳和大范围位移。
- `PageTransitionsTheme` 保持 Flutter 默认配置。不得再使用返回 `child` 的 `_NoTransitionBuilder` 替换 Android/iOS builder。
- iOS 边缘返回和 Android 预测性返回的开始、进度、取消、完成必须继续工作。

保留默认路由动画是首期固定取舍：它避免移除 Cupertino 边缘手势检测器和 Android predictive-back observer。Flutter 后续若提供官方的 gesture-preserving reduced-motion builder，再通过单独计划变更评估。

### 7.4 量化标准

- Android 可操作目标至少 `48 x 48dp`；iOS 原生控件至少 `44 x 44pt`；共享自绘控件至少 `48 x 48` logical pixels。
- 普通文字对比度至少 `4.5:1`；不小于 `24` logical pixels 的常规字重文字、不小于 `18.5` logical pixels 的粗体文字、焦点指示、控件边界和关键非文本元素至少 `3:1`。
- 错误、危险、选中和禁用状态不得只依赖颜色区分。
- 所有交互组件必须提供名称、角色、当前值或状态以及可执行动作。
- 加载和提交结果固定使用 `Semantics(liveRegion: true)` 公告，不能造成重复播报。
- Dialog 打开后焦点进入 Dialog，关闭后回到触发控件；表单提交失败后聚焦首个错误字段。

## 8. 公共组件契约

公开名称、精确构造参数、泛型、nullability、`Key`、回调和状态所有权以 [Design System 组件规范](../design-system/03-components.md#ds-cmp-001) 与非导出的 [`design_system_contract_probe.dart`](../../tool/design_system/design_system_contract_probe.dart) 为唯一合同。Phase 0D 实现不得改名、合并成任意 `child/style` 逃生口或重新开放产品选择；任何签名变化必须先做版本化 Design System 变更并让 probe 通过。

| 组件 | 必需输入与状态 | 固定约束 |
| --- | --- | --- |
| `AppPage` / `AppPageAction` | title/body/navigationMode/actions/parentLabel/scrollable | root 禁止 back 且 parentLabel 为空；child 要求非空 parentLabel；Core 持有 page bar、安全区与滚动合同 |
| `AppBottomNavigation` / `AppNavigationDestination` | destinations/selectedIndex/onDestinationSelected | Shell 持有 index 和页面；底栏只渲染与单次回调 |
| `AppButton` | label/onPressed/variant/icon/enabled/loading | caller 持有任务幂等和 loading 迁移；Core 在 disabled/loading 时不派发，每次激活最多一次 |
| `AppTextField` | controller/label/focus/validator/error/input/autofill/password/callback/icon | Business 持有文本、焦点、校验与提交；Core 只持有密码可见展示态 |
| `AppSelect<T extends Object>` | label/value/options/onChanged/enabled/validator/error | 2-20 项字段选择；iOS Cancel 不提交，Done 回调一次；无搜索/远程/多选 |
| `AppSegmentedControl<T extends Object>` | value/options/onChanged/enabled | 2-5 个短同级模式；不承载设置、导航或主行动 |
| `AppSingleChoiceList<T extends Object>` | title/value/choices/onChanged/enabled | 设置主题/字号；Android radio、iOS checkmark；选择即时提交 |
| `AppSwitch` | label/value/onChanged/enabled | caller 持有 App 偏好；整行与开关一个语义动作，不双触发 |
| `AppListTile` | title/subtitle/icon/currentValue/onTap/states/disclosure | 尾值受压下移；导航 disclosure 由 Core 决定；不开放任意 trailing Widget；不承载业务分组 |
| `AppSection` | title/footer/children | 页面持有顺序；无嵌套 Card，无业务状态 |
| `AppNotice` | tone/title/message/action pair | Business 决定状态与文案；Core 只呈现 inline 状态，不替 Business 判成功 |
| `AppFeedback` / controller/request | message/tone/action pair | App root 单一 owner；无 action 且非 accessible navigation 时 3s/5s，否则持久；关闭、替换、公告按 DS-FBK-001 |
| `AppDialog` / controller | `showInformation(title,message)`、`showConfirmation(title,message,confirmLabel)`、`showDestructive(title,message,confirmLabel)` | Business 只经 controller 请求并等待 `Future<void/bool>`；Core 内部持有 Widget、平台呈现和焦点；取消返回 `false`，不可逆操作不可遮罩关闭 |
| `AppActionMenu<T>` / item / controller | `showActionMenu<T>(title,items,cancelLabel)` | Business 等待 `Future<T?>`；2-6 命令，取消/系统关闭返回 `null`，一次选择最多返回一个非空值；不承担字段选择 |
| `AppProgressIndicator` | label/kind/value | `null` 为未知，0...1 为确定；Business 持有真实进度，Core 持有渲染/Semantics |
| `AppIconRole` | 跨平台语义枚举 | 仅含 back/close/chevronForward/home/homeSelected/account/accountSelected/settings/search/info/warning/success/error/visibility/visibilityOff/more；不暴露 `IconData` |

`forceErrorText` 非空时优先于 `validator`，直到 Business 在输入变化后显式清除。`AppFeedback` 的持久谓词为 action 存在或 `MediaQuery.accessibleNavigationOf(context)`；读屏设备必须实测该平台信号，无法证明时该设备门禁为 Unknown。新消息原子替换旧消息、取消旧 timer、保持焦点并只公告新消息一次。所有公共组件不得依赖 Provider、业务 ViewModel、实体、Repository 或服务。

Dialog、ActionMenu 与 Feedback 的呈现入口分别由 `AppInteractionController` 和 `AppFeedbackController` 持有。information 返回 `Future<void>`，confirmation/destructive 返回 `Future<bool>`，所有取消路径返回 `false`；action menu 返回选择值或 `null`。关闭后恢复原焦点。Phase 0D 只可实现该已冻结合同，不得让 feature 直接持有 `BuildContext` 选择平台弹层。

## 9. 组件批次与现有迁移

### 9.1 实施批次

首批平台骨架：

- `AppPage`
- `AppBottomNavigation`
- `AppListTile`
- `AppSection`
- `AppSwitch`
- `AppSingleChoiceList`
- `AppFeedback`
- `AppProgressIndicator`
- 内部平台图标映射

第二批通用操作：

- `AppButton`
- `AppDialog`
- `AppTextField`
- `AppNotice`
- `AppActionMenu`

`AppSelect` 与 `AppSegmentedControl` 合同已冻结，但没有当前消费者；出现真实消费者时在同一变更中实现、补 Gallery/测试/设备证据。之后仍只按真实消费者增加 Checkbox、DatePicker、Empty、Result、Tag、Avatar、文件选择、图片选择、图表和富文本适配器。

### 9.2 迁移表

| 当前实现 | 固定目标 |
| --- | --- |
| `FoundationPage` | `AppPage` |
| `SettingsSection` | `AppSection` |
| `UnavailableNotice` | `AppNotice`，业务文案移回 feature |
| `FilledButton` / `OutlinedButton` / `TextButton` | 对应 variant 的 `AppButton` |
| `SwitchListTile` | 单一 `AppSwitch` 行；标签、状态和点击由一个语义动作承载，不与 `AppListTile` 嵌套 |
| `TextFormField` | `AppTextField` |
| `SegmentedButton` | `AppSegmentedControl` |
| `DropdownButton` | `AppSelect` |
| `NavigationBar` | `AppBottomNavigation` |
| `SnackBar` | `AppFeedback` |
| 离散操作 bottom sheet / action sheet | `AppActionMenu` |
| `CircularProgressIndicator` / `LinearProgressIndicator` | `AppProgressIndicator` |
| Core 内 `AppRoutes` 业务路由组合 + `MaterialPageRoute` | 业务路由组合移至 App host；Core 只导出导航原语；继续使用平台默认 builder |

Phase 0 必须用 `rg` 查清当前仓库内消费者。没有仓库外消费者时直接迁移并删除旧实现；只有真实跨阶段消费者存在时才建立带替代说明和删除里程碑的 `@Deprecated` 包装。

## 10. 导航与 Shell 契约

1. `Admin9Shell` 持有当前 Tab、页面实例和页面保活。重复点击已选 Tab 明确保持当前状态，不伪造滚顶或资源启停；真实业务出现滚顶或媒体资源需求时，由对应 feature/resource owner 提供并测试该行为。
2. Android Shell 固定使用 `Scaffold(body: IndexedStack, bottomNavigationBar: AppBottomNavigation)`；iOS Shell 固定使用 `CupertinoPageScaffold`，在纵向布局中依次放置 `Expanded(IndexedStack)` 和 `AppBottomNavigation`。`CupertinoTabScaffold` 不进入首期，避免把页面所有权交给底栏组件。
3. `AppBottomNavigation` 只渲染平台底栏并上报选择事件。
4. Android 和 iOS 都保留当前两个一级目的地“首页”“我的”；两个目的地是已确认产品结构，不为迎合组件建议增加占位 Tab。
5. Phase 0D 将现有 `AppRoutes` 的业务路由组合移至 App host；Core 只提供导航原语。子页面由 App host 创建 `MaterialPageRoute` 并保留平台默认 builder。
6. iOS 使用默认 Cupertino 转场和边缘返回；Android 使用默认 predictive-back 转场。
7. 根页不能返回；子页返回后仍停留在进入前的 Tab，Tab 页面状态和滚动位置不丢失。
8. Dialog、Picker 和 modal sheet 先关闭自身，再允许页面返回。
9. 首期不增加每个 Tab 的独立 Navigator。出现需要独立 Tab 栈的真实流程后另行评审。

Android `Scaffold` 和 iOS `CupertinoPageScaffold` 都启用键盘避让。子页面正文固定应用 `SafeArea(top: false, bottom: true)`；顶部由平台导航栏处理，底部由 `MediaQuery.viewPadding` 保护。Shell 的一级页面底部由 NavigationBar/CupertinoTabBar 处理，不再叠加第二层 bottom SafeArea。所有 modal sheet 和 Picker 自身应用底部 SafeArea。

## 11. 实施阶段与门禁

### Phase 0D：非视觉合同与机器门禁（v1.0.1 边界澄清）

- 以已通过的非导出 declaration probe 为输入，只实现枚举、值对象、controller 接口、`AppDesignScope`、`AppFeedbackHost`、`AppInteractionHost` 和 Brand entry 这些非视觉机制；禁止用 `throw`、`external`、占位 Widget 或假服务冒充 presenter 实现。lookup scope 缺失时抛出明确 `FlutterError` 属于 host 配置违约，不是临时实现。Dialog、ActionMenu、Feedback 和其他具体视觉 Widget 在所属 Phase 首次实现、实例化、测试并导出，不在 0D 伪造。
- 创建 `lib/core/design_system/`、非空且精确白名单化的 `lib/admin9_ui.dart` 与 Brand entry，并建立 analyzer AST 导入边界测试及正反 fixtures。Phase 0D 硬门禁覆盖 Core/App/Business、Core internal、公共出口、`lib/ui/features/**`、`lib/ui/shared/**` 和跨 feature；Phase 5 在页面迁移完成后启用拒绝全部 Business 直接 Material/Cupertino 交互导入的 final 模式。
- 将业务路由组合从 Core 移至 `lib/app/app_routes.dart`，路由名称合同单独放在 `lib/app/app_route_names.dart`；Business 对 App 的只读 allowlist 仅含路由名称与 `lib/app/app_identity.dart`，不得反向导入 App host 或 Brand entry。AST 门禁证明 Core 不导入 feature 页面、模型或服务，且不存在路由组装环。
- 派生项目先验证根 manifest，再通过固定生成器生成 `lib/app/brand/app_brand_theme.dart` 与 `lib/app/app_identity.dart`；精确 Brand verifier 比较全部字段、类型、构造面、颜色、字体、圆角、资产和 App 身份，拒绝额外字段与任一 Dart 值漂移。
- 在派生项目模板中放置符合 schema 的 `admin9-foundation.yaml`，运行 validator；当前仓库不因本规范提交虚构自己是派生项目。
- 固定 Gallery route registry 的 debug/profile 注册和 release 缺席测试接口，但不实现 Gallery 页或任何组件视觉。Phase 1 才建立可达页和 release 安装包不可达证据。
- 更新兼容表为实际实现 commit；设备不可用项继续记录 Unknown。

退出门禁：declaration/implementation probes、manifest validator、AST import fixtures/0D 仓库模式和 Gallery registry/release guard 均有可执行命令；AST 证明 Core 无业务路由组合和 feature 依赖；公共非视觉 API 无待选签名；具体 Widget 实例化证据已唯一分配到所属 Phase；仍不得迁移页面或实现视觉。

### Phase 1：主题、系统偏好、本地化与 Gallery 骨架

- 建立 ColorScheme、TextTheme、Cupertino theme bridge、间距、圆角和 motion Token。
- 合并系统与 App 的高对比度、减少动态效果设置。
- 删除字体缩放 2.0 上限，保留系统非线性 TextScaler。
- 修复减少动态效果对平台返回手势的破坏。
- 增加 `flutter_localizations` 与固定 `zh_CN` 配置。
- 建立仅 debug/profile 可达的 Gallery 路由和状态切换壳。

退出门禁：A-L 矩阵中的基础/主题行通过；系统偏好运行时变化能够重建；默认路由 builder 未被替换；Gallery AST、profile 可达、release build 与安装包不可达四项证据齐全。

### Phase 2：平台骨架与导航

- 实现 `AppPage`、`AppBottomNavigation`、`AppFeedback`、`AppProgressIndicator` 和平台图标映射。
- 将 Shell、顶部标题栏、底部导航和现有反馈接入 Admin9 UI。
- 自动化覆盖普通系统返回前后的路由与 Tab 状态，并保留平台默认返回 builder；iOS 边缘返回完成/取消和 Android API 34+ predictive back 四阶段作为 Phase 6 真人系统手势硬门禁。

Phase 2 实现退出门禁：首页与我的双端导航、安全区、edge-to-edge 和状态恢复通过自动化；integration test 证明普通返回事件前后的路由结果、选中 Tab、页面状态和无重复 pop。真实系统手势不是 Phase 2 的退出条件，也不伪装成 Phase 2 自动化结果；它们统一延迟到 Phase 6，并已按第 12.3、12.4 节关闭。

### Phase 3：设置页端到端试点

- 实现 `AppListTile`、`AppSection`、`AppSwitch` 和 `AppSingleChoiceList`。
- 完成“首页/我的切换 → 进入设置 → 修改主题与辅助功能 → 返回”的完整任务链。
- 验证重启后偏好持久化，返回后 Tab 和页面状态正确。
- 在 Gallery 展示每个组件的 variants、states、平台、主题、高对比度和字号。

退出门禁：A-L 自动化、持久化和双端映射通过；设备阶段仅对自动化不能证明的真实读屏、系统手势、真实输入法、安全区和 release 安装进行代表流程取证。

### Phase 4：按钮、弹窗、输入与通用页面

- 实现 `AppButton`、`AppDialog`、`AppTextField`、`AppNotice` 和 `AppActionMenu`。
- 迁移认证表单、账户页、隐私门禁、法务、关于和联系方式页面。
- 保持路由、校验、隐私、会话和未接入服务边界不变。
- 表单覆盖键盘、autofill、密码、错误聚焦、最长中文文案和防重复提交。

退出门禁：业务行为不回退；feature 页面不再直接使用已被 Admin9 UI 接管的控件；测试不依赖 Material 实现类型定位业务行为。

### Phase 5：全量迁移与兼容层清理

- 完成剩余页面迁移。
- 删除无消费者的旧组件和临时兼容包装。
- 检查 `admin9_ui.dart` 导出面和 feature 导入边界。
- 完成组件文档、Gallery 和代表性 Golden。

退出门禁：无废弃引用、无越过公共出口的核心交互组件、无业务文案下沉到公共层。

### Phase 6：交付验收

- 运行第 12 节全部静态检查、单元测试、Widget 测试、设备集成测试和 release 构建。
- 自动化与代码审查固定覆盖组件状态、焦点请求、Semantics、表单校验、响应式、Token、平台映射和业务边界。
- 人工仅验证自动化不能证明的真实读屏、系统手势、真实输入法、安全区和 release 安装冷启动；每类能力每平台一条代表流程，不遍历所有等价页面。
- P0/P1 必须在交付前关闭；P2/P3 记录责任人、触发条件和 backlog，待真实业务采用、观测到失败或用户反馈后升级。非阻塞项不得伪称已通过。

退出门禁：自动化命令全绿，人工 P0/P1 代表矩阵签字，无未关闭 P0/P1，P2/P3 全部进入可追踪 backlog，计划与实现差异为零。

## 12. 测试与量化验收

### 12.1 自动化覆盖

公共组件与页面模式必须使用 Design System [A-L 唯一矩阵](../design-system/06-accessibility-quality.md#ds-rsp-001)，本文不定义第二套组合。每个已实现 Core 组件和三张参考页面模式都执行 A-L；无文字组件仍在每一行验证 bounds、焦点和状态。组件测试另外覆盖：

- Android 与 iOS target platform；组件存在平台分支时两端都断言底层类型。
- light、dark、高对比度以及有效系统偏好变化；缺失 A-L 任一要求即失败。
- 契约中适用的 normal、disabled、loading、error、destructive、selected 状态。
- App `1.00/1.12/1.24` 与 synthetic system scaler `1.0/2.0/3.0` 的精确组合；synthetic case 不冒充真实 Android/iOS 最大字号。
- Semantics 的 label、role、value/state、enabled、selected/toggled 和 action。
- Widget 测试按 A-L 固定 320、360、390、600 与 844x390，断言无 overflow、裁切、重叠、操作入口或滚动终点丢失。
- 减少动态效果开启后不播放非必要动画；Android/iOS integration test 只验证普通返回事件前后的应用状态。iOS edge-back 的开始、进度、取消、完成和 Android predictive back 四阶段都由对应模拟器/真机的人类真实手势硬门禁证明，自动化不得冒充系统手势证据。优先保存连续录像；若系统录屏无法捕获合成层转场，必须保留失败录像、原生输入方法、同步观察记录及取消/完成前后截图，且不得把失败录像标为通过。
- 系统 bold text 开启后不截字、不改变语义顺序；Widget 测试固定焦点顺序与 Enter/Space/Escape 行为。外接键盘实机采样为 P2，只在真实业务采用或出现焦点回归时升级为阻塞项。
- `AppFeedback` Widget 测试覆盖：无操作且 `accessibleNavigation == false` 时 3 秒/5 秒到期；存在操作按钮或 `accessibleNavigation == true` 时持久显示；关闭控件、操作回调仅一次、回调后关闭和新消息原子替换；同时断言 live region、焦点不被抢走、消息标签、关闭/操作语义以及替换时只公告新消息。
- `AppActionMenu` 覆盖 2/6 项、disabled、destructive、取消、焦点、一次选择与两端 sheet 类型；`AppProgressIndicator` 覆盖 circular/linear、indeterminate、0/45/100%、label/value Semantics 和 reduced motion。

业务 Widget 与 integration test 固定使用稳定 Key、可见文字、Semantics 和结果状态定位。只有 Admin9 UI 自身的组件测试可以用 `find.byType` 断言 Material/Cupertino 底层映射。

iOS 边缘返回测试不得在拖动失败后调用系统返回作为兜底；必须分别断言短距离拖动取消后仍留在当前页、长距离拖动完成后回到上一页。现有 `flutter test integration_test/...` 命令不产生 Android 系统级预测返回手势；Android integration test 固定只断言返回事件前后的路由结果、选中 Tab、页面状态和无重复 pop。`Navigator.pop()`、`handlePopRoute()` 以及 integration test 的普通返回都不得作为 predictive back 开始、进度、取消或完成的证据。

Golden 只覆盖以下代表组合，不做全矩阵笛卡尔积：

- 核心组件 Gallery：A、F、G、L 及每个组件的关键状态。
- 代表页面：首页、设置、认证表单和隐私门禁。
- Golden 只作为视觉回归证据，不能替代对比度、Semantics 和真机手势测试。

### 12.2 项目命令

从仓库根目录按顺序执行：

```bash
dart format --output=none --set-exit-if-changed lib test integration_test
dart format --output=none --set-exit-if-changed tool
dart run tool/design_system/validate_foundation_manifest.dart --fixtures
flutter analyze tool/design_system/design_system_contract_probe.dart
dart run tool/design_system/verify_rule_links.dart
phase6_implementation_commit="$(git rev-parse 'design-system-v1.0.2^{commit}^')"
dart run tool/design_system/verify_design_system_release.dart --version=1.0.2 --foundation-commit="$phase6_implementation_commit"
dart run tool/design_system/verify_repository_governance.dart
dart run tool/design_system/verify_public_api_parity.dart --self-test
node tool/design_system/verify_documentation.mjs
node docs/design-system/evidence/sources/verify_visual_references.mjs docs/design-system/evidence/visual-references
dart run tool/design_system/verify_android_release_plugins.dart --self-test
dart run tool/design_system/verify_android_release_plugins.dart
flutter analyze
flutter test -r expanded

flutter devices
ADMIN9_ANDROID_DEVICE_ID='replace-with-android-device-id'
ADMIN9_IOS_DEVICE_ID='replace-with-ios-device-id'
flutter test integration_test/foundation_smoke_test.dart -d "$ADMIN9_ANDROID_DEVICE_ID"
flutter test integration_test/foundation_smoke_test.dart -d "$ADMIN9_IOS_DEVICE_ID"

flutter build apk --release
flutter build ios --release --no-codesign
git diff --check
```

`flutter test` 不执行 `integration_test/`，因此两条设备命令是独立硬门禁。设备 ID 必须记录在验收报告，不把占位符原样用于执行。

上述 Android 设备命令只验证应用在普通返回事件前后的状态，不验证系统 predictive back 四阶段。predictive back 的硬门禁固定采用第 12.3、12.4 节的 API 34+ 模拟器或真机人工手势及屏幕录像证据，本期不新增系统级自动化工具。

### 12.3 设备矩阵

| 平台 | 最低覆盖 | 必验内容 |
| --- | --- | --- |
| Android API 34 模拟器 | 手势导航 | 人工 predictive back 开始、可见进度、取消、完成硬门禁；IME 与表单 |
| Android API 36 模拟器 | 手势导航和三键导航各一次 | 人工 predictive back 四阶段回归；强制 edge-to-edge、状态栏/导航栏图标对比度、显示缺口、安全区、底栏与 IME |
| Android 可用真机 | 至少一台；本期 API 30 覆盖非版本限定项 | release 安装/冷启动、TalkBack 代表流程、一个单选、一个开关、字号持久化、真实 IME、深浅色/大字号冒烟；Android 14+ 真机缺失单独记 Unknown |
| iOS 当前版本模拟器 | Xcode 实际可用的一种小屏和一种常规屏 | 记录具体型号、runtime 与实测逻辑宽度；自动化验证路由状态、键盘避让、Picker/Dialog 映射与安全区约束；边缘返回真人硬门禁只在 iPhone 完成 |
| iPhone 真机 | 至少一台 | 最终源码签名安装/冷启动、VoiceOver 代表流程、真实 IME、边缘返回、安全区、深浅色/最大字号冒烟 |

iOS 13.0 作为构建兼容下限保留；若当前 Xcode 不提供 iOS 13 runtime，以 deployment target、release build 和编译结果作为下限证据，不伪造旧系统真机结论。

320、360、390、600 逻辑像素宽度和手机横屏尺寸只由 Widget 测试窗口覆盖。iOS 模拟器证据必须来自当前 Xcode 实际列出的设备；若不存在 320pt 设备，不得用其他型号或缩放截图冒充 320pt 模拟器证据。

### 12.4 人工验收任务

1. 双端各完成一次首次启动隐私门禁、接受并进入首页，记录 release 冷启动和实际读屏公告。
2. 双端各用一条代表读屏流程覆盖一级导航、返回、一个设置单选、一个开关、认证首错聚焦、密码显示状态和未接入真实边界。
3. 双端真实输入法各验证一次 Next 和 Done/提交；其余键盘、autofill、表单状态由自动化负责。
4. 双端各冒烟一次浅色、深色和大字号代表页；记录安全区、滚动终点和主操作可达性。
5. Android API 36 人工检查代表页的手势/三键、edge-to-edge、状态/导航栏、缺口和 IME；iOS 人工记录一次边缘返回取消与完成。
6. Android API 34 与 API 36 分别记录 predictive back 开始、可见进度、取消和完成；证据包含设备/模拟器、API、导航模式、录像和四阶段结果。

每项 P0/P1 记录设备、OS/API、设置、预期、实际和证据编号。Switch Access/Control、外接键盘、密码管理器、逐页面读屏、全部 Dialog/Notice/AppFeedback 变体的人工重复为 P2 backlog；自动化或代表流程发现真实失败时立即重新定级。

## 13. Gallery 与发布隔离

Gallery 从 Phase 1 开始与组件同步维护，固定展示 variants、states、Android/iOS、light/dark/high-contrast、字号、长中文和窄屏。

Gallery 只在 debug/profile 构建注册入口，release 构建不得注册路由、菜单或深链。Gallery 不从 `admin9_ui.dart` 导出，不读取生产数据，不写入用户偏好。

## 14. 西昌归档评审裁决

评审对象：

- 分支：`codex/archive-xichang-prototype`
- Tag：`xichang-prototype-20260729`
- SHA：`d838794d311fb007e2f8a61c444fb23cf4d5df0b`

归档仅作为历史设计输入，不作为发布质量证明。允许复用的只有 `App*` 命名、有限 `ThemeExtension`、统一间距/圆角/语义测试和代表性 Golden 的方法。

不得迁入：六套融媒体色板、频道渐变、媒体尺寸、直播规格、全平台强制 Apple 字体、Material-only iOS 控件、页面 DSL、Shell 状态、播放器生命周期和客户业务能力。

归档中的测试数量和覆盖率是历史证据，不替代 v1.2 实施门禁。实施阶段不恢复、合并或整体复制归档代码。

## 15. 第三方依赖与 package 边界

首期唯一计划内依赖变化是增加 Flutter SDK 自带的 `flutter_localizations`。其他依赖必须单独说明 Android/iOS 支持、维护状态、Flutter 兼容性、License、无障碍、深色模式、字体缩放、包体和官方能力缺口，经批准后才能加入。

出现以下任一事实后再评估独立 `admin9_ui` package：

1. 第二个 Flutter 项目需要同步使用同一套 UI。
2. Admin9 UI 需要独立版本、变更日志和发布节奏。
3. 当前仓库无法清晰承担组件测试、Gallery 和文档职责。

在此之前不引入 package 拆分、组件级 semver、Token 生成器和跨仓库发布流程。

## 16. 建议提交顺序

1. `docs(ui): revise Admin9 UI implementation baseline`
2. `feat(theme): establish adaptive theme and accessibility foundations`
3. `feat(ui): add adaptive shell and navigation components`
4. `refactor(settings): validate Admin9 UI pilot flow`
5. `feat(ui): add adaptive form and action components`
6. `refactor(ui): migrate common app pages`
7. `test(ui): complete gallery and device acceptance coverage`
8. `docs(ui): finalize component and validation guides`

提交顺序只是未来本地 Git 组织建议，不构成提交、push、发布或部署授权。

## 17. 工作量基线

- Phase 0D 真实声明、schema/validator 接入、AST fixtures 和 Gallery release gate：3 至 5 个工作日。
- Foundations、系统偏好、本地化和平台主题桥：5 至 7 个工作日。
- 首批平台组件、Shell、设置试点、ActionMenu/Progress：10 至 14 个工作日。
- Gallery、参考 fixtures、Goldens 和 A-L 自动化：4 至 6 个工作日。
- 认证及其余通用页面迁移：5 至 8 个工作日。
- 双端设备/无障碍验收、修正和交付文档：4 至 7 个工作日。

单人完整基础版预计 31 至 47 个工作日。两名协调工程师可以缩短经过时间，但视觉校准、API 门禁和设备验收仍需串行收口。该估算不包含新业务页面、无消费者的 Select/Segmented 实现、专项第三方组件、签名证书故障和设备不可用；不得通过删除 P1 门禁压缩工期。

## 18. 变更控制

以下变化必须先修订本文并重新评审，不能在代码评审中临时决定：

- 更换 `MaterialApp`、路由体系、状态管理或公共组件所有权。
- 改变第 5 节平台组件映射。
- 增加全局 UI 套件、自定义字体、动态颜色或独立 package。
- 降低触控目标、对比度、字体缩放、读屏、edge-to-edge 或返回手势门禁。
- 让 Gallery 进入 release，或让公共组件依赖业务状态和服务。

Flutter SDK 升级后必须重新核对默认 `PageTransitionsTheme`、Android target SDK、edge-to-edge、predictive back、Cupertino API 和弃用项，再确认本基线是否仍成立。

## 19. 变更记录

- 2026-07-29：建立初始工作版本，记录 Admin9 UI、`App*` 命名和 Material/Cupertino 自适应方向。
- 2026-07-29：完成西昌归档评审与二次复核，形成 v1.0 正式实施计划。
- 2026-07-29：依据六角色终审和对抗式复查修订为 v1.1；固定平台组件映射与产品基线，补齐系统辅助功能合并、字体缩放、gesture-preserving reduced motion、Android edge-to-edge/predictive back、组件契约、阶段顺序、设备测试命令和量化验收标准。
- 2026-07-29：收口 v1.1 侧边验收；固定 `AppFeedback` 无障碍持久态、Android predictive back 人工硬门禁证据和 Widget/iOS 模拟器宽度职责。
- 2026-07-29：同步 Admin9 Design System v1.0，形成 v1.2 下游计划；替换旧 Token，补齐 schema/validator、declaration probe、`AppSingleChoiceList`、`AppActionMenu`、`AppProgressIndicator`、A-L 自动化矩阵、Gallery release 门禁和 31-47 工作日工期。
- 2026-07-31：同步 Design System v1.0.2 风险分层证据政策与实际阶段状态；固定 P0/P1 代表流程硬门禁、P2/P3 backlog、系统手势失败录像边界和 Phase 6 验收责任。
