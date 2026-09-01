import 'dart:convert';
import 'dart:typed_data';

import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_action_bar.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_preview.dart';
import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/layout/grid/a_grid.dart';
import 'package:admin9_app_flutter/shared/ui/layout/grid/a_grid_item.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class GridPage extends StatefulWidget {
  const GridPage({super.key});

  @override
  State<GridPage> createState() => _GridPageState();
}

enum _GridScenario { quickActions, contentEntries, statusPanel }

enum _GridVisual { icon, image, custom }

enum _GridBadge { none, count, label, dot }

class _GridPageState extends State<GridPage> {
  _GridScenario _scenario = _GridScenario.quickActions;
  int _columns = 3;
  double _horizontalGap = 8;
  double _verticalGap = 8;
  double _childAspectRatio = 0.9;
  double _padding = 0;
  AGridItemLayout _layout = AGridItemLayout.vertical;
  _GridVisual _visual = _GridVisual.icon;
  _GridBadge _badge = _GridBadge.none;
  bool _enabled = true;
  bool _selected = false;
  int _actionCount = 0;
  String? _status;

  void _selectScenario(_GridScenario scenario) {
    setState(() {
      _scenario = scenario;
      _applyScenarioDefaults(scenario);
    });
  }

  void _applyScenarioDefaults(_GridScenario scenario) {
    switch (scenario) {
      case _GridScenario.quickActions:
        _columns = 3;
        _horizontalGap = 8;
        _verticalGap = 8;
        _childAspectRatio = 0.9;
        _padding = 0;
        _layout = AGridItemLayout.vertical;
        _visual = _GridVisual.icon;
        _badge = _GridBadge.none;
      case _GridScenario.contentEntries:
        _columns = 1;
        _horizontalGap = 12;
        _verticalGap = 12;
        _childAspectRatio = 3.2;
        _padding = 0;
        _layout = AGridItemLayout.horizontalStart;
        _visual = _GridVisual.image;
        _badge = _GridBadge.label;
      case _GridScenario.statusPanel:
        _columns = 2;
        _horizontalGap = 12;
        _verticalGap = 12;
        _childAspectRatio = 1.05;
        _padding = 0;
        _layout = AGridItemLayout.vertical;
        _visual = _GridVisual.custom;
        _badge = _GridBadge.count;
    }
    _enabled = true;
    _selected = false;
    _actionCount = 0;
    _status = null;
  }

  void _activate(String label) {
    final status = 'examples.foundation.layout.grid.playground.action_result'
        .tr(namedArgs: {'label': label, 'count': '${_actionCount + 1}'});
    setState(() {
      _actionCount++;
      _selected = true;
      _status = status;
    });
    showFToast(
      context: context,
      title: Text(status),
      icon: const Icon(FLucideIcons.circleCheck),
    );
  }

