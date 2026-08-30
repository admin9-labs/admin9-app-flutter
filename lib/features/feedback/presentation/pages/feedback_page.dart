import 'package:admin9_app_flutter/app/routing/app_router.gr.dart';
import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader(title: Text('feedback.title'.tr())),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'feedback.catalog.alerts_progress.title'.tr(),
          description: 'feedback.catalog.alerts_progress.description'.tr(),
          child: _CatalogButton(
            label: 'feedback.catalog.alerts_progress.open'.tr(),
            onPress: () => context.pushRoute(const AlertsProgressRoute()),
          ),
        ),
        ComponentExampleSection(
          title: 'feedback.catalog.dialogs.title'.tr(),
          description: 'feedback.catalog.dialogs.description'.tr(),
          child: _CatalogButton(
            label: 'feedback.catalog.dialogs.open'.tr(),
            onPress: () => context.pushRoute(const DialogsRoute()),
          ),
        ),
        ComponentExampleSection(
          title: 'feedback.catalog.sheets.title'.tr(),
          description: 'feedback.catalog.sheets.description'.tr(),
          child: _CatalogButton(
            label: 'feedback.catalog.sheets.open'.tr(),
            onPress: () => context.pushRoute(const SheetsRoute()),
          ),
        ),
        ComponentExampleSection(
          title: 'feedback.catalog.popovers.title'.tr(),
          description: 'feedback.catalog.popovers.description'.tr(),
          child: _CatalogButton(
            label: 'feedback.catalog.popovers.open'.tr(),
            onPress: () => context.pushRoute(const PopoversRoute()),
          ),
        ),
        ComponentExampleSection(
          title: 'feedback.catalog.toasts_tooltips.title'.tr(),
          description: 'feedback.catalog.toasts_tooltips.description'.tr(),
          child: _CatalogButton(
            label: 'feedback.catalog.toasts_tooltips.open'.tr(),
            onPress: () => context.pushRoute(const ToastsTooltipsRoute()),
          ),
        ),
      ],
    ),
  );
}

class _CatalogButton extends StatelessWidget {
  const _CatalogButton({required this.label, required this.onPress});

  final String label;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) => FButton(
    variant: .outline,
    onPress: onPress,
    suffix: context.theme.icons.chevronRight(context),
    builder: (_, _, _, _, _, child) => Expanded(child: child!),
    child: Text(label),
  );
}
