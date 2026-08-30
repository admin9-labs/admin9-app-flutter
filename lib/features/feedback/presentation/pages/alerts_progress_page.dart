import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class AlertsProgressPage extends StatelessWidget {
  const AlertsProgressPage({super.key});

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('feedback.catalog.alerts_progress.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'feedback.alerts.primary_title'.tr(),
          child: FAlert(
            liveRegion: false,
            icon: const Icon(FLucideIcons.info),
            title: Text('feedback.alerts.primary_message'.tr()),
            subtitle: Text('feedback.alerts.primary_description'.tr()),
          ),
        ),
        ComponentExampleSection(
          title: 'feedback.alerts.destructive_title'.tr(),
          child: FAlert(
            variant: .destructive,
            liveRegion: false,
            icon: const Icon(FLucideIcons.triangleAlert),
            title: Text('feedback.alerts.destructive_message'.tr()),
            subtitle: Text('feedback.alerts.destructive_description'.tr()),
          ),
        ),
        ComponentExampleSection(
          title: 'feedback.progress.circular_title'.tr(),
          description: 'feedback.progress.circular_description'.tr(),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: FCircularProgress(size: .lg),
          ),
        ),
        ComponentExampleSection(
          title: 'feedback.progress.determinate_title'.tr(),
          description: 'feedback.progress.determinate_description'.tr(),
          child: const FDeterminateProgress(value: 0.65),
        ),
        ComponentExampleSection(
          title: 'feedback.progress.indeterminate_title'.tr(),
          description: 'feedback.progress.indeterminate_description'.tr(),
          child: const FProgress(),
        ),
      ],
    ),
  );
}
