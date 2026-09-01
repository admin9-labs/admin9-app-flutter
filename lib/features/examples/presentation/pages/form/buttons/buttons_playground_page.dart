import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_action_bar.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_preview.dart';
import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class ButtonsPlaygroundPage extends StatefulWidget {
  const ButtonsPlaygroundPage({super.key});

  @override
  State<ButtonsPlaygroundPage> createState() => _ButtonsPlaygroundPageState();
}

class _ButtonsPlaygroundPageState extends State<ButtonsPlaygroundPage> {
  String _kind = 'standard';
  String _variant = 'primary';
  String _size = 'md';
  bool _enabled = true;
  bool _selected = false;
  bool _loading = false;
  bool _withIcons = true;
  bool _expanded = true;
  String _status = 'examples.forms.playgrounds.common.ready'.tr();

  FButtonVariant get _buttonVariant => switch (_variant) {
    'secondary' => .secondary,
    'destructive' => .destructive,
    'outline' => .outline,
    'ghost' => .ghost,
    _ => .primary,
  };

  FButtonSizeVariant get _buttonSize => switch (_size) {
    'xs' => .xs,
    'sm' => .sm,
    'lg' => .lg,
    _ => .md,
  };

  void _reset() => setState(() {
    _kind = 'standard';
    _variant = 'primary';
    _size = 'md';
    _enabled = true;
    _selected = false;
    _loading = false;
    _withIcons = true;
    _expanded = true;
    _status = 'examples.forms.playgrounds.common.reset_done'.tr();
  });

  void _publish() => setState(() {
    _selected = !_selected;
    _status = _selected
        ? 'examples.forms.playgrounds.buttons.published'.tr()
        : 'examples.forms.playgrounds.buttons.unselected'.tr();
  });

