import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_action_bar.dart';
import 'package:admin9_app_flutter/features/examples/presentation/widgets/playground_preview.dart';
import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

enum _ConfirmationMode { dialog, sheet, persistentSheet }

@RoutePage()
class ConfirmationPlaygroundPage extends StatefulWidget {
  const ConfirmationPlaygroundPage({super.key});

  @override
  State<ConfirmationPlaygroundPage> createState() =>
      _ConfirmationPlaygroundPageState();
}

class _ConfirmationPlaygroundPageState
    extends State<ConfirmationPlaygroundPage> {
  final _modeController = FMultiValueNotifier<_ConfirmationMode>.radio(
    _ConfirmationMode.dialog,
  );
  final _triggerFocusNode = FocusNode();
  _ConfirmationMode _mode = _ConfirmationMode.dialog;
  TextEditingValue _draft = const TextEditingValue(text: 'Admin9 Starter');
  FPersistentSheetController? _persistentController;
  bool _enabled = true;
  int _underlyingPresses = 0;
  String _statusKey = 'examples.feedback.playgrounds.confirmation.status_ready';

  @override
  void dispose() {
    _persistentController?.dispose();
    _modeController.dispose();
    _triggerFocusNode.dispose();
    super.dispose();
  }

  Future<void> _open(BuildContext overlayContext) async {
    if (!_enabled) return;
    _triggerFocusNode.requestFocus();

    switch (_mode) {
      case _ConfirmationMode.dialog:
        final confirmed = await showFDialog<bool>(
          context: overlayContext,
          useSafeArea: true,
          barrierDismissible: true,
          barrierLabel:
              'examples.feedback.playgrounds.confirmation.dialog_semantics'
                  .tr(),
          builder: (dialogContext, _, animation) => FDialog.adaptive(
            key: const ValueKey('confirmation-dialog'),
            animation: animation,
            semanticsLabel:
                'examples.feedback.playgrounds.confirmation.dialog_semantics'
                    .tr(),
            verticalBuilder: (context, style) => _ConfirmationDialogContent(
              key: const ValueKey('confirmation-dialog-vertical'),
              style: style,
              horizontal: false,
              onCancel: () => Navigator.of(dialogContext).pop(false),
              onConfirm: () => Navigator.of(dialogContext).pop(true),
            ),
            horizontalBuilder: (context, style) => _ConfirmationDialogContent(
              key: const ValueKey('confirmation-dialog-horizontal'),
              style: style,
              horizontal: true,
              onCancel: () => Navigator.of(dialogContext).pop(false),
              onConfirm: () => Navigator.of(dialogContext).pop(true),
            ),
          ),
        );
        if (!mounted) return;
        setState(
          () => _statusKey = confirmed == true
              ? 'examples.feedback.playgrounds.confirmation.status_confirmed'
              : 'examples.feedback.playgrounds.confirmation.status_cancelled',
        );

      case _ConfirmationMode.sheet:
        final savedDraft = await showFSheet<TextEditingValue>(
          context: overlayContext,
          side: .btt,
          useSafeArea: true,
          barrierDismissible: true,
          builder: (sheetContext) => _EditSheet(
            value: _draft,
            onCancel: () => Navigator.of(sheetContext).pop(),
            onSave: (value) => Navigator.of(sheetContext).pop(value),
          ),
        );
        if (!mounted) return;
        setState(() {
          if (savedDraft != null) _draft = savedDraft;
          _statusKey = savedDraft != null
              ? 'examples.feedback.playgrounds.confirmation.status_saved'
              : 'examples.feedback.playgrounds.confirmation.status_cancelled';
        });

      case _ConfirmationMode.persistentSheet:
        final controller = _persistentController;
        if (controller == null) {
          _persistentController = showFPersistentSheet(
            context: overlayContext,
            side: .btt,
            useSafeArea: true,
            mainAxisMaxRatio: 0.4,
            builder: (sheetContext, controller) =>
                _PersistentContent(onClose: controller.hide),
          );
        } else {
          controller.toggle();
        }
        setState(
          () => _statusKey =
              'examples.feedback.playgrounds.confirmation.status_persistent',
        );
    }
  }

  void _reset() {
    _persistentController?.hide();
    _modeController.value = {_ConfirmationMode.dialog};
    setState(() {
      _mode = _ConfirmationMode.dialog;
      _draft = const TextEditingValue(text: 'Admin9 Starter');
      _enabled = true;
      _underlyingPresses = 0;
      _statusKey = 'examples.feedback.playgrounds.confirmation.status_ready';
    });
  }

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('examples.feedback.playgrounds.confirmation.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'examples.feedback.playgrounds.common.configuration'.tr(),
          child: Column(
            spacing: 16,
            children: [
              FSelectGroup<_ConfirmationMode>(
                key: const ValueKey('confirmation-mode-control'),
                control: .managedRadio(
                  controller: _modeController,
                  onChange: (values) {
                    if (values.isNotEmpty) {
                      setState(() => _mode = values.single);
                    }
                  },
                ),
                children: [
                  .radio(
                    value: _ConfirmationMode.dialog,
                    label: Text(
                      'examples.feedback.playgrounds.confirmation.mode_dialog'
                          .tr(),
                    ),
                  ),
                  .radio(
                    value: _ConfirmationMode.sheet,
                    label: Text(
                      'examples.feedback.playgrounds.confirmation.mode_sheet'
                          .tr(),
                    ),
                  ),
                  .radio(
                    value: _ConfirmationMode.persistentSheet,
                    label: Text(
                      'examples.feedback.playgrounds.confirmation.mode_persistent'
                          .tr(),
                    ),
                  ),
                ],
              ),
              FSwitch(
                key: const ValueKey('confirmation-enabled-control'),
                label: Text(
                  'examples.feedback.playgrounds.common.enabled'.tr(),
                ),
                value: _enabled,
                onChange: (value) => setState(() => _enabled = value),
              ),
            ],
          ),
        ),
        PlaygroundPreview(
          title: 'examples.feedback.playgrounds.common.preview'.tr(),
          status: _statusKey.tr(),
          child: Builder(
            builder: (overlayContext) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FButton(
                  key: const ValueKey('confirmation-open'),
                  focusNode: _triggerFocusNode,
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: _enabled ? () => _open(overlayContext) : null,
                  prefix: const Icon(FLucideIcons.squarePen),
                  child: Text(
                    'examples.feedback.playgrounds.confirmation.open'.tr(),
                  ),
                ),
                FButton(
                  key: const ValueKey('confirmation-underlying-action'),
                  variant: .ghost,
                  mainAxisSize: .min,
                  onPress: () => setState(() => _underlyingPresses++),
                  child: Text(
                    'examples.feedback.playgrounds.confirmation.underlying_action'
                        .tr(),
                  ),
                ),
              ],
            ),
          ),
        ),
        PlaygroundActionBar(
          resetLabel: 'examples.feedback.playgrounds.common.reset'.tr(),
          onReset: _reset,
        ),
      ],
    ),
  );
}

