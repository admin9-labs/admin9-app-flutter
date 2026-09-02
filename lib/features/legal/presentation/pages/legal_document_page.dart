import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

import '../../domain/legal_document.dart';

@RoutePage()
class LegalDocumentPage extends StatelessWidget {
  const LegalDocumentPage({super.key, required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final keys = switch (document) {
      LegalDocument.userAgreement => const (
        title: 'legal.user.title',
        updated: 'legal.user.updated',
        sections: [
          'legal.user.section_1',
          'legal.user.section_2',
          'legal.user.section_3',
          'legal.user.section_4',
        ],
      ),
      LegalDocument.privacyPolicy => const (
        title: 'legal.privacy.title',
        updated: 'legal.privacy.updated',
        sections: [
          'legal.privacy.section_1',
          'legal.privacy.section_2',
          'legal.privacy.section_3',
          'legal.privacy.section_4',
        ],
      ),
    };
    return FScaffold(
      header: FHeader.nested(
        title: Text(context.tr(keys.title)),
        prefixes: [FHeaderAction.back(onPress: context.router.maybePop)],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              Text(
                context.tr(keys.updated),
                style: FTheme.of(context).typography.body.sm
                    .copyWith(color: FTheme.of(context).colors.mutedForeground),
              ),
              for (final section in keys.sections)
                Text(
                  context.tr(section),
                  style: FTheme.of(context).typography.body.md
                      .copyWith(height: 1.7),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
