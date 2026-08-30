import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class ToastsTooltipsPage extends StatefulWidget {
  const ToastsTooltipsPage({super.key});

  @override
  State<ToastsTooltipsPage> createState() => _ToastsTooltipsPageState();
}

class _ToastsTooltipsPageState extends State<ToastsTooltipsPage> {
  bool _tooltipShown = false;

  void _showToast(BuildContext context) {
    showFToast(
      context: context,
      alignment: .bottomCenter,
      icon: const Icon(FLucideIcons.circleCheck),
      title: Text('feedback.toasts.success_title'.tr()),
      description: Text('feedback.toasts.success_description'.tr()),
      suffixBuilder: (_, entry) => FButton(
        variant: .ghost,
        size: .sm,
        mainAxisSize: .min,
        onPress: entry.dismiss,
        child: Text('feedback.toasts.dismiss'.tr()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('feedback.catalog.toasts_tooltips.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'feedback.toasts.static_title'.tr(),
          description: 'feedback.toasts.static_description'.tr(),
          child: FToast(
            icon: const Icon(FLucideIcons.info),
            title: Text('feedback.toasts.preview_title'.tr()),
            description: Text('feedback.toasts.preview_description'.tr()),
          ),
        ),
        ComponentExampleSection(
          title: 'feedback.toasts.overlay_title'.tr(),
          description: 'feedback.toasts.overlay_description'.tr(),
          child: FButton(
            variant: .outline,
            onPress: () => _showToast(context),
            child: Text('feedback.toasts.show'.tr()),
          ),
        ),
        ComponentExampleSection(
          title: 'feedback.tooltips.title'.tr(),
          description: 'feedback.tooltips.description'.tr(),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FTooltip(
              control: .lifted(
                shown: _tooltipShown,
                onChange: _setTooltipShown,
              ),
              longPress: true,
              tipBuilder: (_, _) => Text('feedback.tooltips.tip'.tr()),
              child: FButton.icon(
                variant: .outline,
                semanticsLabel: 'feedback.tooltips.tip'.tr(),
                onPress: () => _setTooltipShown(!_tooltipShown),
                child: const Icon(FLucideIcons.info),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  void _setTooltipShown(bool shown) {
    if (mounted && shown != _tooltipShown) {
      setState(() => _tooltipShown = shown);
    }
  }
}
