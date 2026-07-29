# Admin9 UI 最终实施计划

> 状态：v1.1 可执行实施基线，尚未授权开始代码实施
> 版本：v1.1
> 建立日期：2026-07-29
> 修订日期：2026-07-29
> 适用范围：Admin9 App Foundation Flutter（Android / iOS）
> SDK 基线：Flutter 3.44.1、Dart 3.12.1、Android min SDK 24 / target SDK 36、iOS 13.0

## 1. 文档目的与授权边界

本文固定 Admin9 App Foundation Flutter 的 UI 架构、视觉基线、组件 API、平台映射、实施顺序和验收门禁，是后续代码实施的唯一基线。

本文已经关闭首期架构和产品表现的选择题。实施者不得在 feature 页面自行改用另一套 Material、Cupertino、自绘控件、路由转场、反馈形式或页面容器。发现 Flutter SDK 限制时，应先记录复现、影响范围和候选修正，经计划变更评审后再调整本基线。

本文定稿不代表已经授权修改主题、组件、页面、依赖、测试或导航。代码实施、Git 提交、push、发布和部署均需单独授权。

## 2. 固定架构决策

1. 整套 UI 体系命名为 **Admin9 UI**，项目级公共组件使用 `App*` 命名。
2. 应用根节点固定使用 `MaterialApp`，不切换为 `CupertinoApp`，也不按平台维护两棵应用树。
3. Android 交互控件使用 Material 3；iOS 交互控件使用 Flutter Cupertino 控件。品牌颜色、内容层级和业务语义保持一致，平台手势、控件结构、系统反馈和导航行为保持原生。
4. 平台分支只存在于 Admin9 UI、主题桥接和 App Shell。feature 页面不得使用 `Platform.isIOS`，也不得直接选择 Material/Cupertino 实现。
5. 页面路由固定保留 `MaterialPageRoute` 与 Flutter 默认 `PageTransitionsTheme`。首期不创建自定义路由类。
6. 不引入 `flutter_platform_widgets` 等全局第三方 UI 套件。图表、富文本和媒体能力按独立需求评估。
7. Admin9 UI 固定保留在当前应用仓库，首期不拆独立 package。
8. 只封装具有平台差异、统一状态、无障碍或稳定复用价值的组件，不包装 `Row`、`Column`、`Text`、`Icon`、`Padding`、`SizedBox`、`Expanded` 和 `Flexible`。
9. App Shell 固定持有一级导航、Tab 页面实例、页面保活和全局资源生命周期；各 feature 固定持有本页滚动控制器、表单状态、业务状态和页面级资源。公共组件只接收值、展示数据和回调。
10. 媒体、频道、直播、积分、客户身份、Logo、法务资料和构建配置不进入 Admin9 UI。
11. v1.1 只支持中文简体界面，固定配置 `zh_CN` 和 Flutter 的 Material、Cupertino、Widgets 本地化代理；日期、时间和 24 小时制尊重系统设置。
12. 首期不启用 Android 动态颜色。两端都使用本计划固定的 Admin9 品牌主题。

## 3. 产品视觉基线

### 3.1 视觉气质

Admin9 是通用业务 App 骨架，视觉固定为安静、清晰、克制、适合重复操作的信息界面。首期不使用装饰渐变、玻璃拟态、悬浮大卡片、营销式大标题和无业务含义的动效。

Android 保留 Material 3 的状态层、波纹、NavigationBar 和标准表单行为；iOS 保留 Cupertino 的导航栏、Tab Bar、按压反馈、弹层结构和边缘返回。不得通过给 Material 控件换颜色来冒充 iOS 适配。

### 3.2 颜色

主题固定以 `ColorScheme.fromSeed(seedColor: Color(0xff263238))` 生成完整角色，并覆盖以下品牌角色：

| 角色 | 浅色 | 深色 |
| --- | --- | --- |
| `primary` | `#263238` | `#F4F6F7` |
| `onPrimary` | `#FFFFFF` | `#20272A` |
| `secondary` | `#C83F32` | `#FF8A7A` |
| `tertiary` / success | `#08786E` | `#71D8CC` |
| `surface` | `#F8F9FA` | `#15191B` |

普通主题使用 `contrastLevel: 0.2`，有效高对比度开启时使用 `contrastLevel: 1.0`。Error、outline、surface container、disabled 和 state layer 角色从同一个 `ColorScheme` 获取，不在业务页面硬编码。

