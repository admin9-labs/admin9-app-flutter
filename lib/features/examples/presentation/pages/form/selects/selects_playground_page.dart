import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_action_bar.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_preview.dart';
import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

enum _SelectPreviewState { ready, loading, error }

@RoutePage()
class SelectsPlaygroundPage extends StatefulWidget {
  const SelectsPlaygroundPage({super.key});

  @override
  State<SelectsPlaygroundPage> createState() => _SelectsPlaygroundPageState();
}

class _SelectsPlaygroundPageState extends State<SelectsPlaygroundPage> {
  final _formKey = GlobalKey<FormState>();
  _SelectPreviewState _previewState = _SelectPreviewState.ready;
  String? _priority = 'medium';
  String? _searchPriority;
  Set<String> _channels = {'email'};
  bool _enabled = true;
  bool _clearable = true;
  String _status = 'examples.forms.playgrounds.common.ready'.tr();

  Future<Iterable<String>> _filter(
    Map<String, String> labels,
    String query,
  ) async {
    if (_previewState == _SelectPreviewState.loading) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
    } else if (_previewState == _SelectPreviewState.error) {
      await Future<void>.delayed(const Duration(milliseconds: 25));
      throw StateError('configured preview failure');
    }
    return labels.keys.where((value) => labels[value]!.contains(query));
  }

  void _save() {
    final valid = _formKey.currentState?.validate() ?? false;
    if (valid) _formKey.currentState?.save();
    setState(() {
      _status = valid
          ? 'examples.forms.playgrounds.selects.saved'.tr()
          : 'examples.forms.playgrounds.selects.validation_failed'.tr();
    });
  }

  void _reset() => setState(() {
    _previewState = _SelectPreviewState.ready;
    _priority = 'medium';
    _searchPriority = null;
    _channels = {'email'};
    _enabled = true;
    _clearable = true;
    _formKey.currentState?.reset();
    _status = 'examples.forms.playgrounds.common.reset_done'.tr();
  });

  @override
  Widget build(BuildContext context) {
    final priorities = <String, String>{
      'examples.forms.playgrounds.selects.priority.low'.tr(): 'low',
      'examples.forms.playgrounds.selects.priority.medium'.tr(): 'medium',
      'examples.forms.playgrounds.selects.priority.high'.tr(): 'high',
    };
    final priorityLabels = {
      for (final entry in priorities.entries) entry.value: entry.key,
    };
    final channels = <String, String>{
      'examples.forms.playgrounds.selects.channel.email'.tr(): 'email',
      'examples.forms.playgrounds.selects.channel.push'.tr(): 'push',
      'examples.forms.playgrounds.selects.channel.sms'.tr(): 'sms',
    };
    final channelLabels = {
      for (final entry in channels.entries) entry.value: entry.key,
    };

    return FScaffold(
      childPad: false,
      header: FHeader.nested(
        title: Text('examples.forms.playgrounds.selects.title'.tr()),
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
                key: const ValueKey('selects-preview-ready'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 14,
                children: [
                  Text('examples.forms.playgrounds.selects.scenario'.tr()),
                  if (_previewState == _SelectPreviewState.loading)
                    const Center(
                      key: ValueKey('selects-preview-loading'),
                      child: FCircularProgress(),
                    )
                  else if (_previewState == _SelectPreviewState.error)
                    FAlert(
                      key: const ValueKey('selects-preview-error'),
                      variant: .destructive,
                      icon: const Icon(FLucideIcons.triangleAlert),
                      title: Text(
                        'examples.forms.playgrounds.selects.error_title'.tr(),
                      ),
                      subtitle: Text(
                        'examples.forms.playgrounds.selects.error_description'
                            .tr(),
                      ),
                    ),
                  FSelect<String>.rich(
                    key: const ValueKey('selects-priority'),
                    control: .lifted(
                      value: _priority,
                      onChange: (value) => setState(() => _priority = value),
                    ),
                    format: (value) => priorityLabels[value] ?? value,
                    enabled: _enabled,
                    clearable: _clearable,
                    validator: (value) => value == null
                        ? 'examples.forms.playgrounds.selects.validation_failed'
                              .tr()
                        : null,
                    formFieldKey: const ValueKey('selects-priority-form-field'),
                    label: Text(
                      'examples.forms.playgrounds.selects.priority'.tr(),
                    ),
                    hint: 'examples.forms.playgrounds.selects.priority_hint'
                        .tr(),
                    children: [
                      .section(
                        label: Text(
                          'examples.forms.playgrounds.selects.priority'.tr(),
                        ),
                        items: priorities,
                      ),
                    ],
                  ),
                  FSelect<String>.search(
                    items: priorities,
                    key: const ValueKey('selects-search-priority'),
                    control: .lifted(
                      value: _searchPriority,
                      onChange: (value) =>
                          setState(() => _searchPriority = value),
                    ),
                    enabled: _enabled,
                    clearable: _clearable,
                    label: Text(
                      'examples.forms.playgrounds.selects.search_priority'.tr(),
                    ),
                    hint: 'examples.forms.playgrounds.selects.priority_hint'
                        .tr(),
                    filter: (query) => _filter(priorityLabels, query),
                    contentLoadingBuilder: (context, style) => Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'examples.forms.playgrounds.selects.state.loading'.tr(),
                        key: const ValueKey('selects-search-loading'),
                      ),
                    ),
                    contentErrorBuilder: (context, error, stackTrace) => Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'examples.forms.playgrounds.selects.error_description'
                            .tr(),
                        key: const ValueKey('selects-search-error'),
                      ),
                    ),
                  ),
                  FMultiSelect<String>.search(
                    channels,
                    key: const ValueKey('selects-channels'),
                    control: .lifted(
                      value: _channels,
                      onChange: (value) => setState(() => _channels = value),
                    ),
                    enabled: _enabled,
                    clearable: _clearable,
                    validator: (values) => values.isEmpty
                        ? 'examples.forms.playgrounds.selects.validation_failed'
                              .tr()
                        : null,
                    formFieldKey: const ValueKey('selects-channels-form-field'),
                    label: Text(
                      'examples.forms.playgrounds.selects.channels'.tr(),
                    ),
                    hint: Text(
                      'examples.forms.playgrounds.selects.channels_hint'.tr(),
                    ),
                    filter: (query) => _filter(channelLabels, query),
                    contentLoadingBuilder: (context, style) => Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'examples.forms.playgrounds.selects.state.loading'.tr(),
                        key: const ValueKey('multi-select-loading'),
                      ),
                    ),
                    contentErrorBuilder: (context, error, stackTrace) => Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'examples.forms.playgrounds.selects.error_description'
                            .tr(),
                        key: const ValueKey('multi-select-error'),
                      ),
                    ),
                  ),
                  FButton(
                    key: const ValueKey('selects-save'),
                    onPress: _enabled ? _save : null,
                    child: Text('examples.forms.playgrounds.selects.save'.tr()),
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
                Text('examples.forms.playgrounds.selects.preview_state'.tr()),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final state in _SelectPreviewState.values)
                      FButton(
                        key: ValueKey('selects-state-${state.name}'),
                        variant: .outline,
                        selected: _previewState == state,
                        mainAxisSize: .min,
                        onPress: () => setState(() => _previewState = state),
                        child: Text(_stateLabel(state)),
                      ),
                  ],
                ),
                FSwitch(
                  label: Text('examples.forms.playgrounds.common.enabled'.tr()),
                  value: _enabled,
                  onChange: (value) => setState(() => _enabled = value),
                ),
                FSwitch(
                  label: Text(
                    'examples.forms.playgrounds.selects.clearable'.tr(),
                  ),
                  value: _clearable,
                  onChange: (value) => setState(() => _clearable = value),
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
}

String _stateLabel(_SelectPreviewState state) => switch (state) {
  _SelectPreviewState.ready =>
    'examples.forms.playgrounds.selects.state.ready'.tr(),
  _SelectPreviewState.loading =>
    'examples.forms.playgrounds.selects.state.loading'.tr(),
  _SelectPreviewState.error =>
    'examples.forms.playgrounds.selects.state.error'.tr(),
};
