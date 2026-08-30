import 'package:admin9_app_flutter/shared/ui/component_example_section.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class FoundationLayoutPage extends StatefulWidget {
  const FoundationLayoutPage({super.key});

  @override
  State<FoundationLayoutPage> createState() => _FoundationLayoutPageState();
}

class _FoundationLayoutPageState extends State<FoundationLayoutPage> {
  int _searchCount = 0;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      FHeader.nested(
        title: Text('foundation.layout.title'.tr()),
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
              title: 'foundation.layout.header.title'.tr(),
              description: 'foundation.layout.header.description'.tr(),
              child: FCard(
                clipBehavior: .hardEdge,
                child: FHeader(
                  title: Text(
                    _searchCount == 0
                        ? 'foundation.layout.header.sample'.tr()
                        : 'foundation.layout.header.search_count'.tr(
                            namedArgs: {'count': '$_searchCount'},
                          ),
                  ),
                  suffixes: [
                    FHeaderAction(
                      icon: context.theme.icons.search(context),
                      semanticsLabel:
                          'foundation.layout.header.search_semantics'.tr(),
                      onPress: () => setState(() => _searchCount++),
                    ),
                  ],
                ),
              ),
            ),
            ComponentExampleSection(
              title: 'foundation.layout.divider.title'.tr(),
              child: FCard(
                builder: (context, style, _) => Padding(
                  padding: style.padding,
                  child: Column(
                    spacing: 12,
                    children: [
                      Text('foundation.layout.divider.first'.tr()),
                      const FDivider(),
                      Text('foundation.layout.divider.second'.tr()),
                    ],
                  ),
                ),
              ),
            ),
            ComponentExampleSection(
              title: 'foundation.layout.theme.title'.tr(),
              description: 'foundation.layout.theme.description'.tr(),
              child: FCard(
                builder: (context, style, _) => Padding(
                  padding: style.padding,
                  child: Row(
                    spacing: 12,
                    children: [
                      context.theme.icons.calendar(context),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          spacing: 4,
                          children: [
                            Text(
                              'foundation.layout.theme.primary'.tr(),
                              style: style.titleTextStyle,
                            ),
                            Text(
                              'foundation.layout.theme.body'.tr(),
                              style: style.subtitleTextStyle,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.theme.colors.primary,
                          borderRadius: .circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ComponentExampleSection(
              title: 'foundation.layout.responsive.title'.tr(),
              description: 'foundation.layout.responsive.description'.tr(),
              child: const _ResponsiveStatus(),
            ),
            ComponentExampleSection(
              title: 'foundation.layout.safe_area.title'.tr(),
              description: 'foundation.layout.safe_area.description'.tr(),
              child: FCard(
                builder: (context, style, _) => Padding(
                  padding: style.padding,
                  child: Row(
                    spacing: 12,
                    children: [
                      context.theme.icons.check(context),
                      Expanded(
                        child: Text('foundation.layout.safe_area.body'.tr()),
                      ),
                    ],
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

class _ResponsiveStatus extends StatelessWidget {
  const _ResponsiveStatus();

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 600;
      return FCard(
        builder: (context, style, _) => Padding(
          padding: style.padding,
          child: Row(
            spacing: 12,
            children: [
              context.theme.icons.chevronsUpDown(context),
              Expanded(
                child: Text(
                  compact
                      ? 'foundation.layout.responsive.compact'.tr()
                      : 'foundation.layout.responsive.regular'.tr(),
                  style: style.titleTextStyle,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