  void _reset() {
    setState(() => _applyScenarioDefaults(_scenario));
    showFToast(
      context: context,
      title: Text('examples.playground.reset_done'.tr()),
      icon: const Icon(FLucideIcons.rotateCcw),
    );
  }

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('examples.foundation.layout.grid.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: context.maybePop)],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'examples.foundation.layout.grid.playground.scenario.title'
              .tr(),
          description:
              'examples.foundation.layout.grid.playground.scenario.description'
                  .tr(),
          child: _ChoiceControl<_GridScenario>(
            value: _scenario,
            onChanged: _selectScenario,
            choices: [
              (
                value: _GridScenario.quickActions,
                label:
                    'examples.foundation.layout.grid.playground.scenario.quick'
                        .tr(),
                key: const ValueKey('grid-scenario-quick'),
              ),
              (
                value: _GridScenario.contentEntries,
                label: 'examples.foundation.layout.grid.playground.scenario.content'
                    .tr(),
                key: const ValueKey('grid-scenario-content'),
              ),
              (
                value: _GridScenario.statusPanel,
                label:
                    'examples.foundation.layout.grid.playground.scenario.status'
                        .tr(),
                key: const ValueKey('grid-scenario-status'),
              ),
            ],
          ),
        ),
        PlaygroundPreview(
          title: 'examples.playground.preview'.tr(),
          status: _status,
          child: AGrid(
            key: const ValueKey('grid-playground-preview'),
            columns: _columns,
            horizontalGap: _horizontalGap,
            verticalGap: _verticalGap,
            childAspectRatio: _childAspectRatio,
            padding: EdgeInsets.all(_padding),
            children: _scenarioItems,
          ),
        ),
        ComponentExampleSection(
          title: 'examples.playground.configuration'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              _GridSliderControl(
                key: const ValueKey('grid-columns-slider'),
                label: 'examples.foundation.layout.grid.playground.columns'
                    .tr(),
                value: _columns.toDouble(),
                min: 1,
                max: 4,
                step: 1,
                formatter: (value) => '${value.round()}',
                onChanged: (value) => setState(() => _columns = value.round()),
              ),
              _GridSliderControl(
                key: const ValueKey('grid-horizontal-gap-slider'),
                label:
                    'examples.foundation.layout.grid.playground.horizontal_gap'
                        .tr(),
                value: _horizontalGap,
                min: 0,
                max: 24,
                step: 4,
                onChanged: (value) => setState(() => _horizontalGap = value),
              ),
              _GridSliderControl(
                key: const ValueKey('grid-vertical-gap-slider'),
                label: 'examples.foundation.layout.grid.playground.vertical_gap'
                    .tr(),
                value: _verticalGap,
                min: 0,
                max: 24,
                step: 4,
                onChanged: (value) => setState(() => _verticalGap = value),
              ),
              _GridSliderControl(
                key: const ValueKey('grid-ratio-slider'),
                label: 'examples.foundation.layout.grid.playground.ratio'.tr(),
                value: _childAspectRatio,
                min: 0.75,
                max: 3.25,
                step: 0.25,
                formatter: (value) => value.toStringAsFixed(2),
                onChanged: (value) => setState(() => _childAspectRatio = value),
              ),
              _GridSliderControl(
                key: const ValueKey('grid-padding-slider'),
                label: 'examples.foundation.layout.grid.playground.padding'
                    .tr(),
                value: _padding,
                min: 0,
                max: 24,
                step: 4,
                onChanged: (value) => setState(() => _padding = value),
              ),
              _ChoiceControl<AGridItemLayout>(
                label: 'examples.foundation.layout.grid.playground.layout'.tr(),
                value: _layout,
                onChanged: (value) => setState(() => _layout = value),
                choices: [
                  (
                    value: AGridItemLayout.vertical,
                    label: 'examples.foundation.layout.grid.playground.layout_vertical'
                        .tr(),
                    key: const ValueKey('grid-layout-vertical'),
                  ),
                  (
                    value: AGridItemLayout.horizontalStart,
                    label: 'examples.foundation.layout.grid.playground.layout_start'
                        .tr(),
                    key: const ValueKey('grid-layout-start'),
                  ),
                  (
                    value: AGridItemLayout.horizontalEnd,
                    label:
                        'examples.foundation.layout.grid.playground.layout_end'
                            .tr(),
                    key: const ValueKey('grid-layout-end'),
                  ),
                ],
              ),
              _ChoiceControl<_GridVisual>(
                label: 'examples.foundation.layout.grid.playground.visual'.tr(),
                value: _visual,
                onChanged: (value) => setState(() => _visual = value),
                choices: [
                  (
                    value: _GridVisual.icon,
                    label:
                        'examples.foundation.layout.grid.playground.visual_icon'
                            .tr(),
                    key: const ValueKey('grid-visual-icon'),
                  ),
                  (
                    value: _GridVisual.image,
                    label: 'examples.foundation.layout.grid.playground.visual_image'
                        .tr(),
                    key: const ValueKey('grid-visual-image'),
                  ),
                  (
                    value: _GridVisual.custom,
                    label: 'examples.foundation.layout.grid.playground.visual_custom'
                        .tr(),
                    key: const ValueKey('grid-visual-custom'),
                  ),
                ],
              ),
              _ChoiceControl<_GridBadge>(
                label: 'examples.foundation.layout.grid.playground.badge'.tr(),
                value: _badge,
                onChanged: (value) => setState(() => _badge = value),
                choices: [
                  (
                    value: _GridBadge.none,
                    label:
                        'examples.foundation.layout.grid.playground.badge_none'
                            .tr(),
                    key: const ValueKey('grid-badge-none'),
                  ),
                  (
                    value: _GridBadge.count,
                    label:
                        'examples.foundation.layout.grid.playground.badge_count'
                            .tr(),
                    key: const ValueKey('grid-badge-count'),
                  ),
                  (
                    value: _GridBadge.label,
                    label:
                        'examples.foundation.layout.grid.playground.badge_label'
                            .tr(),
                    key: const ValueKey('grid-badge-label'),
                  ),
                  (
                    value: _GridBadge.dot,
                    label:
                        'examples.foundation.layout.grid.playground.badge_dot'
                            .tr(),
                    key: const ValueKey('grid-badge-dot'),
                  ),
                ],
              ),
              FSwitch(
                key: const ValueKey('grid-enabled-switch'),
                label: Text(
                  'examples.foundation.layout.grid.playground.enabled'.tr(),
                ),
                value: _enabled,
                onChange: (value) => setState(() => _enabled = value),
              ),
              FSwitch(
                key: const ValueKey('grid-selected-switch'),
                label: Text(
                  'examples.foundation.layout.grid.playground.selected'.tr(),
                ),
                value: _selected,
                onChange: (value) => setState(() => _selected = value),
              ),
            ],
          ),
        ),
        PlaygroundActionBar(
          resetLabel: 'examples.playground.reset'.tr(),
          onReset: _reset,
        ),
      ],
    ),
  );

  List<AGridItem> get _scenarioItems => switch (_scenario) {
    _GridScenario.quickActions => [
      _targetItem(
        title: 'examples.foundation.layout.grid.playground.items.scan'.tr(),
        icon: FLucideIcons.search,
      ),
      _contextItem(
        title: 'examples.foundation.layout.grid.playground.items.share'.tr(),
        icon: FLucideIcons.messageCircle,
      ),
      _contextItem(
        title: 'examples.foundation.layout.grid.playground.items.favorite'.tr(),
        icon: FLucideIcons.heart,
      ),
      _contextItem(
        title: 'examples.foundation.layout.grid.playground.items.settings'.tr(),
        icon: FLucideIcons.settings,
      ),
    ],
    _GridScenario.contentEntries => [
      _targetItem(
        title: 'examples.foundation.layout.grid.playground.items.brand_assets'
            .tr(),
        description: 'examples.foundation.layout.grid.playground.items.brand_assets_description'
            .tr(),
        icon: FLucideIcons.image,
      ),
      _contextItem(
        title: 'examples.foundation.layout.grid.playground.items.theme_guide'
            .tr(),
        description: 'examples.foundation.layout.grid.playground.items.theme_guide_description'
            .tr(),
        icon: FLucideIcons.palette,
      ),
      _contextItem(
        title: 'examples.foundation.layout.grid.playground.items.icon_library'
            .tr(),
        description: 'examples.foundation.layout.grid.playground.items.icon_library_description'
            .tr(),
        icon: FLucideIcons.layoutGrid,
      ),
    ],
    _GridScenario.statusPanel => [
      _targetItem(
        title: 'examples.foundation.layout.grid.playground.items.pending'.tr(),
        description: 'examples.foundation.layout.grid.playground.items.pending_description'
            .tr(),
        icon: FLucideIcons.bell,
      ),
      _contextItem(
        title: 'examples.foundation.layout.grid.playground.items.messages'.tr(),
        description: 'examples.foundation.layout.grid.playground.items.messages_description'
            .tr(),
        icon: FLucideIcons.messageCircle,
        badge: FBadge(child: const Text('8')),
        badgeSemantics: '8 条未读消息',
      ),
      _contextItem(
        title: 'examples.foundation.layout.grid.playground.items.completed'
            .tr(),
        description: 'examples.foundation.layout.grid.playground.items.completed_description'
            .tr(),
        icon: FLucideIcons.circleCheck,
        selected: true,
      ),
      _contextItem(
        title: 'examples.foundation.layout.grid.playground.items.disabled'.tr(),
        description: 'examples.foundation.layout.grid.playground.items.disabled_description'
            .tr(),
        icon: FLucideIcons.lock,
        enabled: false,
      ),
    ],
  };

  AGridItem _targetItem({
    required String title,
    required IconData icon,
    String? description,
  }) => AGridItem(
    key: const ValueKey('grid-preview-target'),
    visual: _targetVisual(icon),
    title: Text(title),
    description: description == null ? null : Text(description),
    badge: _targetBadge,
    layout: _layout,
    enabled: _enabled,
    selected: _selected,
    semanticsLabel: _itemSemanticsLabel(
      title,
      description,
      visualLabel: _visual == _GridVisual.custom
          ? '${12 + _actionCount}'
          : null,
    ),
    semanticsHint: _enabled
        ? 'examples.foundation.layout.grid.playground.activate_hint'.tr()
        : null,
    badgeSemanticsLabel: _badge == _GridBadge.none
        ? null
        : 'examples.foundation.layout.grid.playground.badge_semantics'.tr(),
    onPress: () => _activate(title),
  );

  AGridItem _contextItem({
    required String title,
    required IconData icon,
    String? description,
    Widget? badge,
    String? badgeSemantics,
    bool selected = false,
    bool enabled = true,
  }) => AGridItem(
    visual: Icon(icon),
    title: Text(title),
    description: description == null ? null : Text(description),
    badge: badge,
    layout: _layout,
    enabled: enabled,
    selected: selected,
    semanticsLabel: _itemSemanticsLabel(title, description),
    badgeSemanticsLabel: badgeSemantics,
    onPress: () => _activate(title),
  );

  Widget _targetVisual(IconData icon) => switch (_visual) {
    _GridVisual.icon => Icon(icon),
    _GridVisual.image => ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.memory(
        _admin9Thumbnail,
        key: const ValueKey('grid-preview-image'),
        width: 44,
        height: 44,
        fit: BoxFit.cover,
      ),
    ),
    _GridVisual.custom => _MetricVisual(value: '${12 + _actionCount}'),
  };

  Widget? get _targetBadge => switch (_badge) {
    _GridBadge.none => null,
    _GridBadge.count => FBadge(
      key: const ValueKey('grid-preview-badge-count'),
      child: Text('${8 + _actionCount}'),
    ),
    _GridBadge.label => FBadge(
      key: const ValueKey('grid-preview-badge-label'),
      variant: .secondary,
      child: Text('examples.foundation.layout.grid.playground.new_label'.tr()),
    ),
    _GridBadge.dot => const _NotificationDot(),
  };

  String _itemSemanticsLabel(
    String title,
    String? description, {
    String? visualLabel,
  }) => [
    visualLabel,
    title,
    description,
  ].whereType<String>().where((value) => value.isNotEmpty).join('，');
}

