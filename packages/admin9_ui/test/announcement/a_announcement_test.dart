import 'package:admin9_ui/admin9_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import '../support/pump_content.dart';
import '../support/test_theme.dart';

List<AAnnouncementItem> notices(List<int> ids, {List<int>? opened}) => [
  for (final id in ids)
    AAnnouncementItem(id: id, title: '公告$id', onPress: () => opened?.add(id)),
];
void main() {
  testWidgets('empty and single announcements have no next button', (
    tester,
  ) async {
    await pumpContent(tester, const AAnnouncement(items: []));
    expect(find.byType(PageView), findsNothing);
    await pumpContent(
      tester,
      AAnnouncement(items: notices([1]), autoplay: true),
    );
    expect(find.byType(FButton), findsNothing);
    await tester.pump(const Duration(seconds: 20));
    expect(find.text('公告1'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('manual next wraps and opens the current item without autoplay', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final opened = <int>[], changed = <int>[];
    await pumpContent(
      tester,
      AAnnouncement(
        items: notices([1, 2], opened: opened),
        onChanged: changed.add,
      ),
    );
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('公告1'), findsOneWidget);
    await tester.tap(find.byType(FButton));
    await tester.pumpAndSettle();
    expect(find.text('公告2'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('公告2'));
    await tester.pumpAndSettle();
    expect(opened, [2]);
    await tester.tap(find.byType(FButton));
    await tester.pumpAndSettle();
    expect(changed, [1, 0]);
    semantics.dispose();
  });
  testWidgets(
    'automatic notices retain selected identity and pause for inactive hosts',
    (tester) async {
      final changed = <int>[];
      Widget notice(List<int> ids, {bool active = true}) => AAnnouncement(
        items: notices(ids),
        autoplay: true,
        active: active,
        interval: const Duration(seconds: 1),
        onChanged: changed.add,
      );
      await pumpContent(tester, notice([1, 2, 3]));
      await advanceContent(tester);
      expect(find.text('公告2'), findsOneWidget);
      await pumpContent(tester, notice([3, 1, 2], active: false));
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('公告2'), findsOneWidget);
      expect(changed, [1, 2]);
      await pumpContent(tester, notice([3, 1]));
      expect(find.text('公告3'), findsOneWidget);
      expect(changed, [1, 2, 0]);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'long copy fits measured viewport in both themes, RTL and large text',
    (tester) async {
      const title = '关于服务时间调整的公告：2026年10月13日至2026年10月20日，请完整阅读各项安排。';
      final semantics = tester.ensureSemantics();
      for (final theme in [lightTheme, darkTheme]) {
        for (final direction in TextDirection.values) {
          await pumpContent(
            tester,
            const AAnnouncement(
              items: [
                AAnnouncementItem(id: 1, title: '短公告'),
                AAnnouncementItem(id: 2, title: title),
              ],
            ),
            width: 320,
            scale: 2,
            theme: theme,
            direction: direction,
          );
          await tester.tap(find.byType(FButton));
          await tester.pumpAndSettle();
          expect(find.bySemanticsLabel(title), findsOneWidget);
          expect(
            tester.getSize(find.text(title)).height,
            lessThanOrEqualTo(tester.getSize(find.byType(PageView)).height),
          );
          expect(tester.widget<Text>(find.text(title)).maxLines, isNull);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        }
      }
      semantics.dispose();
    },
  );
  testWidgets(
    'holding the next control pauses autoplay before manual activation',
    (tester) async {
      final changed = <int>[];
      await pumpContent(
        tester,
        AAnnouncement(
          items: notices([1, 2, 3]),
          autoplay: true,
          interval: const Duration(seconds: 1),
          onChanged: changed.add,
        ),
      );
      final hold = await tester.startGesture(
        tester.getCenter(find.byType(FButton)),
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 1));
      expect(changed, isEmpty);
      expect(find.text('公告1'), findsOneWidget);
      await hold.up();
      await tester.pumpAndSettle();
      expect(changed, [1]);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('motion and accessibility reveal every announcement action', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    for (final accessible in [false, true]) {
      final opened = <int>[];
      await pumpContent(
        tester,
        AAnnouncement(
          items: notices([1, 2, 3], opened: opened),
          autoplay: true,
        ),
        reduceMotion: !accessible,
        accessibleNavigation: accessible,
        width: 320,
        scale: 2,
      );
      expect(find.byType(PageView), findsNothing);
      for (var i = 1; i <= 3; i++) {
        await tester.tap(find.bySemanticsLabel('公告$i'));
        await tester.pumpAndSettle();
      }
      expect(opened, [1, 2, 3]);
      expect(tester.takeException(), isNull);
    }
    semantics.dispose();
  });
}
