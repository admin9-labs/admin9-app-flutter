import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_action_bar.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_clipboard.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_code_panel.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_preview.dart';
import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class SelectionControlsPlaygroundPage extends StatefulWidget {
  const SelectionControlsPlaygroundPage({super.key});

  @override
  State<SelectionControlsPlaygroundPage> createState() =>
      _SelectionControlsPlaygroundPageState();
}

class _SelectionControlsPlaygroundPageState
    extends State<SelectionControlsPlaygroundPage> {
  final _formKey = GlobalKey<FormState>();
  bool _enabled = true;
  bool _updates = true;
  bool _marketing = false;
  bool _showError = false;
  bool _leadingLabels = true;
  Set<String> _frequency = {'daily'};
  Set<String> _channels = {'email'};
  String _status = 'examples.forms.playgrounds.common.ready'.tr();

  String get _summary =>
      'enabled: $_enabled, updates: $_updates, marketing: $_marketing, '
      'frequency: ${_frequency.single}, channels: ${_channels.join(',')}, '
      'error: $_showError, leadingLabel: $_leadingLabels';

  String get _code =>
      '''FSwitch(
  value: $_updates,
  enabled: $_enabled,
  leadingLabel: $_leadingLabels,
  onChange: updatePreference,
)''';

  void _save() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (valid) _formKey.currentState?.save();
    setState(() {
      _showError = !valid;
      _status = valid
          ? 'examples.forms.playgrounds.selection_controls.saved'.tr()
          : 'examples.forms.playgrounds.selection_controls.validation_failed'
                .tr();
    });
  }

  void _reset() => setState(() {
    _enabled = true;
    _updates = true;
    _marketing = false;
    _showError = false;
    _leadingLabels = true;
    _frequency = {'daily'};
    _channels = {'email'};
    _formKey.currentState?.reset();
    _status = 'examples.forms.playgrounds.common.reset_done'.tr();
  });

  Future<void> _copy() => copyPlaygroundText(
    context,
    text: _code,
    title: 'examples.forms.playgrounds.common.copied'.tr(),
    description: 'examples.forms.playgrounds.common.copied_description'.tr(),
  );

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('examples.forms.playgrounds.selection_controls.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
    ),
    child: ResponsivePageBody(
      children: [
        PlaygroundPreview(
          title: 'examples.forms.playgrounds.common.preview'.tr(),
          status: _status,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                Text(
                  'examples.forms.playgrounds.selection_controls.scenario'.tr(),
                ),
                FSwitch(
                  key: const ValueKey('selection-preview-switch'),
                  leadingLabel: _leadingLabels,
                  label: Text(
                    'examples.forms.playgrounds.selection_controls.updates'
                        .tr(),
                  ),
                  description: Text(
                    'examples.forms.playgrounds.selection_controls.updates_description'
                        .tr(),
                  ),
                  value: _updates,
                  enabled: _enabled,
                  semanticsLabel:
                      'examples.forms.playgrounds.selection_controls.updates'
                          .tr(),
                  onChange: (value) => setState(() => _updates = value),
                ),
                FCheckbox(
                  key: const ValueKey('selection-preview-checkbox'),
                  leadingLabel: _leadingLabels,
                  label: Text(
                    'examples.forms.playgrounds.selection_controls.marketing'
                        .tr(),
                  ),
                  description: Text(
                    'examples.forms.playgrounds.selection_controls.optional'
                        .tr(),
                  ),
                  value: _marketing,
                  enabled: _enabled,
                  semanticsLabel:
                      'examples.forms.playgrounds.selection_controls.marketing'
                          .tr(),
                  error: _showError
                      ? Text(
                          'examples.forms.playgrounds.selection_controls.checkbox_error'
                              .tr(),
                        )
                      : null,
                  onChange: (value) => setState(() => _marketing = value),
                ),
                FSelectGroup<String>(
                  key: const ValueKey('selection-radio-group'),
                  control: .lifted(
                    value: _frequency,
                    onChange: (value) => setState(() => _frequency = value),
                  ),
                  enabled: _enabled,
                  validator: (values) => values?.isEmpty ?? true
                      ? 'examples.forms.playgrounds.selection_controls.required'
                            .tr()
                      : null,
                  label: Text(
                    'examples.forms.playgrounds.selection_controls.frequency'
                        .tr(),
                  ),
                  children: [
                    .radio(
                      value: 'daily',
                      label: Text(
                        'examples.forms.playgrounds.selection_controls.daily'
                            .tr(),
                      ),
                    ),
                    .radio(
                      value: 'weekly',
                      label: Text(
                        'examples.forms.playgrounds.selection_controls.weekly'
                            .tr(),
                      ),
                    ),
                    .radio(
                      value: 'important',
                      enabled: false,
                      semanticsLabel: 'examples.forms.playgrounds.selection_controls.important'
                          .tr(),
                      label: Text(
                        'examples.forms.playgrounds.selection_controls.important'
                            .tr(),
                      ),
                    ),
                  ],
                ),
                FSelectGroup<String>(
                  key: const ValueKey('selection-checkbox-group'),
                  control: .lifted(
                    value: _channels,
                    onChange: (value) => setState(() => _channels = value),
                  ),
                  enabled: _enabled,
                  validator: (values) => values?.isEmpty ?? true
                      ? 'examples.forms.playgrounds.selection_controls.required'
                            .tr()
                      : null,
                  label: Text(
                    'examples.forms.playgrounds.selection_controls.channels'
                        .tr(),
                  ),
                  children: [
                    .checkbox(
                      value: 'email',
                      semanticsLabel:
                          'examples.forms.playgrounds.selection_controls.email'
                              .tr(),
                      label: Text(
                        'examples.forms.playgrounds.selection_controls.email'
                            .tr(),
                      ),
                    ),
                    .checkbox(
                      value: 'push',
                      semanticsLabel:
                          'examples.forms.playgrounds.selection_controls.push'
                              .tr(),
                      label: Text(
                        'examples.forms.playgrounds.selection_controls.push'
                            .tr(),
                      ),
                    ),
                    .checkbox(
                      value: 'sms',
                      enabled: false,
                      semanticsLabel:
                          'examples.forms.playgrounds.selection_controls.sms'
                              .tr(),
                      label: Text(
                        'examples.forms.playgrounds.selection_controls.sms'
                            .tr(),
                      ),
                    ),
                  ],
                ),
                FButton(
                  key: const ValueKey('selection-save'),
                  onPress: _enabled ? _save : null,
                  child: Text(
                    'examples.forms.playgrounds.selection_controls.save'.tr(),
                  ),
                ),
              ],
            ),
          ),
        ),
        ComponentExampleSection(
          title: 'examples.forms.playgrounds.common.configuration'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              FSwitch(
                key: const ValueKey('selection-error-toggle'),
                label: Text(
                  'examples.forms.playgrounds.selection_controls.show_error'
                      .tr(),
                ),
                value: _showError,
                onChange: (value) => setState(() => _showError = value),
              ),
              FSwitch(
                key: const ValueKey('selection-enabled-toggle'),
                label: Text('examples.forms.playgrounds.common.enabled'.tr()),
                value: _enabled,
                onChange: (value) => setState(() => _enabled = value),
              ),
              FSwitch(
                label: Text(
                  'examples.forms.playgrounds.selection_controls.leading_labels'
                      .tr(),
                ),
                value: _leadingLabels,
                onChange: (value) => setState(() => _leadingLabels = value),
              ),
            ],
          ),
        ),
        PlaygroundCodePanel(
          title: 'examples.forms.playgrounds.common.current_parameters'.tr(),
          summary: _summary,
          code: _code,
        ),
        PlaygroundActionBar(
          copyLabel: 'examples.forms.playgrounds.common.copy'.tr(),
          resetLabel: 'examples.forms.playgrounds.common.reset'.tr(),
          onCopy: _copy,
          onReset: _reset,
        ),
      ],
    ),
  );
}