  Widget _buildPreviewButton() {
    final onPress = _enabled && !_loading ? _publish : null;
    final label = 'examples.forms.playgrounds.buttons.publish'.tr();

    return switch (_kind) {
      'icon' => FButton.icon(
        key: const ValueKey('buttons-preview-button'),
        variant: _buttonVariant,
        size: _buttonSize,
        selected: _selected,
        semanticsLabel: label,
        onPress: onPress,
        child: _loading
            ? const FCircularProgress(key: ValueKey('buttons-progress'))
            : const Icon(
                FLucideIcons.send,
                key: ValueKey('buttons-preview-icon'),
              ),
      ),
      'raw' => FButton.raw(
        key: const ValueKey('buttons-preview-button'),
        variant: _buttonVariant,
        size: _buttonSize,
        selected: _selected,
        semanticsLabel: label,
        onPress: onPress,
        child: Padding(
          key: const ValueKey('buttons-preview-raw'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 8,
            children: [
              if (_loading)
                const FCircularProgress(key: ValueKey('buttons-progress'))
              else if (_withIcons)
                const Icon(FLucideIcons.send),
              Text(label),
            ],
          ),
        ),
      ),
      _ => FButton(
        key: const ValueKey('buttons-preview-button'),
        variant: _buttonVariant,
        size: _buttonSize,
        selected: _selected,
        semanticsLabel: label,
        mainAxisSize: _expanded ? .max : .min,
        prefix: _loading
            ? const FCircularProgress(key: ValueKey('buttons-progress'))
            : _withIcons
            ? const Icon(FLucideIcons.send, key: ValueKey('buttons-prefix'))
            : null,
        suffix: _withIcons && !_loading
            ? const Icon(
                FLucideIcons.chevronRight,
                key: ValueKey('buttons-suffix'),
              )
            : null,
        onPress: onPress,
        child: Text(
          _loading
              ? 'examples.forms.playgrounds.buttons.publishing'.tr()
              : label,
          key: const ValueKey('buttons-preview-standard'),
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('examples.forms.playgrounds.buttons.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
    ),
    child: ResponsivePageBody(
      children: [
        PlaygroundPreview(
          title: 'examples.forms.playgrounds.common.preview'.tr(),
          status: _status,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Text('examples.forms.playgrounds.buttons.scenario'.tr()),
              if (_expanded && _kind == 'standard')
                _buildPreviewButton()
              else
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _buildPreviewButton(),
                ),
            ],
          ),
        ),
        ComponentExampleSection(
          title: 'examples.forms.playgrounds.common.configuration'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              _Options(
                label: 'examples.forms.playgrounds.buttons.kind'.tr(),
                values: [
                  (
                    'standard',
                    'examples.forms.playgrounds.buttons.kind.standard'.tr(),
                  ),
                  ('icon', 'examples.forms.playgrounds.buttons.kind.icon'.tr()),
                  ('raw', 'examples.forms.playgrounds.buttons.kind.raw'.tr()),
                ],
                selected: _kind,
                keyPrefix: 'buttons-kind',
                onChanged: (value) => setState(() => _kind = value),
              ),
              _Options(
                label: 'examples.forms.playgrounds.buttons.variant'.tr(),
                values: [
                  (
                    'primary',
                    'examples.forms.playgrounds.buttons.variant.primary'.tr(),
                  ),
                  (
                    'secondary',
                    'examples.forms.playgrounds.buttons.variant.secondary'.tr(),
                  ),
                  (
                    'destructive',
                    'examples.forms.playgrounds.buttons.variant.destructive'
                        .tr(),
                  ),
                  (
                    'outline',
                    'examples.forms.playgrounds.buttons.variant.outline'.tr(),
                  ),
                  (
                    'ghost',
                    'examples.forms.playgrounds.buttons.variant.ghost'.tr(),
                  ),
                ],
                selected: _variant,
                keyPrefix: 'buttons-variant',
                onChanged: (value) => setState(() => _variant = value),
              ),
              _Options(
                label: 'examples.forms.playgrounds.buttons.size'.tr(),
                values: const [
                  ('xs', 'XS'),
                  ('sm', 'SM'),
                  ('md', 'MD'),
                  ('lg', 'LG'),
                ],
                selected: _size,
                keyPrefix: 'buttons-size',
                onChanged: (value) => setState(() => _size = value),
              ),
              FSwitch(
                key: const ValueKey('buttons-enabled-toggle'),
                label: Text('examples.forms.playgrounds.common.enabled'.tr()),
                value: _enabled,
                onChange: (value) => setState(() => _enabled = value),
              ),
              FSwitch(
                key: const ValueKey('buttons-loading-toggle'),
                label: Text('examples.forms.playgrounds.buttons.loading'.tr()),
                value: _loading,
                onChange: (value) => setState(() => _loading = value),
              ),
              FSwitch(
                key: const ValueKey('buttons-icons-toggle'),
                label: Text('examples.forms.playgrounds.buttons.icons'.tr()),
                value: _withIcons,
                onChange: (value) => setState(() => _withIcons = value),
              ),
              FSwitch(
                key: const ValueKey('buttons-expanded-toggle'),
                label: Text('examples.forms.playgrounds.buttons.expanded'.tr()),
                value: _expanded,
                onChange: (value) => setState(() => _expanded = value),
              ),
            ],
          ),
        ),
        PlaygroundActionBar(
          resetLabel: 'examples.forms.playgrounds.common.reset'.tr(),
          onReset: _reset,
        ),
      ],
    ),
  );
}

class _Options extends StatelessWidget {
  const _Options({
    required this.label,
    required this.values,
    required this.selected,
    required this.keyPrefix,
    required this.onChanged,
  });

  final String label;
  final List<(String, String)> values;
  final String selected;
  final String keyPrefix;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: [
      Text(label),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final (value, text) in values)
            FButton(
              key: ValueKey('$keyPrefix-$value'),
              variant: .outline,
              selected: selected == value,
              mainAxisSize: .min,
              onPress: () => onChanged(value),
              child: Text(text),
            ),
        ],
      ),
    ],
  );
}
