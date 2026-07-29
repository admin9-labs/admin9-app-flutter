import 'package:flutter/material.dart';

import '../../theme/app_appearance.dart';
import '../components/app_bottom_navigation.dart';
import '../components/app_page.dart';
import '../components/app_progress_indicator.dart';
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
                ],
              ),
            ),
          ),
        ),
      ),
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
