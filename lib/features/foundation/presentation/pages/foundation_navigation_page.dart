import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class FoundationNavigationPage extends StatelessWidget {
  const FoundationNavigationPage({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      FHeader.nested(
        title: Text('foundation.navigation.title'.tr()),
        prefixes: [
          FHeaderAction.back(
            onPress: () {
              context.maybePop();
            },
          ),
        ],
      ),
      Expanded(
        child: ResponsivePageBody(
          children: [
            ComponentExampleSection(
              title: 'foundation.navigation.tabs.title'.tr(),
              description: 'foundation.navigation.tabs.description'.tr(),
              child: FTabs(
                children: [
                  FTabEntry.entry(
                    label: Text('foundation.navigation.tabs.theme'.tr()),
                    child: _TabContent(
                      icon: context.theme.icons.calendar(context),
                      title: 'foundation.navigation.tabs.theme_title'.tr(),
                      body: 'foundation.navigation.tabs.theme_body'.tr(),
                    ),
                  ),
                  FTabEntry.entry(
                    label: Text('foundation.navigation.tabs.layout'.tr()),
                    child: _TabContent(
                      icon: context.theme.icons.chevronsUpDown(context),
                      title: 'foundation.navigation.tabs.layout_title'.tr(),
                      body: 'foundation.navigation.tabs.layout_body'.tr(),
                    ),
                  ),
                  FTabEntry.entry(
                    label: Text('foundation.navigation.tabs.input'.tr()),
                    child: _TabContent(
                      icon: context.theme.icons.userRound(context),
                      title: 'foundation.navigation.tabs.input_title'.tr(),
                      body: 'foundation.navigation.tabs.input_body'.tr(),
                    ),
                  ),
                ],
              ),
            ),
            ComponentExampleSection(
              title: 'foundation.navigation.shell.title'.tr(),
              description: 'foundation.navigation.shell.description'.tr(),
              child: FCard(
                builder: (context, style, _) => Padding(
                  padding: style.padding,
                  child: Text(
                    'foundation.navigation.shell.body'.tr(),
                    style: style.subtitleTextStyle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _TabContent extends StatelessWidget {
  const _TabContent({
    required this.icon,
    required this.title,
    required this.body,
  });

  final Widget icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => FCard(
    builder: (context, style, _) => Padding(
      padding: style.padding,
      child: Row(
        crossAxisAlignment: .start,
        spacing: 12,
        children: [
          icon,
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              spacing: 4,
              children: [
                Text(title, style: style.titleTextStyle),
                Text(body, style: style.subtitleTextStyle),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
