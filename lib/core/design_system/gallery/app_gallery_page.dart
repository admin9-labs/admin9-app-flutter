import 'package:flutter/material.dart';

import '../../theme/app_appearance.dart';
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