class _ConfirmationDialogContent extends StatelessWidget {
  const _ConfirmationDialogContent({
    super.key,
    required this.style,
    required this.horizontal,
    required this.onCancel,
    required this.onConfirm,
  });

  final FDialogStyle style;
  final bool horizontal;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final copy = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text(
          'examples.feedback.playgrounds.confirmation.dialog_title'.tr(),
          style: style.titleTextStyle,
        ),
        Text(
          'examples.feedback.playgrounds.confirmation.dialog_body'.tr(),
          style: style.bodyTextStyle,
        ),
      ],
    );
    final actions = Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        FButton(
          key: const ValueKey('confirmation-cancel'),
          variant: .outline,
          mainAxisSize: .min,
          onPress: onCancel,
          child: Text('examples.feedback.playgrounds.confirmation.cancel'.tr()),
        ),
        FButton(
          key: const ValueKey('confirmation-confirm'),
          mainAxisSize: .min,
          onPress: onConfirm,
          child: Text(
            'examples.feedback.playgrounds.confirmation.confirm'.tr(),
          ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: horizontal
          ? Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 20,
              children: [
                Expanded(child: copy),
                actions,
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [copy, actions],
            ),
    );
  }
}

class _EditSheet extends StatefulWidget {
  const _EditSheet({
    required this.value,
    required this.onCancel,
    required this.onSave,
  });

  final TextEditingValue value;
  final VoidCallback onCancel;
  final ValueChanged<TextEditingValue> onSave;

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late TextEditingValue _value = widget.value;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.theme.colors.background,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Text(
              'examples.feedback.playgrounds.confirmation.sheet_title'.tr(),
              style: context.theme.typography.display.md,
            ),
            FTextField(
              key: const ValueKey('confirmation-draft'),
              control: .lifted(
                value: _value,
                onChange: (value) => setState(() => _value = value),
              ),
              label: Text(
                'examples.feedback.playgrounds.confirmation.draft_label'.tr(),
              ),
            ),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                FButton(
                  key: const ValueKey('confirmation-sheet-cancel'),
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: widget.onCancel,
                  child: Text(
                    'examples.feedback.playgrounds.confirmation.cancel'.tr(),
                  ),
                ),
                FButton(
                  key: const ValueKey('confirmation-save'),
                  mainAxisSize: .min,
                  onPress: () => widget.onSave(_value),
                  child: Text(
                    'examples.feedback.playgrounds.confirmation.save'.tr(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _PersistentContent extends StatelessWidget {
  const _PersistentContent({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => ColoredBox(
    key: const ValueKey('confirmation-persistent-content'),
    color: context.theme.colors.background,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(
              'examples.feedback.playgrounds.confirmation.persistent_title'
                  .tr(),
              style: context.theme.typography.display.md,
            ),
            Text(
              'examples.feedback.playgrounds.confirmation.persistent_body'.tr(),
            ),
            FButton(
              key: const ValueKey('confirmation-persistent-close'),
              mainAxisSize: .min,
              onPress: onClose,
              child: Text(
                'examples.feedback.playgrounds.confirmation.close'.tr(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
