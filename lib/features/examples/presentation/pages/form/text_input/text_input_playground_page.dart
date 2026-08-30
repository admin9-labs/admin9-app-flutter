import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_action_bar.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_clipboard.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_code_panel.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_preview.dart';
import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class TextInputPlaygroundPage extends StatefulWidget {
  const TextInputPlaygroundPage({super.key});

  @override
  State<TextInputPlaygroundPage> createState() =>
      _TextInputPlaygroundPageState();
}

class _TextInputPlaygroundPageState extends State<TextInputPlaygroundPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(
    text: 'examples.forms.playgrounds.text_input.default_name'.tr(),
  );
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();
  final _requiredController = TextEditingController();
  final _otpFocusNode = FocusNode(debugLabel: 'text-input-playground-otp');
  String _size = 'md';
  bool _enabled = true;
  bool _clearable = true;
  bool _multiline = false;
  int _resetGeneration = 0;
  bool _showErrors = false;
  String _savedValue = '';
  String _submittedValue = '';
  String _status = 'examples.forms.playgrounds.common.ready'.tr();

  FTextFieldSizeVariant get _fieldSize => switch (_size) {
    'sm' => .sm,
    'lg' => .lg,
    _ => .md,
  };

  String get _summary =>
      'size: $_size, enabled: $_enabled, clearable: $_clearable, '
      'maxLines: ${_multiline ? 4 : 1}, validation: required';

  String get _code =>
      '''FTextField(
  size: FTextFieldSizeVariant.$_size,
  enabled: $_enabled,
  clearable: ${_clearable ? '(value) => value.text.isNotEmpty' : 'null'},
  maxLines: ${_multiline ? 4 : 1},
  label: Text('${'examples.forms.playgrounds.text_input.name_label'.tr()}'),
)''';

  void _submit() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (valid) _formKey.currentState?.save();
    setState(() {
      _showErrors = !valid;
      _status = valid
          ? 'examples.forms.playgrounds.text_input.saved'.tr()
          : 'examples.forms.playgrounds.text_input.validation_failed'.tr();
    });
  }

  void _reset() => setState(() {
    _formKey.currentState?.reset();
    _nameController.text = 'examples.forms.playgrounds.text_input.default_name'
        .tr();
    _requiredController.clear();
    _emailController.clear();
    _passwordController.clear();
    _bioController.clear();
    _size = 'md';
    _enabled = true;
    _clearable = true;
    _multiline = false;
    _resetGeneration++;
    _showErrors = false;
    _savedValue = '';
    _submittedValue = '';
    _status = 'examples.forms.playgrounds.common.reset_done'.tr();
  });

  Future<void> _copy() => copyPlaygroundText(
    context,
    text: _code,
    title: 'examples.forms.playgrounds.common.copied'.tr(),
    description: 'examples.forms.playgrounds.common.copied_description'.tr(),
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _requiredController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('examples.forms.playgrounds.text_input.title'.tr()),
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
              spacing: 14,
              children: [
                Text('examples.forms.playgrounds.text_input.scenario'.tr()),
                FTextField(
                  key: const ValueKey('text-preview-field'),
                  control: .managed(controller: _nameController),
                  size: _fieldSize,
                  enabled: _enabled,
                  clearable: _clearable
                      ? (value) => value.text.isNotEmpty
                      : (_) => false,
                  label: Text(
                    'examples.forms.playgrounds.text_input.name_label'.tr(),
                  ),
                  description: Text(
                    'examples.forms.playgrounds.text_input.name_description'
                        .tr(),
                  ),
                  maxLines: _multiline ? 4 : 1,
                ),
                FTextField.email(
                  key: const ValueKey('text-email-field'),
                  control: .managed(controller: _emailController),
                  size: _fieldSize,
                  enabled: _enabled,
                  label: Text(
                    'examples.forms.playgrounds.text_input.email_label'.tr(),
                  ),
                  clearable: _clearable
                      ? (value) => value.text.isNotEmpty
                      : (_) => false,
                ),
                FTextField.password(
                  key: const ValueKey('text-password-field'),
                  control: .managed(controller: _passwordController),
                  size: _fieldSize,
                  enabled: _enabled,
                  label: Text(
                    'examples.forms.playgrounds.text_input.password_label'.tr(),
                  ),
                  clearable: _clearable
                      ? (value) => value.text.isNotEmpty
                      : (_) => false,
                ),
                FTextField.multiline(
                  key: const ValueKey('text-multiline-field'),
                  control: .managed(controller: _bioController),
                  size: _fieldSize,
                  enabled: _enabled,
                  label: Text(
                    'examples.forms.playgrounds.text_input.bio_label'.tr(),
                  ),
                  description: Text(
                    'examples.forms.playgrounds.text_input.bio_description'
                        .tr(),
                  ),
                  maxLines: 4,
                ),
                FTextFormField(
                  key: const ValueKey('text-form-field'),
                  control: .managed(controller: _requiredController),
                  size: _fieldSize,
                  enabled: _enabled,
                  label: Text(
                    'examples.forms.playgrounds.text_input.required_label'.tr(),
                  ),
                  hint: 'examples.forms.playgrounds.text_input.required_hint'
                      .tr(),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'examples.forms.playgrounds.text_input.required_error'
                            .tr()
                      : null,
                  onSaved: (value) => _savedValue = value ?? '',
                  onSubmit: (value) => setState(() {
                    _submittedValue = value;
                    _status = 'examples.forms.playgrounds.text_input.keyboard_submitted'
                        .tr();
                  }),
                  textInputAction: TextInputAction.done,
                  autovalidateMode: .onUserInteraction,
                  formFieldKey: const ValueKey('text-form-form-field'),
                ),
                FAutocomplete.text(
                  key: ValueKey('text-autocomplete-$_resetGeneration'),
                  size: _fieldSize,
                  enabled: _enabled,
                  label: Text(
                    'examples.forms.playgrounds.text_input.city_label'.tr(),
                  ),
                  hint: 'examples.forms.playgrounds.text_input.city_hint'.tr(),
                  items: [
                    'examples.forms.playgrounds.text_input.city.chengdu'.tr(),
                    'examples.forms.playgrounds.text_input.city.shanghai'.tr(),
                    'examples.forms.playgrounds.text_input.city.shenzhen'.tr(),
                  ],
                  validator: (value) => value == null || value.isEmpty
                      ? 'examples.forms.playgrounds.text_input.city_error'.tr()
                      : null,
                ),
                Semantics(
                  container: true,
                  label: 'examples.forms.playgrounds.text_input.otp_label'.tr(),
                  child: FOtpField(
                    key: ValueKey('text-otp-$_resetGeneration'),
                    control: const .managed(
                      children: [
                        FOtpItem(),
                        FOtpItem(),
                        FOtpItem(),
                        FOtpDivider(),
                        FOtpItem(),
                        FOtpItem(),
                        FOtpItem(),
                      ],
                    ),
                    enabled: _enabled,
                    focusNode: _otpFocusNode,
                    label: Text(
                      'examples.forms.playgrounds.text_input.otp_label'.tr(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value != null && value.length == 6
                        ? null
                        : 'examples.forms.playgrounds.text_input.otp_error'
                              .tr(),
                    textInputAction: TextInputAction.done,
                    formFieldKey: const ValueKey('text-otp-form-field'),
                  ),
                ),
                FLabel(
                  key: const ValueKey('text-required-label'),
                  layout: .horizontalTrailing,
                  label: Semantics(
                    label: 'examples.forms.playgrounds.text_input.required_semantics'
                        .tr(),
                    child: Text(
                      'examples.forms.playgrounds.text_input.completeness'.tr(),
                    ),
                  ),
                  description: Text(
                    'examples.forms.playgrounds.text_input.completeness_description'
                        .tr(),
                  ),
                  error: _showErrors
                      ? Text(
                          'examples.forms.playgrounds.text_input.required_error'
                              .tr(),
                        )
                      : null,
                  variants: {if (_showErrors) FFormFieldVariant.error},
                  child: const Icon(FLucideIcons.badgeCheck),
                ),
                FButton(
                  key: const ValueKey('text-submit'),
                  onPress: _enabled ? _submit : null,
                  child: Text(
                    'examples.forms.playgrounds.text_input.submit'.tr(),
                  ),
                ),
                Text(_savedValue, key: const ValueKey('text-saved-value')),
                Text(
                  _submittedValue,
                  key: const ValueKey('text-submitted-value'),
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
              Text('examples.forms.playgrounds.text_input.size'.tr()),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final size in const ['sm', 'md', 'lg'])
                    FButton(
                      key: ValueKey('text-size-$size'),
                      variant: .outline,
                      selected: _size == size,
                      mainAxisSize: .min,
                      onPress: () => setState(() => _size = size),
                      child: Text(size.toUpperCase()),
                    ),
                ],
              ),
              FSwitch(
                key: const ValueKey('text-enabled-toggle'),
                label: Text('examples.forms.playgrounds.common.enabled'.tr()),
                value: _enabled,
                onChange: (value) => setState(() => _enabled = value),
              ),
              FSwitch(
                label: Text(
                  'examples.forms.playgrounds.text_input.clearable'.tr(),
                ),
                value: _clearable,
                onChange: (value) => setState(() => _clearable = value),
              ),
              FSwitch(
                label: Text(
                  'examples.forms.playgrounds.text_input.multiline'.tr(),
                ),
                value: _multiline,
                onChange: (value) => setState(() => _multiline = value),
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
