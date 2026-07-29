import 'package:flutter/material.dart';

import '../../theme/app_appearance.dart';
import '../components/app_bottom_navigation.dart';
import '../components/app_form_components.dart';
import '../components/app_notice.dart';
import '../components/app_page.dart';
import '../components/app_progress_indicator.dart';
import '../components/app_settings_components.dart';
import '../foundation/app_contracts.dart';
import '../foundation/app_theme.dart';
import '../foundation/app_design_tokens.dart';

typedef AppGalleryThemeResolver =
    AppResolvedTheme Function({
      required Brightness brightness,
      required TargetPlatform platform,
      required bool highContrast,
      required bool reduceMotion,
      required bool boldText,
    });

class AppGalleryPage extends StatefulWidget {
  const AppGalleryPage({
    super.key,
    required this.resolveTheme,
    this.initialBrightness = Brightness.light,
    this.initialPlatform = TargetPlatform.android,
    this.initialFontScale = AppFontScale.standard,
    this.initialHighContrast = false,
    this.initialReduceMotion = false,
    this.initialBoldText = false,
  });

  final AppGalleryThemeResolver resolveTheme;
  final Brightness initialBrightness;
  final TargetPlatform initialPlatform;
  final AppFontScale initialFontScale;
  final bool initialHighContrast;
  final bool initialReduceMotion;
  final bool initialBoldText;

  @override
  State<AppGalleryPage> createState() => _AppGalleryPageState();
}

class _AppGalleryPageState extends State<AppGalleryPage> {
  late Brightness _brightness = widget.initialBrightness;
  late TargetPlatform _platform = widget.initialPlatform;
  late AppFontScale _fontScale = widget.initialFontScale;
  late bool _highContrast = widget.initialHighContrast;
  late bool _reduceMotion = widget.initialReduceMotion;
  late bool _boldText = widget.initialBoldText;