`warning` 和 `info` 是 Flutter `ColorScheme` 未提供的通用语义，进入单个 `ThemeExtension`。固定颜色对如下：浅色 warning `#8A4D00` / onWarning `#FFFFFF`，深色 warning `#FFB86B` / onWarning `#2B1700`；浅色 info `#315E7D` / onInfo `#FFFFFF`，深色 info `#A7C7E7` / onInfo `#102636`。高对比度沿用同一颜色对并提高边框宽度，不生成第三套色值；Phase 1 必须计算并记录实际对比度。首期不为每个组件建立独立 Token 类。

### 3.3 字体、间距、圆角与密度

- 两个平台都使用系统字体，不引入字体文件，不强制 `.AppleSystemUIFont`。
- 文字语义以 `TextTheme` 为公共入口；Cupertino 组件从相同语义角色生成 `cupertinoOverrideTheme`，业务页面不写平台字号。
- 间距刻度固定为 `4 / 8 / 12 / 16 / 20 / 24 / 32` logical pixels。
- 紧凑控件圆角固定为 `4`，输入框、卡片和列表分组固定为 `8`，Dialog 与底部弹层固定为 `12`。
- 页面水平内边距：宽度小于 `600` 时为 `16`，宽度不小于 `600` 时为 `24`。
- 内容最大宽度固定为 `720`，大屏采用居中单栏；首期不实现双栏、NavigationRail 和桌面布局。
- Android 列表项最小高度为 `56dp`，iOS 列表项最小高度为 `44pt`。共享自绘交互区域不得小于 `48 x 48` logical pixels。
- Android 底部导航内容高度固定为 `72dp`，iOS 使用 `CupertinoTabBar` 默认高度并叠加系统安全区。

### 3.4 响应式范围

首期支持宽度不小于 `320` logical pixels 的手机竖屏和横屏。平板继续使用最大宽度 `720` 的单栏布局。组件不得依赖固定屏幕宽度；横排内容在 `320` 宽度或最大系统字号下放不下时，先让文字换行，再把复合字段切为纵排。只有分段控件和横向工具条使用横向滚动，不能缩小到验收字号以下。

### 3.5 动效

- 自定义微交互动效只使用 `100ms` fast、`200ms` standard 和 `300ms` emphasized 三档。
- 进入使用 `Curves.easeOutCubic`，状态切换使用 `Curves.easeInOutCubic`，退出使用 `Curves.easeInCubic`。
- 主题切换正常时固定 `200ms`，有效减少动态效果开启时固定 `Duration.zero`。
- 页面转场不读取上述 Token，始终使用 Flutter 的平台默认 builder 和时长。
- 首期不实现弹跳、弹性、循环缩放、Hero 和视差自定义动画。

## 4. 目标结构与公共 API

```text
lib/
├── admin9_ui.dart
├── core/
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_theme_tokens.dart
│   │   ├── app_spacing.dart
│   │   ├── app_radii.dart
│   │   └── app_motion.dart
│   └── widgets/
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
│       └── internal/
│           └── app_platform_icons.dart
└── debug/
    └── admin9_ui_gallery_page.dart
```

`lib/admin9_ui.dart` 是 feature 唯一允许导入的 Admin9 UI 出口，只导出稳定组件、公共枚举和主题读取 API。它不导出 Gallery、平台图标表、主题构建器内部实现和迁移兼容层。

`BrandMark` 继续属于应用 branding 层，不从 `admin9_ui.dart` 导出。`AppNotice` 只接收调用方文案和 tone，不内置“服务尚未接入”等业务文字。

