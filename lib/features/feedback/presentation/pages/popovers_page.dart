import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class PopoversPage extends StatefulWidget {
  const PopoversPage({super.key});

  @override
  State<PopoversPage> createState() => _PopoversPageState();
}

class _PopoversPageState extends State<PopoversPage> {
  String _selectedKey = 'feedback.popovers.menu_first';

  @override
  Widget build(BuildContext context) => FScaffold(
    childPad: false,
    header: FHeader.nested(
      title: Text('feedback.catalog.popovers.title'.tr()),
      prefixes: [FHeaderAction.back(onPress: () => context.maybePop())],
    ),
    child: ResponsivePageBody(
      children: [
        ComponentExampleSection(
          title: 'feedback.popovers.popover_title'.tr(),
          description: 'feedback.popovers.popover_description'.tr(),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FPopover(
              popoverBuilder: (context, controller) => Padding(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(
                        'feedback.popovers.popover_content_title'.tr(),
                        style: context.theme.typography.display.sm,
                      ),
                      Text('feedback.popovers.popover_content'.tr()),
                      FButton(
                        size: .sm,
                        mainAxisSize: .min,
                        onPress: controller.hide,
                        child: Text('common.confirm'.tr()),
                      ),
                    ],
                  ),
                ),
              ),
              builder: (_, controller, _) => FButton(
                variant: .outline,
                mainAxisSize: .min,
                onPress: controller.toggle,
                child: Text('feedback.popovers.open_popover'.tr()),
              ),
            ),
          ),
        ),
        ComponentExampleSection(
          title: 'feedback.popovers.menu_title'.tr(),
          description: 'feedback.popovers.menu_description'.tr(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(
                'feedback.popovers.selected'.tr(
                  namedArgs: {'value': _selectedKey.tr()},
                ),
              ),
              FPopoverMenu(
                menuBuilder: (_, controller, _) => [
                  .group(
                    children: [
                      .item(
                        prefix: const Icon(FLucideIcons.list),
                        title: Text('feedback.popovers.menu_first'.tr()),
                        onPress: () {
                          setState(
                            () => _selectedKey = 'feedback.popovers.menu_first',
                          );
                          controller.hide();
                        },
                      ),
                      .item(
                        prefix: const Icon(FLucideIcons.layoutGrid),
                        title: Text('feedback.popovers.menu_second'.tr()),
                        onPress: () {
                          setState(
                            () =>
                                _selectedKey = 'feedback.popovers.menu_second',
                          );
                          controller.hide();
                        },
                      ),
                    ],
                  ),
                ],
                builder: (_, controller, _) => FButton(
                  variant: .outline,
                  mainAxisSize: .min,
                  onPress: controller.toggle,
                  child: Text('feedback.popovers.open_menu'.tr()),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