  @override
  Widget build(BuildContext context) {
    final resolved = widget.resolveTheme(
      brightness: _brightness,
      platform: _platform,
      highContrast: _highContrast,
      reduceMotion: _reduceMotion,
      boldText: _boldText,
    );
    final media = MediaQuery.of(context);
    return AppDesignScope(
      tokens: resolved.tokens,
      child: Theme(
        data: resolved.material,
        child: MediaQuery(
          data: media.copyWith(
            textScaler: AppTextScaler(
              system: media.textScaler,
              preferenceFactor: _fontScale.factor,
            ),
          ),
          child: Builder(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Admin9 Gallery')),
              body: ListView(
                key: const Key('gallery-scroll'),
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('内部设计系统检查页'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Brightness>(
                    key: const Key('gallery-brightness'),
                    isExpanded: true,
                    initialValue: _brightness,
                    decoration: const InputDecoration(labelText: '主题'),
                    items: const [
                      DropdownMenuItem(
                        value: Brightness.light,
                        child: Text('浅色'),
                      ),
                      DropdownMenuItem(
                        value: Brightness.dark,
                        child: Text('深色'),
                      ),
                    ],
                    onChanged: (value) => setState(() => _brightness = value!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TargetPlatform>(
                    key: const Key('gallery-platform'),
                    isExpanded: true,
                    initialValue: _platform,
                    decoration: const InputDecoration(labelText: '平台'),
                    items: const [
                      DropdownMenuItem(
                        value: TargetPlatform.android,
                        child: Text('Android'),
                      ),
                      DropdownMenuItem(
                        value: TargetPlatform.iOS,
                        child: Text('iOS'),
                      ),
                    ],
                    onChanged: (value) => setState(() => _platform = value!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<AppFontScale>(
                    key: const Key('gallery-font-scale'),
                    isExpanded: true,
                    initialValue: _fontScale,
                    decoration: const InputDecoration(labelText: 'App 字号'),
                    items: AppFontScale.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text('${value.label} ${value.factor}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _fontScale = value!),
                  ),
                  SwitchListTile(
                    title: const Text('高对比度'),
                    value: _highContrast,
                    onChanged: (value) => setState(() => _highContrast = value),
                  ),
                  SwitchListTile(
                    title: const Text('粗体文本'),
                    value: _boldText,
                    onChanged: (value) => setState(() => _boldText = value),
                  ),
                  SwitchListTile(
                    title: const Text('减少动态效果'),
                    value: _reduceMotion,
                    onChanged: (value) => setState(() => _reduceMotion = value),
                  ),
                  const SizedBox(height: 24),
                  const _TokenSample(),
                  const SizedBox(height: 24),
                  const _Phase2Sample(),
                  const SizedBox(height: 24),
                  const _Phase3Sample(),
                  const SizedBox(height: 24),
                  const _Phase4Sample(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Phase4Sample extends StatefulWidget {
  const _Phase4Sample();

  @override
  State<_Phase4Sample> createState() => _Phase4SampleState();
}

class _Phase4SampleState extends State<_Phase4Sample> {
  final TextEditingController _account = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _account.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppDesignScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('表单与动作', style: tokens.sectionTitleTextStyle),
        SizedBox(height: tokens.space12),
        AppTextField(
          controller: _account,
          label: '用于验证长中文持续标签的账号字段',
          forceErrorText: '账号格式不正确，错误出现后内容区域按需增长。',
          autofillHints: const [AutofillHints.username],
          prefixIcon: AppIconRole.account,
        ),
        SizedBox(height: tokens.space12),
        AppTextField(
          controller: _password,
          label: '密码',
          obscureText: true,
          showObscureToggle: true,
          autofillHints: const [AutofillHints.password],
        ),
        SizedBox(height: tokens.space12),
        Wrap(
          spacing: tokens.space8,
          runSpacing: tokens.space8,
          children: [
            AppButton(label: '主要操作', onPressed: _galleryNoop),
            AppButton(
              label: '次要操作',
              variant: AppButtonVariant.secondary,
              onPressed: _galleryNoop,
            ),
            AppButton(
              label: '低优先级操作',
              variant: AppButtonVariant.tertiary,
              onPressed: _galleryNoop,
            ),
            AppButton(
              label: '危险操作',
              variant: AppButtonVariant.destructive,
              onPressed: _galleryNoop,
            ),
            AppButton(label: '提交中', loading: true, onPressed: _galleryNoop),
            AppButton(label: '不可用', enabled: false, onPressed: _galleryNoop),
          ],
        ),
        SizedBox(height: tokens.space16),
        const AppNotice(tone: AppTone.info, message: '信息状态不只依赖颜色表达。'),
        SizedBox(height: tokens.space8),
        const AppNotice(tone: AppTone.success, message: '操作已完成。'),
        SizedBox(height: tokens.space8),
        const AppNotice(tone: AppTone.warning, message: '请检查当前设置。'),
        SizedBox(height: tokens.space8),
        AppNotice(
          tone: AppTone.error,
          title: '操作失败',
          message: '错误说明允许多行增长，恢复动作保持可达。',
          actionLabel: '重试',
          onAction: _galleryNoop,
        ),
        SizedBox(height: tokens.space12),
        AppButton(
          label: '打开确认对话框',
          variant: AppButtonVariant.secondary,
          onPressed: () => AppInteractionHost.of(context).showConfirmation(
            title: '确认操作',
            message: '确认继续执行此示例操作吗？',
            confirmLabel: '继续',
          ),
        ),
        SizedBox(height: tokens.space8),
        AppButton(
          label: '打开六项动作菜单',
          variant: AppButtonVariant.secondary,
          onPressed: () => AppInteractionHost.of(context).showActionMenu<int>(
            title: '示例动作',
            items: const [
              AppActionMenuItem(value: 1, label: '查看'),
              AppActionMenuItem(value: 2, label: '编辑'),
              AppActionMenuItem(value: 3, label: '复制'),
              AppActionMenuItem(value: 4, label: '分享'),
              AppActionMenuItem(value: 5, label: '不可用', enabled: false),
              AppActionMenuItem(value: 6, label: '删除', destructive: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _Phase2Sample extends StatefulWidget {
  const _Phase2Sample();

  @override
  State<_Phase2Sample> createState() => _Phase2SampleState();
}

class _Phase2SampleState extends State<_Phase2Sample> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tokens = AppDesignScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('平台骨架', style: tokens.sectionTitleTextStyle),
        SizedBox(height: tokens.space12),
        const AppProgressIndicator(label: '不确定进度'),
        SizedBox(height: tokens.space16),
        const AppProgressIndicator(
          label: '尚未开始 0%',
          kind: AppProgressKind.linear,
          value: 0,
        ),
        SizedBox(height: tokens.space16),
        const AppProgressIndicator(
          label: '已完成 45%',
          kind: AppProgressKind.linear,
          value: 0.45,
        ),
        SizedBox(height: tokens.space16),
        const AppProgressIndicator(
          label: '已完成 100%',
          kind: AppProgressKind.linear,
          value: 1,
        ),
        SizedBox(height: tokens.space16),
        AppBottomNavigation(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (value) =>
              setState(() => _selectedIndex = value),
          destinations: const [
            AppNavigationDestination(
              label: '工作台首页',
              icon: AppIconRole.home,
              selectedIcon: AppIconRole.homeSelected,
            ),
            AppNavigationDestination(
              label: '个人中心',
              icon: AppIconRole.account,
              selectedIcon: AppIconRole.accountSelected,
            ),
          ],
        ),
        SizedBox(height: tokens.space16),
        Wrap(
          spacing: tokens.space8,
          runSpacing: tokens.space8,
          children: [
            FilledButton(
              onPressed: () => AppFeedbackHost.of(context).show(
                const AppFeedbackRequest(message: '信息已更新', tone: AppTone.info),
              ),
              child: const Text('信息'),
            ),
            FilledButton(
              onPressed: () => AppFeedbackHost.of(context).show(
                const AppFeedbackRequest(
                  message: '操作已完成',
                  tone: AppTone.success,
                ),
              ),
              child: const Text('成功反馈'),
            ),
            OutlinedButton(
              onPressed: () => AppFeedbackHost.of(context).show(
                AppFeedbackRequest(
                  message: '可以撤销这次操作',
                  tone: AppTone.warning,
                  actionLabel: '撤销',
                  onAction: () {},
                ),
              ),
              child: const Text('警告与撤销'),
            ),
            OutlinedButton(
              onPressed: () => AppFeedbackHost.of(context).show(
                const AppFeedbackRequest(
                  message: '操作失败，请检查后重试。',
                  tone: AppTone.error,
                ),
              ),
              child: const Text('错误'),
            ),
            TextButton(
              onPressed: () {
                AppFeedbackHost.of(context).show(
                  const AppFeedbackRequest(
                    message: '新消息已替换上一条反馈，长文本将按内容增长。',
                    tone: AppTone.info,
                  ),
                );
              },
              child: const Text('替换为长文本'),
            ),
            TextButton(
              onPressed: () => AppFeedbackHost.of(context).dismiss(),
              child: const Text('关闭反馈'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => const AppPage(
                    title: 'AppPage 子页',
                    parentLabel: 'Gallery',
                    navigationMode: AppPageNavigationMode.child,
                    actions: [
                      AppPageAction(
                        label: '很长的可用页面操作名称',
                        icon: AppIconRole.info,
                        onPressed: _galleryNoop,
                      ),
                      AppPageAction(
                        label: '禁用页面操作',
                        icon: AppIconRole.more,
                        onPressed: _galleryNoop,
                        enabled: false,
                      ),
                    ],
                    body: Text('页面栏、安全区、滚动与返回映射。'),
                  ),
                ),
              ),
              child: const Text('打开 AppPage 样例'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Phase3Sample extends StatefulWidget {
  const _Phase3Sample();

  @override
  State<_Phase3Sample> createState() => _Phase3SampleState();
}

class _Phase3SampleState extends State<_Phase3Sample> {
  bool _enabledSwitch = true;
  String _choice = 'system';

  @override
  Widget build(BuildContext context) {
    final tokens = AppDesignScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('设置与列表', style: tokens.sectionTitleTextStyle),
        SizedBox(height: tokens.space12),
        AppSection(
          title: '外观样例',
          footer: '当前值在内容压力下重排；启用项可按住查看按压态，并可通过键盘 Tab 获得焦点态。',
          children: [
            AppListTile(
              key: const Key('gallery-phase3-interactive-tile'),
              title: '主题',
              currentValue: '跟随系统',
              disclosure: true,
              onTap: _galleryNoop,
            ),
            AppListTile(
              title: '这是用于验证长中文内容增长的设置名称',
              subtitle: '说明文字允许增长，不截断关键状态。',
              currentValue: '一个较长的当前值',
              disclosure: true,
              onTap: _galleryNoop,
            ),
            const AppListTile(title: '已选择的设置项', selected: true),
            const AppListTile(
              title: '不可用的设置项',
              subtitle: '禁用状态不会响应操作',
              enabled: false,
            ),
          ],
        ),
        AppSection(
          title: '布尔偏好',
          footer: '启用开关提供平台原生按压态与键盘焦点态。',
          children: [
            AppSwitch(
              key: const Key('gallery-phase3-interactive-switch'),
              label: '高对比度',
              value: _enabledSwitch,
              onChanged: (value) => setState(() => _enabledSwitch = value),
            ),
            const AppSwitch(
              label: '不可修改的系统要求',
              value: true,
              enabled: false,
              onChanged: _galleryBoolNoop,
            ),
          ],
        ),
        SizedBox(height: tokens.space12),
        OutlinedButton(
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => AppSingleChoiceList<String>(
                title: '主题选择样例',
                value: _choice,
                choices: const [
                  AppChoice(value: 'system', label: '跟随系统'),
                  AppChoice(value: 'light', label: '浅色'),
                  AppChoice(value: 'dark', label: '深色'),
                ],
                onChanged: (value) => setState(() => _choice = value),
              ),
            ),
          ),
          child: const Text('打开单选列表样例'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => AppSingleChoiceList<String>(
                title: '禁用单选列表样例',
                value: 'system',
                choices: [
                  AppChoice(value: 'system', label: '跟随系统'),
                  AppChoice(value: 'dark', label: '深色'),
                ],
                enabled: false,
                onChanged: _galleryStringNoop,
              ),
            ),
          ),
          child: const Text('打开禁用单选列表样例'),
        ),
      ],
    );
  }
}

void _galleryBoolNoop(bool _) {}

void _galleryStringNoop(String _) {}

void _galleryNoop() {}

class _TokenSample extends StatelessWidget {
  const _TokenSample();

  @override
  Widget build(BuildContext context) {
    final tokens = AppDesignScope.of(context);
    return Semantics(
      container: true,
      label: '语义 Token 预览',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surfaceContainer,
          border: Border.all(color: tokens.outline),
          borderRadius: BorderRadius.circular(tokens.controlRadius),
        ),
        child: Padding(
          padding: EdgeInsets.all(tokens.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('页面标题', style: tokens.pageTitleTextStyle),
              SizedBox(height: tokens.space8),
              Text('正文与中文内容增长', style: tokens.bodyTextStyle),
              SizedBox(height: tokens.space12),
              Wrap(
                spacing: tokens.space8,
                runSpacing: tokens.space8,
                children: [
                  _ColorSample(label: '主要', color: tokens.primary),
                  _ColorSample(label: '危险', color: tokens.danger),
                  _ColorSample(label: '警告', color: tokens.warning),
                  _ColorSample(label: '成功', color: tokens.success),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorSample extends StatelessWidget {
  const _ColorSample({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 24, height: 24, color: color),
      const SizedBox(width: 4),
      Text(label),
    ],
  );
}
