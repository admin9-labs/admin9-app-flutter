import 'package:flutter/material.dart';

import '../../../../core/widgets/foundation_page.dart';
import '../models/legal_document.dart';

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({super.key, required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      title: document.type.title,
      child: document.hasContent
          ? SingleChildScrollView(child: SelectableText(document.content!))
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.description_outlined, size: 44),
                  const SizedBox(height: 16),
                  const Text('正式内容尚未提供'),
                  const SizedBox(height: 8),
                  Text(
                    '资源标识：${document.type.resourceKey}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
    );
  }
}
