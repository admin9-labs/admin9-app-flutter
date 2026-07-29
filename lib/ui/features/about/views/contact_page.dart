import 'package:flutter/widgets.dart'
    show
        BuildContext,
        Center,
        Column,
        MainAxisSize,
        StatelessWidget,
        Text,
        Widget;

import '../../../../admin9_ui.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPage(
      title: '联系方式',
      navigationMode: AppPageNavigationMode.child,
      parentLabel: '关于',
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Text('正式联系方式尚未提供')],
        ),
      ),
    );
  }
}