不为本项目引入自定义架构 lint。公共出口、禁止 feature 直引实现文件和内部 helper 不导出的规则，通过代码评审清单与现有静态检查执行。

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
| `AppListTile` | `ListTile` | `CupertinoListTile` | 平台原生按压反馈和尾部箭头 |
| `AppSection` | `Column` + section title + unframed children + row `Divider` | `CupertinoListSection.insetGrouped` | 只负责标题、footer 和 children |
| `AppPage` | `Scaffold` + `AppBar` | `CupertinoPageScaffold` + `CupertinoNavigationBar` | 标题栏固定使用平台原生结构 |
| `AppBottomNavigation` | `NavigationBar` | `CupertinoTabBar` | Shell 持有 index、页面实例和生命周期 |
| `AppFeedback` | 瞬时态固定使用 `SnackBar`；持久态固定使用 `MaterialBanner` | 顶部 `OverlayEntry` 通知条；持久态增加关闭控件 | 无操作且未启用无障碍导航时 info/success 3 秒、warning/error 5 秒；其余情况持久显示并即时公告 |
| 确认弹窗之外的操作菜单 | `showModalBottomSheet` | `CupertinoActionSheet` | 只用于 2 至 6 个离散动作，不承担字段选择 |
| 加载指示 | `CircularProgressIndicator` | `CupertinoActivityIndicator` | 有确定进度时 Android 使用 determinate；iOS 展示文字进度 |
| Checkbox | Material `Checkbox` | `CupertinoCheckbox` | 出现首个真实消费者后进入公共层 |
| Radio | `RadioGroup<T>` + `RadioListTile<T>` | `RadioGroup<T>` + `CupertinoListTile` + `CupertinoRadio<T>` | 出现首个真实消费者后进入公共层 |
| 日期选择 | `showDatePicker` | modal popup + `CupertinoDatePicker` | iOS 固定取消/完成；尊重 locale 和系统制式 |
| 页面路由 | `MaterialPageRoute` 默认 Android builder | `MaterialPageRoute` 默认 Cupertino builder | 禁止替换默认 builder 破坏返回手势 |

`AppSelect` 的取消和提交规则固定如下：Android 选择后立即提交；iOS 滚轮先写临时值，点“完成”后只回调一次，点“取消”不回调。超过 20 项、需要搜索、远程加载或多选的场景固定使用独立选择页面，不扩张 `AppSelect`。

平台通用品牌组件固定为 `AppNotice`、空状态和业务卡片；它们在两端使用相同结构，只由主题提供平台适配后的字体和颜色。

系统语义图标固定如下。带“normal / selected”的条目由 `AppBottomNavigation` 根据当前 index 自动选择：

| `AppIconRole` | Android | iOS |
| --- | --- | --- |
| `back` | `Icons.arrow_back` | `CupertinoIcons.back` |
| `close` | `Icons.close` | `CupertinoIcons.clear` |
| `chevronForward` | `Icons.arrow_forward_ios` | `CupertinoIcons.forward` |
| `home` | `Icons.home_outlined` / `Icons.home` | `CupertinoIcons.house` / `CupertinoIcons.house_fill` |
| `account` | `Icons.person_outline` / `Icons.person` | `CupertinoIcons.person` / `CupertinoIcons.person_fill` |
| `settings` | `Icons.settings_outlined` | `CupertinoIcons.settings` |
| `search` | `Icons.search` | `CupertinoIcons.search` |
| `info` | `Icons.info_outline` | `CupertinoIcons.info_circle` |
| `warning` | `Icons.warning_amber` | `CupertinoIcons.exclamationmark_triangle` |
| `success` | `Icons.check_circle_outline` | `CupertinoIcons.check_mark_circled` |
| `error` | `Icons.error_outline` | `CupertinoIcons.exclamationmark_circle` |
| `visibility` | `Icons.visibility` | `CupertinoIcons.eye` |
| `visibilityOff` | `Icons.visibility_off` | `CupertinoIcons.eye_slash` |
| `textSize` | `Icons.text_fields` | `CupertinoIcons.textformat_size` |
| `contrast` | `Icons.contrast` | `CupertinoIcons.circle_lefthalf_fill` |
| `grayscale` | `Icons.tonality` | `CupertinoIcons.circle_grid_3x3` |
| `reduceMotion` | `Icons.motion_photos_off_outlined` | `CupertinoIcons.slowmo` |

业务品牌图标和内容图标保持跨平台一致。feature 页面不得自行替换上述系统语义图标。

## 6. Token 与主题所有权

Token 采用三类所有权，但不要求三套类层级：

1. Primitive：原始颜色、间距和圆角刻度，仅供主题实现内部使用。
2. Semantic：`ColorScheme`、`TextTheme`、`warning`、`info` 和动效语义，是公共组件的主要输入。
3. Component/platform：Android 度量写入 `NavigationBarThemeData`、`FilledButtonThemeData`、`OutlinedButtonThemeData`、`TextButtonThemeData`、`InputDecorationTheme`、`DialogThemeData` 和 `DividerThemeData`；Cupertino 与 Admin9 自定义度量写入对应组件实现文件，不开放给 feature 覆盖。

