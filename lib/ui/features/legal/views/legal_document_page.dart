import 'package:flutter/widgets.dart'
    show
        BuildContext,
        Center,
        Column,
        MainAxisSize,
        SizedBox,
        StatelessWidget,
        Text,
        Widget;
import 'package:flutter/material.dart' show SelectableText;

import '../../../../admin9_ui.dart';
import '../models/legal_document.dart';

class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({
    super.key,
    required this.document,
    required this.parentLabel,
  });

  final LegalDocument document;
  final String parentLabel;

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: document.type.title,
      navigationMode: AppPageNavigationMode.child,
      parentLabel: parentLabel,
      body: document.hasContent
          ? SelectableText(document.content!)
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('正式内容尚未提供'),
                  const SizedBox(height: 8),
                  Text('资源标识：${document.type.resourceKey}'),
                ],
              ),
            ),
    );
  }
}