class _ChoiceControl<T> extends StatelessWidget {
  const _ChoiceControl({
    required this.value,
    required this.choices,
    required this.onChanged,
    this.label,
  });

  final String? label;
  final T value;
  final List<({T value, String label, Key key})> choices;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: [
      if (label case final label?)
        Text(label, style: context.theme.typography.body.md),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final choice in choices)
            FButton(
              key: choice.key,
              variant: choice.value == value ? .primary : .outline,
              mainAxisSize: MainAxisSize.min,
              selected: choice.value == value,
              onPress: () => onChanged(choice.value),
              child: Text(choice.label),
            ),
        ],
      ),
    ],
  );
}

class _GridSliderControl extends StatelessWidget {
  const _GridSliderControl({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
    this.formatter,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final double step;
  final ValueChanged<double> onChanged;
  final String Function(double value)? formatter;

  @override
  Widget build(BuildContext context) {
    final normalized = (value - min) / (max - min);
    final formatted = formatter?.call(value) ?? value.toStringAsFixed(0);
    return FSlider(
      label: Text('$label：$formatted'),
      control: .liftedContinuous(
        value: FSliderValue(max: normalized),
        stepPercentage: step / (max - min),
        onChange: (next) {
          final raw = min + next.max * (max - min);
          final snapped = (raw / step).round() * step;
          onChanged(snapped.clamp(min, max));
        },
      ),
      semanticFormatterCallback: (sliderValue) {
        final raw = min + sliderValue.max * (max - min);
        final snapped = (raw / step).round() * step;
        return formatter?.call(snapped) ?? snapped.toStringAsFixed(0);
      },
    );
  }
}

class _MetricVisual extends StatelessWidget {
  const _MetricVisual({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) => Text(
    value,
    key: const ValueKey('grid-preview-custom-visual'),
    style: context.theme.typography.body.lg.copyWith(
      color: IconTheme.of(context).color,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _NotificationDot extends StatelessWidget {
  const _NotificationDot();

  @override
  Widget build(BuildContext context) => DecoratedBox(
    key: const ValueKey('grid-preview-badge-dot'),
    decoration: BoxDecoration(
      color: context.theme.colors.destructive,
      shape: BoxShape.circle,
    ),
    child: const SizedBox.square(dimension: 10),
  );
}

final Uint8List _admin9Thumbnail = base64Decode(
  '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',
);