固定消费顺序为：Flutter `ColorScheme` / `TextTheme` → 必要的单个 `ThemeExtension` → 间距和圆角常量 → 组件内部平台度量。`app_theme_tokens.dart` 不得成为无分类的万能常量文件。

Cupertino 主题固定从同一套 semantic Token 生成 `cupertinoOverrideTheme`，映射 `brightness`、`primaryColor`、`primaryContrastingColor`、`scaffoldBackgroundColor`、`barBackgroundColor`、`selectionHandleColor` 和 `textTheme`。禁用态固定使用解析后的 `CupertinoColors.inactiveGray`；Cupertino 组件不得逐个接收其他硬编码颜色。

## 7. 无障碍与系统偏好

### 7.1 有效设置合并

- 有效高对比度固定为 `MediaQuery.highContrast OR AppAppearance.highContrast`。
- 有效减少动态效果固定为 `MediaQuery.disableAnimations OR AppAppearance.reduceMotion`。
- 主题模式继续由 `AppThemePreference.system/light/dark` 控制。
- 灰度只由 App 内偏好控制。
- 系统辅助功能在运行期间变化时，主题和组件必须立即重建，不要求重启 App。

实现固定在 `MaterialApp.builder` 内读取 `MediaQuery`，生成不可持久化的 `EffectiveAppearance`，再用包含 `cupertinoOverrideTheme` 的 `ThemeData` 包住 Navigator child。亮度取 `MaterialApp` 已按 `themeMode` 选中的 ambient `ThemeData.brightness`；高对比度和减少动态效果按上面的 OR 规则合并。系统派生值不得写回 `SharedPreferences`。

### 7.2 字体缩放

系统 `TextScaler` 是基础，App 字号偏好只追加 `1.00 / 1.12 / 1.24` 倍。删除当前 `2.0` 硬上限，不对系统非线性缩放设置最大值。组件必须在 Android 200% 和 iOS 最大辅助功能字号下保持内容、操作入口和错误信息可达。

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

下列公开名称、输入和行为是稳定契约。Phase 0 只负责把它们写成可编译的 Dart 签名，不得改名、合并成任意 `child` API 或增加页面级样式逃生口。新增可选能力必须保持向后兼容；改变现有语义需要先修订本文。

| 组件 | 必需输入与状态 | 固定约束 |
| --- | --- | --- |
| `AppButton` | `variant`、`label`、`onPressed`、`loading = false`、`AppIconRole? leadingIcon` | `loading` 时只触发一次、尺寸不变、语义为忙碌；`onPressed == null` 即禁用；不开放任意 `style` |
| `AppSwitch` | `value`、`onChanged`、`semanticLabel` | 完全受控；不得持久化设置；读屏暴露 toggled 与 enabled |
| `AppDialog` | `showInformation(title, message)`、`showConfirmation(title, message, confirmLabel)`、`showDestructive(title, message, confirmLabel)` | information 返回 `Future<void>`；另两种返回 `Future<bool>`；取消固定返回 `false`；destructive 不允许点遮罩关闭 |
| `AppTextField` | `controller`、`label`、`focusNode`、`validator`、`forceErrorText`、`keyboardType`、`textInputAction`、`autofillHints`、`obscureText = false`、`showObscureToggle = false`、`enabled = true`、`onFieldSubmitted`、`AppIconRole? prefixIcon` | feature 持有 controller、focus 和校验；组件持有密码可见性的纯展示状态；错误文字与字段形成同一语义节点 |
| `AppSegmentedControl<T extends Object>` | `List<AppSegment<T>> segments`、`value`、`onChanged`、`enabled = true` | `AppSegment` 只含 `value/label`；单选、受控、等宽；窄屏放入横向滚动区，不缩小文字；读屏暴露 selected |
| `AppSelect<T extends Object>` | `label`、`value`、`List<AppSelectOption<T>> options`、`onChanged`、`enabled = true`、`validator`、`forceErrorText` | `AppSelectOption` 只含 `value/label`；不负责搜索、多选和远程加载；iOS 取消不改变值；当前值和校验错误必须被读出 |
| `AppListTile` | `title`、`subtitle`、`AppIconRole? leadingIcon`、`Widget? trailing`、`onTap`、`enabled = true`、`selected = false` | `title/subtitle` 是字符串；trailing 只接受 Admin9 UI 控件或只读文字；装饰图标从语义树排除；不得重复朗读 title |
| `AppSection` | `title`、`footer`、`List<Widget> children` | `title/footer` 是 nullable 字符串；不持有业务状态；不嵌套 Card；连续 section 间距使用 Token |
| `AppNotice` | `tone`、`title`、`message`、`actionLabel`、`onAction` | `title/actionLabel/onAction` 可为空；tone 固定为 info/success/warning/error；业务文案由调用方传入；状态不只靠颜色 |
| `AppFeedback` | `show(context, message, tone, actionLabel, onAction)` | `actionLabel/onAction` 同时为空或同时有值；同一时刻只显示一条；是否持久显示、关闭、替换和公告严格执行下述生命周期，不允许调用方指定 duration |
| `AppPage` | `title`、`child`、`List<AppPageAction> actions`、`bodyMode = AppPageBodyMode.padded` | `actions` 默认为空；`padded` 使用标准页面内边距，`list` 让列表接管纵向滚动但仍限制内容宽度；不开放任意 padding、背景和页面 DSL |
| `AppBottomNavigation` | `List<AppNavigationDestination> destinations`、`currentIndex`、`onSelect` | destination 只含 `label/AppIconRole`；数量 2 至 5；不创建页面、不保活、不启停资源；重复点当前 Tab 仍回调给 Shell |

