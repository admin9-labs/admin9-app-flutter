import 'package:admin9_app_flutter/app/appearance/app_appearance_preference.dart';
import 'package:admin9_app_flutter/app/appearance/app_theme_catalog.dart';
import 'package:admin9_app_flutter/shared/ui/media/image_viewer/a_image_viewer.dart';
import 'package:admin9_app_flutter/shared/ui/media/image_viewer/a_image_viewer_item.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:extended_image/extended_image.dart';

void main() {
  final items = [
    const AImageViewerItem.asset(
      assetName: 'assets/images/onboarding/collaborate.jpg',
      semanticLabel: '协作照片',
    ),
    const AImageViewerItem.asset(
      assetName: 'assets/images/onboarding/read.jpg',
      semanticLabel: '阅读照片',
    ),
    const AImageViewerItem.asset(
      assetName: 'assets/images/onboarding/act.jpg',
      semanticLabel: '行动照片',
    ),
  ];

  testWidgets('opens the requested image, pages, and closes semantically', (
    tester,
  ) async {
    var closes = 0;
    await tester.pumpWidget(
      _Harness(
        child: AImageViewer(
          items: items,
          initialIndex: 1,
          onClose: () => closes++,
        ),
      ),
    );
    await _pumpFrames(tester);

    expect(find.text('2/3'), findsOneWidget);
    expect(find.bySemanticsLabel('阅读照片'), findsOneWidget);

    final pages = tester.widget<ExtendedImageGesturePageView>(
      find.byType(ExtendedImageGesturePageView),
    );
    pages.controller.jumpToPage(2);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('3/3'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('a-image-viewer-close')));
    await tester.pump(const Duration(milliseconds: 200));
    expect(closes, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'double tap changes gesture scale without resizing the viewport',
    (tester) async {
      await tester.pumpWidget(
        _Harness(
          child: AImageViewer(items: items, initialIndex: 0, onClose: () {}),
        ),
      );
      await _pumpFrames(tester);
      final viewport = tester.getSize(
        find.byKey(const ValueKey('a-image-viewer-pages')).first,
      );

      await tester.tap(
        find.byKey(
          const ValueKey(
            'a-image-viewer-assets/images/onboarding/collaborate.jpg',
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 80));
      await tester.tap(
        find.byKey(
          const ValueKey(
            'a-image-viewer-assets/images/onboarding/collaborate.jpg',
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        tester.getSize(
          find.byKey(const ValueKey('a-image-viewer-pages')).first,
        ),
        viewport,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _pumpFrames(WidgetTester tester, {int count = 12}) async {
  for (var frame = 0; frame < count; frame++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

class _Harness extends StatelessWidget {
  const _Harness({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MediaQuery(
    data: const MediaQueryData(size: Size(390, 844)),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: FTheme(
        data: AppThemeCatalog.resolve(
          preset: AppThemePreset.neutral,
          fontSize: AppFontSizePreference.standard,
          radius: AppRadiusPreference.medium,
        ).dark,
        child: child,
      ),
    ),
  );
}
