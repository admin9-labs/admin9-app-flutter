import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class DialogsPage extends StatelessWidget {
  const DialogsPage({super.key});

  Future<void> _showConfirmation(BuildContext context) => showFDialog<void>(
    context: context,
    useSafeArea: true,
    builder: (dialogContext, _, animation) => FDialog(
      animation: animation,
      semanticsLabel: 'feedback.dialogs.semantics_label'.tr(),
      builder: (context, style) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Text(
              'feedback.dialogs.confirm_title'.tr(),
              style: style.titleTextStyle,
            ),
            Text(
              'feedback.dialogs.confirm_message'.tr(),
              style: style.bodyTextStyle,
            ),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                FButton(
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: () => Navigator.of(dialogContext).pop(),
                  child: Text('common.cancel'.tr()),
                ),
                FButton(
                  mainAxisSize: .min,
                  onPress: () => Navigator.of(dialogContext).pop(),
                  child: Text('common.confirm'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('feedback.catalog.dialogs.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'feedback.dialogs.title'.tr(),
          description: 'feedback.dialogs.description'.tr(),
          child: FButton(
            variant: .outline,
            onPress: () => _showConfirmation(context),
            child: Text('feedback.dialogs.open'.tr()),
          ),
        ),
      ],
    ),
  );
}