`AppIconRole` 固定包含 `back`、`close`、`chevronForward`、`home`、`account`、`settings`、`search`、`info`、`warning`、`success`、`error`、`visibility`、`visibilityOff`、`textSize`、`contrast`、`grayscale` 和 `reduceMotion`。`AppPageAction` 固定包含 `label`、`AppIconRole icon` 和 `onPressed`。公共 API 不暴露 Material/Cupertino `IconData`。

Dialog 固定使用“知道了”作为 information 关闭文案，使用“取消”作为 confirmation/destructive 的取消文案。确认文案由调用方通过 `confirmLabel` 提供，不能为空，也不能只用图标表达。

`forceErrorText` 非空时优先于 `validator` 结果，直到 feature 在输入变化后显式清除；组件不得自行清除服务端错误状态。

`AppFeedback` 的生命周期固定如下：`persistent = actionLabel != null || MediaQuery.accessibleNavigationOf(context) || SemanticsBinding.instance.semanticsEnabled`。`persistent == false` 时，info/success 在 3 秒后自动关闭，warning/error 在 5 秒后自动关闭；`persistent == true` 时不得自动关闭，必须显示使用 `AppIconRole.close` 的可见关闭控件，只能通过关闭控件、操作按钮激活或新消息替换而消失。操作按钮激活后立即封锁重复触发，只调用一次 `onAction`，随后关闭当前消息，不以回调结果决定是否关闭。新消息始终替换当前消息，无论当前消息处于瞬时态还是持久态。

每条反馈的正文使用单一 `Semantics(liveRegion: true)` 节点公告 message 和 tone；出现时不得仅因公告抢走当前读屏焦点。替换时只公告新消息，不重复公告旧消息；关闭不额外播报。持久态的关闭控件和操作按钮各自使用独立语义节点，必须分别具有可读名称与可执行语义。

所有公共组件必须拥有 `Key` 透传、const 可用性、light/dark/high-contrast 支持和适用状态的 Widget 测试。公共组件不得依赖 Provider、业务 ViewModel、业务实体、Repository 或接口服务。

## 9. 组件批次与现有迁移

### 9.1 实施批次

首批平台骨架：

- `AppPage`
- `AppBottomNavigation`
- `AppListTile`
- `AppSection`
- `AppSwitch`
- `AppSegmentedControl`
- `AppSelect`
- `AppFeedback`
- 内部平台图标映射

第二批通用操作：

- `AppButton`
- `AppDialog`
- `AppTextField`
- `AppNotice`

出现真实消费者后再增加：Checkbox、Radio、DatePicker、Empty、Result、Tag、Avatar、文件选择、图片选择、图表和富文本适配器。

### 9.2 迁移表

| 当前实现 | 固定目标 |
| --- | --- |
| `FoundationPage` | `AppPage` |
| `SettingsSection` | `AppSection` |
| `UnavailableNotice` | `AppNotice`，业务文案移回 feature |
| `FilledButton` / `OutlinedButton` / `TextButton` | 对应 variant 的 `AppButton` |
| `SwitchListTile` | `AppListTile` + `AppSwitch` |
| `TextFormField` | `AppTextField` |
| `SegmentedButton` | `AppSegmentedControl` |
| `DropdownButton` | `AppSelect` |
| `NavigationBar` | `AppBottomNavigation` |
| `SnackBar` | `AppFeedback` |
| `AppRoutes` + `MaterialPageRoute` | 保留路由入口和默认 builder，补齐手势测试 |

