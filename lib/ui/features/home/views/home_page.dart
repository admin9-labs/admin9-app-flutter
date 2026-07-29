import 'package:flutter/widgets.dart'
    show
        BuildContext,
        Center,
        Column,
        EdgeInsets,
        MainAxisSize,
        Padding,
        SizedBox,
        StatelessWidget,
        Text,
        Widget;

import '../../../../admin9_ui.dart';
import '../../../../app/app_identity.dart';
import '../../../shared/brand_mark.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = AppDesignScope.of(context);
    return AppPage(
      title: AppIdentity.name,
      navigationMode: AppPageNavigationMode.root,
      scrollable: false,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandMark(size: 72, showName: false),
              const SizedBox(height: 24),
              Text('暂无内容', style: tokens.sectionTitleTextStyle),
            ],
          ),
        ),
      ),
    );
  }
}
