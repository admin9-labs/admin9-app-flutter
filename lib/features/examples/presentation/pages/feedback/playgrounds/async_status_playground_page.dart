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
class AsyncStatusPlaygroundPage extends StatefulWidget {
  const AsyncStatusPlaygroundPage({super.key});

  @override
  State<AsyncStatusPlaygroundPage> createState() =>
      _AsyncStatusPlaygroundPageState();
}

class _AsyncStatusPlaygroundPageState extends State<AsyncStatusPlaygroundPage> {
  final _triggerFocusNode = FocusNode();
  FToasterEntry? _toastEntry;
  FSliderValue _progress = FSliderValue(max: 0.35);
  bool _enabled = true;
  bool _simulateError = false;
  bool _toastAtTop = false;
  bool _shortToast = false;
  bool _largeCircular = false;
  bool _running = false;
  int _operationGeneration = 0;
  String _statusKey = 'examples.feedback.playgrounds.async.status_ready';

  String get _summary =>
      'value: ${_progress.max.toStringAsFixed(2)}, '
      'enabled: $_enabled, error: $_simulateError, '
      'alignment: ${_toastAtTop ? 'topCenter' : 'bottomCenter'}, '
      'duration: ${_shortToast ? '1s' : '5s'}, '
      'circularSize: ${_largeCircular ? 'xl' : 'sm'}';

  String get _code =>
      'FDeterminateProgress(value: ${_progress.max.toStringAsFixed(2)});\n'
      'FCircularProgress(size: FCircularProgressSizeVariant.${_largeCircular ? 'xl' : 'sm'});\n'
      'showFToast(alignment: FToastAlignment.${_toastAtTop ? 'topCenter' : 'bottomCenter'}, '
      'duration: Duration(seconds: ${_shortToast ? 1 : 5}), '
      'variant: ${_simulateError ? 'FToastVariant.destructive' : 'FToastVariant.primary'});';

  Future<void> _run() async {
    if (!_enabled || _running) return;
    final operationGeneration = ++_operationGeneration;
    _triggerFocusNode.requestFocus();

    setState(() {
      _running = true;
      _statusKey = 'examples.feedback.playgrounds.async.status_syncing';
    });
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (!mounted || operationGeneration != _operationGeneration) return;

    final failed = _simulateError;
    setState(() {
      _running = false;
      _statusKey = failed
          ? 'examples.feedback.playgrounds.async.status_error'
          : 'examples.feedback.playgrounds.async.status_success';
      if (!failed) {
        _progress = FSliderValue(max: 1);
      }
    });
    _toastEntry?.dismiss();
    _toastEntry = showFToast(
      context: context,
      alignment: _toastAtTop ? .topCenter : .bottomCenter,
      variant: failed ? .destructive : .primary,
      duration: Duration(seconds: _shortToast ? 1 : 5),
      icon: Icon(
        failed ? FLucideIcons.triangleAlert : FLucideIcons.circleCheck,
      ),
      title: Text(
        (failed
                ? 'examples.feedback.playgrounds.async.toast_error_title'
                : 'examples.feedback.playgrounds.async.toast_success_title')
            .tr(),
      ),
      description: Text(_statusKey.tr()),
      suffixBuilder: (_, entry) => FButton.icon(
        key: const ValueKey('async-toast-dismiss'),
        variant: .ghost,
        size: .sm,
        semanticsLabel: 'examples.feedback.playgrounds.async.toast_dismiss'
            .tr(),
        onPress: entry.dismiss,
        child: const Icon(FLucideIcons.x),
      ),
      onDismiss: () {
        _toastEntry = null;
        if (mounted) _triggerFocusNode.requestFocus();
      },
    );
  }

  void _reset() {
    _operationGeneration++;
    _toastEntry?.dismiss();
    setState(() {
      _progress = FSliderValue(max: 0.35);
      _enabled = true;
      _simulateError = false;
      _toastAtTop = false;
      _shortToast = false;
      _largeCircular = false;
      _running = false;
      _statusKey = 'examples.feedback.playgrounds.async.status_ready';
    });
  }

  Future<void> _copy() => copyPlaygroundText(
    context,
    text: _code,
    title: 'examples.feedback.playgrounds.common.copied_title'.tr(),
    description: 'examples.feedback.playgrounds.common.copied_description'.tr(),
  );

