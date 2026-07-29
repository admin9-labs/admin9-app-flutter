import 'package:flutter/material.dart';

import '../../../../app/app_route_names.dart';
import '../../../../app/app_identity.dart';
import '../../../shared/brand_mark.dart';
import '../../../../core/widgets/foundation_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      title: '关于',
      padding: EdgeInsets.zero,
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: BrandMark(size: 72)),
          ),
          const ListTile(
            leading: Icon(Icons.apps_outlined),
            title: Text('产品'),
            trailing: Text(AppIdentity.productName),
          ),
          const ListTile(
            leading: Icon(Icons.numbers),
            title: Text('版本'),
            trailing: Text(AppIdentity.version),
          ),
          ListTile(
            leading: const Icon(Icons.contact_support_outlined),
            title: const Text('联系方式'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, AppRoutes.contact),
          ),
        ],
      ),
    );
  }
}
