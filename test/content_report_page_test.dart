import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:admin9_app_flutter/core/theme/app_appearance.dart';
import 'package:admin9_app_flutter/core/theme/app_theme.dart';
import 'package:admin9_app_flutter/domain/models/article.dart';
import 'package:admin9_app_flutter/ui/features/foundation/views/content_report_page.dart';

void main() {
  testWidgets('ContentReportPage submits selected reason and returns', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(
          brand: AppBrand.newsBlueBrand,
          fontLevel: AppFontLevel.standard,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                key: const Key('open-report-page'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ContentReportPage(article: _article),
                  ),
                ),
                child: const Text('打开举报'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('open-report-page')));
    await tester.pumpAndSettle();

    expect(find.text('举报内容'), findsOneWidget);
    expect(find.text(_article.title), findsOneWidget);
    expect(find.text('举报原因'), findsOneWidget);
    expect(find.text('补充说明'), findsOneWidget);
    expect(find.byKey(const Key('submit-content-report')), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('侵权投诉').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '补充举报说明');

    await tester.tap(find.byKey(const Key('submit-content-report')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('open-report-page')), findsOneWidget);
    expect(find.text('举报已提交：侵权投诉'), findsOneWidget);
  });
}

const _article = Article(
  id: 'report-test',
  title: '被举报测试文章',
  source: '测试来源',
  time: '今天 10:00',
  summary: '用于举报页面 smoke test。',
  visuals: [ArticleVisualAsset(label: '测试图', type: ArticleVisualType.city)],
  paragraphs: ['测试正文'],
);