Phase 0 必须用 `rg` 查清当前仓库内消费者。没有仓库外消费者时直接迁移并删除旧实现；只有真实跨阶段消费者存在时才建立带替代说明和删除里程碑的 `@Deprecated` 包装。

## 10. 导航与 Shell 契约

1. `Admin9Shell` 继续持有当前 Tab、页面实例、页面保活、重复点击 Tab、滚动到顶部和资源启停。
2. Android Shell 固定使用 `Scaffold(body: IndexedStack, bottomNavigationBar: AppBottomNavigation)`；iOS Shell 固定使用 `CupertinoPageScaffold`，在纵向布局中依次放置 `Expanded(IndexedStack)` 和 `AppBottomNavigation`。`CupertinoTabScaffold` 不进入首期，避免把页面所有权交给底栏组件。
3. `AppBottomNavigation` 只渲染平台底栏并上报选择事件。
4. Android 和 iOS 都保留当前两个一级目的地“首页”“我的”；两个目的地是已确认产品结构，不为迎合组件建议增加占位 Tab。
5. 子页面统一经现有 `AppRoutes` 创建 `MaterialPageRoute`。
6. iOS 使用默认 Cupertino 转场和边缘返回；Android 使用默认 predictive-back 转场。
7. 根页不能返回；子页返回后仍停留在进入前的 Tab，Tab 页面状态和滚动位置不丢失。
8. Dialog、Picker 和 modal sheet 先关闭自身，再允许页面返回。
9. 首期不增加每个 Tab 的独立 Navigator。出现需要独立 Tab 栈的真实流程后另行评审。

Android `Scaffold` 和 iOS `CupertinoPageScaffold` 都启用键盘避让。子页面正文固定应用 `SafeArea(top: false, bottom: true)`；顶部由平台导航栏处理，底部由 `MediaQuery.viewPadding` 保护。Shell 的一级页面底部由 NavigationBar/CupertinoTabBar 处理，不再叠加第二层 bottom SafeArea。所有 modal sheet 和 Picker 自身应用底部 SafeArea。

## 11. 实施阶段与门禁

### Phase 0：盘点、签名冻结与证据基线

- 核对所有 UI 使用点和仓库内消费者。
- 将第 8 节契约落实为逐组件 Dart API 草案，不写实现代码。
- 记录首页、我的、设置、认证表单和隐私门禁的双端基线截图。
- 记录当前 light/dark、高对比度、字体缩放、返回和键盘行为。
- 确认 Flutter、Dart、Android SDK、iOS deployment target 与本文 SDK 基线一致。
- 按最终迁移清单重新校准工期。

退出门禁：迁移清单、API 草案、设备清单和基线证据齐全；不得遗留影响 Phase 1 至 Phase 3 的产品选择。

### Phase 1：主题、系统偏好、本地化与 Gallery 骨架

- 建立 ColorScheme、TextTheme、Cupertino theme bridge、间距、圆角和 motion Token。
- 合并系统与 App 的高对比度、减少动态效果设置。
- 删除字体缩放 2.0 上限，保留系统非线性 TextScaler。
- 修复减少动态效果对平台返回手势的破坏。
- 增加 `flutter_localizations` 与固定 `zh_CN` 配置。
- 建立仅 debug/profile 可达的 Gallery 路由和状态切换壳。

退出门禁：主题单元/Widget 测试通过；系统偏好运行时变化能够重建；默认路由 builder 未被替换；Gallery 在 release 不注册路由。

### Phase 2：平台骨架与导航

- 实现 `AppPage`、`AppBottomNavigation`、`AppFeedback` 和平台图标映射。
- 将 Shell、顶部标题栏、底部导航和现有反馈接入 Admin9 UI。
- 覆盖 iOS 边缘返回完成/取消、普通系统返回前后的路由与 Tab 状态；在 Android API 34+ 模拟器或真机完成人工 predictive back 开始、可见进度、取消和完成硬门禁。

退出门禁：首页与我的双端导航、安全区、edge-to-edge 和状态恢复通过自动化；integration test 证明普通返回事件前后的路由结果、选中 Tab、页面状态和无重复 pop；Android predictive back 四阶段通过第 12.3、12.4 节规定的设备人工证据后方可退出。

