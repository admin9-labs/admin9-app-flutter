import 'package:admin9_app_flutter/app/routing/app_router.gr.dart';
import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class FoundationPage extends StatelessWidget {
  const FoundationPage({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      FHeader(title: Text('foundation.title'.tr())),
      Expanded(
        child: ResponsivePageBody(
          children: [
            ComponentExampleSection(
              title: 'foundation.catalog.title'.tr(),
              description: 'foundation.catalog.description'.tr(),
              child: Column(
                spacing: 12,
                children: [
                  FButton(
                    variant: .outline,
                    prefix: context.theme.icons.calendar(context),
                    suffix: context.theme.icons.chevronRight(context),
                    onPress: () =>
                        context.pushRoute(const FoundationLayoutRoute()),
                    child: Text('foundation.catalog.layout'.tr()),
                  ),
                  FButton(
                    variant: .outline,
                    prefix: context.theme.icons.chevronsUpDown(context),
                    suffix: context.theme.icons.chevronRight(context),
                    onPress: () =>
                        context.pushRoute(const FoundationNavigationRoute()),
                    child: Text('foundation.catalog.navigation'.tr()),
                  ),
                  FButton(
                    variant: .outline,
                    prefix: context.theme.icons.userRound(context),
                    suffix: context.theme.icons.chevronRight(context),
                    onPress: () =>
                        context.pushRoute(const FoundationInteractionRoute()),
                    child: Text('foundation.catalog.interaction'.tr()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
