import 'package:flutter/material.dart';

import '../../../../core/widgets/foundation_page.dart';
import '../../../../domain/models/foundation_models.dart';

class AgreementPage extends StatelessWidget {
  const AgreementPage({super.key, required this.document});

  final AgreementDocument document;

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      title: document.title,
      children: [
        Text(document.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 14),
        Text(document.content, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