### Phase 3：设置页端到端试点

- 实现 `AppListTile`、`AppSection`、`AppSwitch`、`AppSegmentedControl` 和 `AppSelect`。
- 完成“首页/我的切换 → 进入设置 → 修改主题与辅助功能 → 返回”的完整任务链。
- 验证重启后偏好持久化，返回后 Tab 和页面状态正确。
- 在 Gallery 展示每个组件的 variants、states、平台、主题、高对比度和字号。

退出门禁：Android 与 iOS 的截图、VoiceOver/TalkBack、最大字号、减少动态效果和真机交互全部通过，才允许迁移其余页面。

### Phase 4：按钮、弹窗、输入与通用页面

- 实现 `AppButton`、`AppDialog`、`AppTextField` 和 `AppNotice`。
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
- 完成双端无障碍、edge-to-edge、预测性返回和视觉验收。
- 将失败、豁免和设备环境阻塞记录到验收报告；未批准的失败不得标记通过。

退出门禁：自动化命令全绿，人工矩阵签字，计划与实现差异为零。

## 12. 测试与量化验收

### 12.1 自动化覆盖

公共组件测试必须覆盖：

- Android 与 iOS target platform；组件存在平台分支时两端都断言底层类型。
- light、dark、高对比度以及有效系统偏好变化。
- 契约中适用的 normal、disabled、loading、error、destructive、selected 状态。
- 系统默认字号、App `1.12/1.24` 倍、Android 200% 和 iOS 最大辅助功能字号。
- Semantics 的 label、role、value/state、enabled、selected/toggled 和 action。
- Widget 测试固定设置 320、360、390、600 逻辑像素宽度与一个手机横屏尺寸，断言无 overflow、裁切和操作入口丢失。
- 减少动态效果开启后不播放非必要动画；iOS 边缘返回自动化仍覆盖开始、取消和完成，Android integration test 只覆盖普通返回事件前后的应用状态。
- 系统 bold text 开启后不截字、不改变语义顺序，外接键盘 Tab/Shift+Tab、Enter/Space 和 Escape 行为符合组件角色。
- `AppFeedback` Widget 测试覆盖：无操作且无无障碍导航时 3 秒/5 秒到期；存在操作按钮、`accessibleNavigation == true`、`semanticsEnabled == true` 时分别持久显示；关闭控件、操作回调仅一次、回调后关闭和新消息替换；同时断言 live region、消息标签、关闭/操作语义以及替换时只保留新消息。

业务 Widget 与 integration test 固定使用稳定 Key、可见文字、Semantics 和结果状态定位。只有 Admin9 UI 自身的组件测试可以用 `find.byType` 断言 Material/Cupertino 底层映射。

iOS 边缘返回测试不得在拖动失败后调用系统返回作为兜底；必须分别断言短距离拖动取消后仍留在当前页、长距离拖动完成后回到上一页。现有 `flutter test integration_test/...` 命令不产生 Android 系统级预测返回手势；Android integration test 固定只断言返回事件前后的路由结果、选中 Tab、页面状态和无重复 pop。`Navigator.pop()`、`handlePopRoute()` 以及 integration test 的普通返回都不得作为 predictive back 开始、进度、取消或完成的证据。

Golden 只覆盖以下代表组合，不做全矩阵笛卡尔积：

- 核心组件 Gallery：Android light、iOS light、Android high-contrast dark、iOS 最大字号。
- 代表页面：首页、设置、认证表单和隐私门禁。
- Golden 只作为视觉回归证据，不能替代对比度、Semantics 和真机手势测试。

### 12.2 项目命令

从仓库根目录按顺序执行：

