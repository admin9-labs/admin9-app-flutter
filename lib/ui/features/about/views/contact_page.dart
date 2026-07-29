import 'package:flutter/material.dart';

import '../../../../core/widgets/foundation_page.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FoundationPage(
      title: '联系方式',
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.contact_mail_outlined, size: 44),
            SizedBox(height: 16),
            Text('正式联系方式尚未提供'),
          ],
        ),
      ),
    );
  }
}
