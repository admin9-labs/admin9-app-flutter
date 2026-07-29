import 'package:flutter/widgets.dart'
    show
        BuildContext,
        Center,
        EdgeInsets,
        ListView,
        Navigator,
        Padding,
        StatelessWidget,
        Widget;

import '../../../../admin9_ui.dart';
import '../../../../app/app_route_names.dart';
import '../../../../app/app_identity.dart';
import '../../../shared/brand_mark.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: '关于',
      navigationMode: AppPageNavigationMode.child,
      parentLabel: '我的',
      scrollable: false,
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: BrandMark(size: 72)),
          ),
          const AppListTile(title: '产品', currentValue: AppIdentity.productName),
          const AppListTile(title: '版本', currentValue: AppIdentity.version),
          AppListTile(
            title: '联系方式',
            disclosure: true,
            onTap: () => Navigator.pushNamed(context, AppRoutes.contact),
          ),
        ],
      ),
    );
  }
}
