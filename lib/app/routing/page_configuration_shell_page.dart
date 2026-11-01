import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

/// Each configured page owns an independent nested stack, keyed by its page ID.
@RoutePage(name: 'PageConfigurationShellRoute')
class PageConfigurationShellPage extends StatelessWidget {
  const PageConfigurationShellPage({
    @PathParam('pageId') required this.pageId,
    super.key,
  });

  final String pageId;

  @override
  Widget build(BuildContext context) => const AutoRouter();
}