```bash
dart format --output=none --set-exit-if-changed lib test integration_test
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
| Android 当前版本真机 | 至少一台 | TalkBack、Switch Access、200% 字号、深浅色、返回、触控目标和完整试点任务 |
| iOS 当前版本模拟器 | Xcode 实际可用的一种小屏和一种常规屏 | 记录具体型号、runtime 与实测逻辑宽度；验证键盘、Picker、Dialog、边缘返回完成与取消 |
| iPhone 真机 | 至少一台 | VoiceOver、Switch Control、最大辅助字号、深浅色、高对比度、Bold Text、Reduce Motion、完整试点任务 |

iOS 13.0 作为构建兼容下限保留；若当前 Xcode 不提供 iOS 13 runtime，以 deployment target、release build 和编译结果作为下限证据，不伪造旧系统真机结论。

320、360、390、600 逻辑像素宽度和手机横屏尺寸只由 Widget 测试窗口覆盖。iOS 模拟器证据必须来自当前 Xcode 实际列出的设备；若不存在 320pt 设备，不得用其他型号或缩放截图冒充 320pt 模拟器证据。

### 12.4 人工验收任务

1. 首次启动阅读隐私协议、返回、接受隐私提示并进入首页。
2. 首页与我的来回切换，进入设置，修改主题、字号、灰度、高对比度和减少动态效果，返回并重启确认持久化。
3. 打开认证表单，完成焦点遍历、键盘下一项、错误提交、密码隐藏、autofill 和返回。
4. 打开确认型和 destructive Dialog，验证焦点、取消、确认、遮罩和读屏顺序。
5. 开启 VoiceOver/TalkBack，完成底部导航、设置选择、表单错误和返回流程；再用 Switch Control/Switch Access 与外接键盘验证同一交互顺序。
6. 在 Android API 36 验证状态栏、导航栏、显示缺口、手势导航、三键导航和 IME 不遮挡内容。
7. 在 Android API 34+ 手势导航模拟器或真机，从可返回页面执行 predictive back：分别记录开始、可见进度、取消后留在原页、完成后返回且只 pop 一次。证据必须包含设备或模拟器型号、API level、导航模式、屏幕录像编号，以及四阶段各自的预期与实际结果；任一阶段缺失即失败。
8. 在 VoiceOver 和 TalkBack 下分别触发带操作按钮的 `AppFeedback`，确认反馈不会自动消失、出现时不抢走当前焦点、消息与操作只公告一次，并能通过操作按钮或可见关闭控件关闭；再触发新消息确认旧消息被替换且只公告新消息。

每项必须记录设备、OS、主题、字号、辅助功能、结果和截图编号；第 7 项必须额外记录导航模式、屏幕录像编号和四阶段逐项结果。截图正常但操作、读屏、对比度或布局失败时，整体仍判失败。

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

归档中的测试数量和覆盖率是历史证据，不替代 v1.1 当前 SHA 的验收。实施阶段不恢复、合并或整体复制归档代码。

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

- Phase 0 盘点、API 签名和证据：1 至 2 个工作日。
- 主题、系统偏好、本地化和 Gallery 骨架：2 至 3 个工作日。
- 平台骨架、导航和设置试点：4 至 6 个工作日。
- 表单、操作组件和通用页面迁移：4 至 7 个工作日。
- 自动化、真机验收、修正和文档：4 至 8 个工作日。

单人完整基础版预计 15 至 26 个工作日，其中包含 2 至 4 个工作日的双端验收与修正缓冲。该估算不包含新业务页面、专项第三方组件、签名证书故障和设备不可用。Phase 0 必须按最终消费者数量与可用设备重新校准，但不得通过删除 P1 验收项压缩工期。

## 18. 变更控制

以下变化必须先修订本文并重新评审，不能在代码评审中临时决定：

- 更换 `MaterialApp`、路由体系、状态管理或公共组件所有权。
- 改变第 5 节平台组件映射。
- 增加全局 UI 套件、自定义字体、动态颜色或独立 package。
- 降低触控目标、对比度、字体缩放、读屏、edge-to-edge 或返回手势门禁。
- 让 Gallery 进入 release，或让公共组件依赖业务状态和服务。

Flutter SDK 升级后必须重新核对默认 `PageTransitionsTheme`、Android target SDK、edge-to-edge、predictive back、Cupertino API 和弃用项，再确认本基线是否仍成立。

## 19. 变更记录

- 2026-07-29：建立 Draft，记录 Admin9 UI、`App*` 命名和 Material/Cupertino 自适应方向。
- 2026-07-29：完成西昌归档评审与二次复核，形成 v1.0 正式实施计划。
- 2026-07-29：依据六角色终审和对抗式复查修订为 v1.1；固定平台组件映射与产品基线，补齐系统辅助功能合并、字体缩放、gesture-preserving reduced motion、Android edge-to-edge/predictive back、组件契约、阶段顺序、设备测试命令和量化验收标准。
- 2026-07-29：收口 v1.1 侧边验收；固定 `AppFeedback` 无障碍持久态、Android predictive back 人工硬门禁证据和 Widget/iOS 模拟器宽度职责。
