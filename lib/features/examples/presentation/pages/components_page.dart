import 'package:admin9_app_flutter/app/routing/app_router.gr.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage()
class ComponentsPage extends StatelessWidget {
  const ComponentsPage({super.key});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      FHeader(title: Text(context.tr('components.title'))),
      Expanded(
        child: ResponsivePageBody(
          safeAreaBottom: false,
          children: [
            _Catalog(
              title: context.tr('components.forui.title'),
              description: context.tr('components.forui.description'),
              entries: [
                _Entry(
                  key: const ValueKey('components-forui-foundation'),
                  icon: FLucideIcons.box,
                  title: context.tr('examples.foundation.title'),
                  onPress: () => context.pushRoute(const FoundationRoute()),
                ),
                _Entry(
                  icon: FLucideIcons.listChecks,
                  title: context.tr('examples.forms.title'),
                  onPress: () => context.pushRoute(const FormsRoute()),
                ),
                _Entry(
                  icon: FLucideIcons.layoutList,
                  title: context.tr('examples.content.title'),
                  onPress: () => context.pushRoute(const ContentRoute()),
                ),
                _Entry(
                  icon: FLucideIcons.messageCircle,
                  title: context.tr('examples.feedback.title'),
                  onPress: () => context.pushRoute(const FeedbackRoute()),
                ),
              ],
            ),
            _Catalog(
              title: context.tr('components.admin9.title'),
              description: context.tr('components.admin9.description'),
              entries: [
                _Entry(
                  key: const ValueKey('components-admin9-grid'),
                  icon: FLucideIcons.layoutGrid,
                  title: context.tr('examples.foundation.layout.grid.title'),
                  subtitle: context.tr('components.admin9.grid_family'),
                  onPress: () => context.pushRoute(const GridRoute()),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

class _Catalog extends StatelessWidget {
  const _Catalog({
    required this.title,
    required this.description,
    required this.entries,
  });

  final String title;
  final String description;
  final List<_Entry> entries;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 10,
    children: [
      Text(title, style: FTheme.of(context).typography.body.lg),
      Text(description, style: FTheme.of(context).typography.body.sm),
      FItemGroup(divider: .indented, children: entries),
    ],
  );
}

class _Entry extends FItem {
  _Entry({
    super.key,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onPress,
  }) : super(
         prefix: Icon(icon),
         title: Text(title),
         subtitle: subtitle == null ? null : Text(subtitle),
         suffix: const Icon(FLucideIcons.chevronRight),
         onPress: onPress,
       );
}
