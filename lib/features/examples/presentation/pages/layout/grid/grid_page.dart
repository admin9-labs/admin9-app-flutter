import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_action_bar.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_preview.dart';
import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/layout/grid/a_grid.dart';
import 'package:admin9_app_flutter/shared/ui/layout/grid/a_grid_badge.dart';
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

enum _GridBadge { none, count, label, dot }

class _GridPageState extends State<GridPage> {
  int _columns = 4;
  double _horizontalGap = 8;
  double _verticalGap = 8;
  double _childAspectRatio = 1;
  double _padding = 0;
  AGridSurface _surface = AGridSurface.transparent;
  _GridBadge _badge = _GridBadge.count;
  bool _enabled = true;
  String? _selectedId;
  int _actionCount = 0;
  String? _status;

  void _activate(String id, String label) {
    final status = 'examples.foundation.layout.grid.playground.action_result'
        .tr(namedArgs: {'label': label, 'count': '${_actionCount + 1}'});
    setState(() {
      _actionCount++;
      _selectedId = id;
      _status = status;
    });
    showFToast(
      context: context,
      title: Text(status),
      icon: const Icon(FLucideIcons.circleCheck),
    );
  }

  void _reset() {
    setState(() {
      _columns = 4;
      _horizontalGap = 8;
      _verticalGap = 8;
      _childAspectRatio = 1;
      _padding = 0;
      _surface = AGridSurface.transparent;
      _badge = _GridBadge.count;
      _enabled = true;
      _selectedId = null;
      _actionCount = 0;
      _status = null;
    });
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
            surface: _surface,
            children: _items,
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
                min: 2,
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
                max: 1.25,
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
              _ChoiceControl<AGridSurface>(
                label: 'examples.foundation.layout.grid.playground.surface'
                    .tr(),
                value: _surface,
                onChanged: (value) => setState(() => _surface = value),
                choices: [
                  (
                    value: AGridSurface.transparent,
                    label: 'examples.foundation.layout.grid.playground.surface_transparent'
                        .tr(),
                    key: const ValueKey('grid-surface-transparent'),
                  ),
                  (
                    value: AGridSurface.muted,
                    label: 'examples.foundation.layout.grid.playground.surface_muted'
                        .tr(),
                    key: const ValueKey('grid-surface-muted'),
                  ),
                  (
                    value: AGridSurface.outlined,
                    label: 'examples.foundation.layout.grid.playground.surface_outlined'
                        .tr(),
                    key: const ValueKey('grid-surface-outlined'),
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
                value: _selectedId == 'scan',
                onChange: (value) =>
                    setState(() => _selectedId = value ? 'scan' : null),
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

  List<AGridItem> get _items => [
    _item(
      id: 'scan',
      label: 'examples.foundation.layout.grid.playground.items.scan'.tr(),
      icon: FLucideIcons.scanLine,
      badge: _targetBadge,
      enabled: _enabled,
      key: const ValueKey('grid-preview-target'),
    ),
    _item(
      id: 'messages',
      label: 'examples.foundation.layout.grid.playground.items.messages'.tr(),
      icon: FLucideIcons.messageCircle,
      badge: AGridBadge.count(
        3,
        semanticsLabel:
            'examples.foundation.layout.grid.playground.badge_count_semantics'
                .tr(namedArgs: {'count': '3'}),
        key: const ValueKey('grid-preview-count-badge'),
      ),
    ),
    _item(
      id: 'pending',
      label: 'examples.foundation.layout.grid.playground.items.pending'.tr(),
      icon: FLucideIcons.bell,
      badge: AGridBadge.dot(
        semanticsLabel:
            'examples.foundation.layout.grid.playground.badge_dot_semantics'
                .tr(),
        key: const ValueKey('grid-preview-dot-badge'),
      ),
    ),
    _item(
      id: 'icons',
      label: 'examples.foundation.layout.grid.playground.items.icon_library'
          .tr(),
      icon: FLucideIcons.layoutGrid,
      badge: AGridBadge.label(
        'examples.foundation.layout.grid.playground.new_label'.tr(),
        key: const ValueKey('grid-preview-label-badge'),
      ),
    ),
    _item(
      id: 'share',
      label: 'examples.foundation.layout.grid.playground.items.share'.tr(),
      icon: FLucideIcons.share2,
    ),
    _item(
      id: 'favorite',
      label: 'examples.foundation.layout.grid.playground.items.favorite'.tr(),
      icon: FLucideIcons.heart,
    ),
    _item(
      id: 'settings',
      label: 'examples.foundation.layout.grid.playground.items.settings'.tr(),
      icon: FLucideIcons.settings,
    ),
    _item(
      id: 'disabled',
      label: 'examples.foundation.layout.grid.playground.items.disabled'.tr(),
      icon: FLucideIcons.lock,
      enabled: false,
    ),
  ];

  AGridBadge? get _targetBadge => switch (_badge) {
    _GridBadge.none => null,
    _GridBadge.count => AGridBadge.count(
      8,
      semanticsLabel:
          'examples.foundation.layout.grid.playground.badge_count_semantics'.tr(
            namedArgs: {'count': '8'},
          ),
      key: const ValueKey('grid-preview-target-count-badge'),
    ),
    _GridBadge.label => AGridBadge.label(
      'examples.foundation.layout.grid.playground.new_label'.tr(),
      key: const ValueKey('grid-preview-target-label-badge'),
    ),
    _GridBadge.dot => AGridBadge.dot(
      semanticsLabel:
          'examples.foundation.layout.grid.playground.badge_dot_semantics'.tr(),
      key: const ValueKey('grid-preview-target-dot-badge'),
    ),
  };

  AGridItem _item({
    required String id,
    required String label,
    required IconData icon,
    AGridBadge? badge,
    bool enabled = true,
    Key? key,
  }) => AGridItem(
    key: key,
    icon: Icon(icon, key: ValueKey('grid-preview-icon-$id')),
    label: Text(label),
    badge: badge,
    enabled: enabled,
    selected: _selectedId == id,
    semanticsLabel: label,
    semanticsHint: enabled
        ? 'examples.foundation.layout.grid.playground.activate_hint'.tr()
        : null,
    onPress: () => _activate(id, label),
  );
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
