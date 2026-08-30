import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class SheetsPage extends StatefulWidget {
  const SheetsPage({super.key});

  @override
  State<SheetsPage> createState() => _SheetsPageState();
}

class _SheetsPageState extends State<SheetsPage> {
  FPersistentSheetController? _persistentController;

  @override
  void dispose() {
    _persistentController?.dispose();
    super.dispose();
  }

  Future<void> _showModalSheet() => showFSheet<void>(
    context: context,
    side: .btt,
    useSafeArea: true,
    builder: (sheetContext) => _SheetContent(
      title: 'feedback.sheets.modal_title'.tr(),
      message: 'feedback.sheets.modal_message'.tr(),
      onClose: () => Navigator.of(sheetContext).pop(),
    ),
  );

  void _togglePersistentSheet() {
    final controller = _persistentController;
    if (controller != null) {
      controller.toggle();
      return;
    }

    _persistentController = showFPersistentSheet(
      context: context,
      side: .btt,
      useSafeArea: true,
      mainAxisMaxRatio: 0.4,
      builder: (sheetContext, controller) => _SheetContent(
        title: 'feedback.sheets.persistent_title'.tr(),
        message: 'feedback.sheets.persistent_message'.tr(),
        onClose: controller.hide,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('feedback.catalog.sheets.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'feedback.sheets.modal_title'.tr(),
          description: 'feedback.sheets.modal_description'.tr(),
          child: FButton(
            variant: .outline,
            onPress: _showModalSheet,
            child: Text('feedback.sheets.open_modal'.tr()),
          ),
        ),
        ComponentExampleSection(
          title: 'feedback.sheets.persistent_title'.tr(),
          description: 'feedback.sheets.persistent_description'.tr(),
          child: FButton(
            variant: .outline,
            onPress: _togglePersistentSheet,
            child: Text('feedback.sheets.toggle_persistent'.tr()),
          ),
        ),
      ],
    ),
  );
}

class _SheetContent extends StatelessWidget {
  const _SheetContent({
    required this.title,
    required this.message,
    required this.onClose,
  });

  final String title;
  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.theme.colors.background,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Text(title, style: context.theme.typography.display.lg),
            Text(message, style: context.theme.typography.body.md),
            Align(
              alignment: Alignment.centerRight,
              child: FButton(
                mainAxisSize: .min,
                onPress: onClose,
                child: Text('common.confirm'.tr()),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
