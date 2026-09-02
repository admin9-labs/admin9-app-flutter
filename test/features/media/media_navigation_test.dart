import 'package:admin9_app_flutter/features/media/presentation/pages/article_page.dart';
import 'package:admin9_app_flutter/features/media/presentation/pages/image_viewer_page.dart';
import 'package:admin9_app_flutter/features/media/presentation/pages/media_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../app/support/test_admin9_app.dart';

void main() {
  testWidgets('article images open the in-process root viewer and return', (
    tester,
  ) async {
    await pumpTestAdmin9App(tester);
    await tester.tap(find.text('媒体'));
    await tester.pumpAndSettle();
    expect(find.byType(MediaPage), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('media-open-article')));
    await tester.pumpAndSettle();
    expect(find.byType(ArticlePage), findsOneWidget);

    final second = find.byKey(
      const ValueKey('article-image-assets/images/onboarding/read.jpg'),
    );
    await tester.ensureVisible(second);
    final articleScroll = tester.state<ScrollableState>(
      find
          .descendant(
            of: find.byType(ArticlePage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    final offsetBeforePreview = articleScroll.position.pixels;
    await tester.tap(second);
    await _pumpUntil(tester, find.byType(ImageViewerPage));
    expect(find.byType(ImageViewerPage), findsOneWidget);
    expect(find.byType(ArticlePage), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.byType(ImageViewerPage), findsOneWidget);
    expect(find.byType(ArticlePage), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 420));
    expect(find.text('2/3'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('a-image-viewer-close')));
    await _pumpUntilGone(tester, find.byType(ImageViewerPage));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(ImageViewerPage), findsNothing);
    expect(find.byType(ArticlePage), findsOneWidget);
    expect(articleScroll.position.pixels, closeTo(offsetBeforePreview, 0.01));
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpUntil(WidgetTester tester, Finder finder) async {
  for (var frame = 0; frame < 40 && finder.evaluate().isEmpty; frame++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<void> _pumpUntilGone(WidgetTester tester, Finder finder) async {
  for (var frame = 0; frame < 40 && finder.evaluate().isNotEmpty; frame++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}