  @override
  void dispose() {
    _triggerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('examples.feedback.playgrounds.async.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'examples.feedback.playgrounds.common.configuration'.tr(),
          child: Column(
            spacing: 16,
            children: [
              FSlider(
                key: const ValueKey('async-progress-control'),
                label: Text(
                  'examples.feedback.playgrounds.async.progress_label'.tr(),
                ),
                enabled: _enabled && !_running,
                control: .liftedContinuous(
                  value: _progress,
                  onChange: (value) => setState(() => _progress = value),
                  stepPercentage: 0.05,
                ),
                semanticFormatterCallback: (value) =>
                    '${(value.max * 100).round()}%',
              ),
              FSwitch(
                key: const ValueKey('async-error-control'),
                label: Text(
                  'examples.feedback.playgrounds.async.error_mode'.tr(),
                ),
                value: _simulateError,
                enabled: !_running,
                onChange: (value) => setState(() => _simulateError = value),
              ),
              FSwitch(
                key: const ValueKey('async-enabled-control'),
                label: Text(
                  'examples.feedback.playgrounds.common.enabled'.tr(),
                ),
                value: _enabled,
                enabled: !_running,
                onChange: (value) => setState(() => _enabled = value),
              ),
              FSwitch(
                key: const ValueKey('async-toast-top-control'),
                label: Text(
                  'examples.feedback.playgrounds.async.toast_top'.tr(),
                ),
                value: _toastAtTop,
                enabled: !_running,
                onChange: (value) => setState(() => _toastAtTop = value),
              ),
              FSwitch(
                key: const ValueKey('async-toast-short-control'),
                label: Text(
                  'examples.feedback.playgrounds.async.toast_short'.tr(),
                ),
                value: _shortToast,
                enabled: !_running,
                onChange: (value) => setState(() => _shortToast = value),
              ),
              FSwitch(
                key: const ValueKey('async-circular-size-control'),
                label: Text(
                  'examples.feedback.playgrounds.async.circular_large'.tr(),
                ),
                value: _largeCircular,
                enabled: !_running,
                onChange: (value) => setState(() => _largeCircular = value),
              ),
            ],
          ),
        ),
        PlaygroundPreview(
          title: 'examples.feedback.playgrounds.common.preview'.tr(),
          status: _statusKey.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              FAlert(
                key: const ValueKey('async-alert'),
                variant: _simulateError ? .destructive : .primary,
                liveRegion: _running,
                icon: Icon(
                  _simulateError
                      ? FLucideIcons.triangleAlert
                      : FLucideIcons.cloudUpload,
                ),
                title: Text(
                  (_simulateError
                          ? 'examples.feedback.playgrounds.async.alert_error'
                          : 'examples.feedback.playgrounds.async.alert_ready')
                      .tr(),
                ),
                subtitle: Text(_statusKey.tr()),
              ),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FCircularProgress(
                    key: const ValueKey('async-circular-progress'),
                    size: _largeCircular ? .xl : .sm,
                    semanticsLabel:
                        'examples.feedback.playgrounds.async.circular_semantics'
                            .tr(),
                  ),
                  Text('${(_progress.max * 100).round()}%'),
                ],
              ),
              FDeterminateProgress(
                key: const ValueKey('async-determinate-progress'),
                value: _progress.max,
                semanticsLabel:
                    'examples.feedback.playgrounds.async.determinate_semantics'
                        .tr(),
              ),
              FProgress(
                key: const ValueKey('async-indeterminate-progress'),
                semanticsLabel: 'examples.feedback.playgrounds.async.indeterminate_semantics'
                    .tr(),
              ),
              FButton(
                key: const ValueKey('async-run'),
                focusNode: _triggerFocusNode,
                onPress: _enabled && !_running ? _run : null,
                onDisabledPress: _running ? () {} : null,
                prefix: _running
                    ? const FCircularProgress(size: .sm)
                    : const Icon(FLucideIcons.refreshCw),
                child: Text(
                  (_running
                          ? 'examples.feedback.playgrounds.async.running'
                          : 'examples.feedback.playgrounds.async.run')
                      .tr(),
                ),
              ),
            ],
          ),
        ),
        PlaygroundCodePanel(
          title: 'examples.feedback.playgrounds.common.usage'.tr(),
          summary: _summary,
          code: _code,
        ),
        PlaygroundActionBar(
          copyLabel: 'examples.feedback.playgrounds.common.copy'.tr(),
          resetLabel: 'examples.feedback.playgrounds.common.reset'.tr(),
          onCopy: _copy,
          onReset: _reset,
        ),
      ],
    ),
  );
}
