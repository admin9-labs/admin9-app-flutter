import 'dart:convert';
import 'dart:io';

import 'package:admin9_app_flutter/app/page_configuration/page_configuration.dart';
import 'package:admin9_app_flutter/features/home/presentation/pages/home_page.dart';
import 'package:admin9_app_flutter/features/media/presentation/pages/media_page.dart';
import 'package:admin9_app_flutter/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'support/test_admin9_app.dart';

Map<String, dynamic> _json() =>
    jsonDecode(File('assets/config/page_configuration.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  testWidgets(
    'reordered, renamed, hidden entries keep shortcuts and branch stacks correct',
    (tester) async {
      final json = _json();
      final navigation = json['navigation'] as List<dynamic>;
      for (final entry in navigation) {
        entry['order'] = switch (entry['pageType']) {
          'settings' => -2,
          'home' => 0,
          _ => -1,
        };
        if (entry['pageType'] == 'home') entry['pageId'] = 'landing';
        if (entry['pageType'] == 'components') entry['visible'] = false;
      }
      for (final page in json['pages'] as List<dynamic>) {
        if (page['pageType'] == 'home') {
          page['pageId'] = 'landing';
          page['title'] = '我的首页';
        }
      }
      await pumpTestAdmin9App(
        tester,
        pageConfiguration: PageConfiguration.fromJson(json)!,
      );
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('我的首页'), findsOneWidget);
      expect(find.byKey(const ValueKey('home-open-components')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('home-open-settings')));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsPage), findsOneWidget);
      final navigationBar = find.byType(FBottomNavigationBar);
      await tester.tap(
        find.descendant(of: navigationBar, matching: find.text('媒体')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MediaPage), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('media-open-article')));
      await tester.pumpAndSettle();
      expect(find.byType(MediaPage), findsNothing);
      await tester.tap(
        find.descendant(of: navigationBar, matching: find.text('首页')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('home-open-media')));
      await tester.pumpAndSettle();
      expect(
        find.byType(MediaPage),
        findsNothing,
        reason: 'Media detail stack is preserved',
      );
      expect(await tester.binding.handlePopRoute(), isTrue);
      await tester.pumpAndSettle();
      expect(find.byType(MediaPage), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'distinct configured placeholder tabs render, titles and regions obey configuration',
    (tester) async {
      final json = _json();
      (json['navigation'] as List<dynamic>).addAll([
        {
          'pageId': 'inbox',
          'pageType': 'placeholder',
          'label': '消息',
          'icon': 'home',
          'order': 8,
        },
        {
          'pageId': 'saved',
          'pageType': 'placeholder',
          'label': '收藏',
          'icon': 'home',
          'order': 9,
        },
      ]);
      (json['pages'] as List<dynamic>).addAll([
        {
          'pageId': 'inbox',
          'pageType': 'placeholder',
          'title': '消息页面',
          'tabs': [
            {
              'id': 'hidden',
              'label': '已读',
              'order': 2,
              'regions': {'content': false},
            },
            {'id': 'empty', 'label': '未读', 'order': 1},
          ],
        },
        {'pageId': 'saved', 'pageType': 'placeholder', 'title': '收藏页面'},
      ]);
      await pumpTestAdmin9App(
        tester,
        pageConfiguration: PageConfiguration.fromJson(json)!,
        size: const Size(390, 844),
      );
      final bar = find.byType(FBottomNavigationBar);
      await tester.tap(find.descendant(of: bar, matching: find.text('消息')));
      await tester.pumpAndSettle();
      expect(find.text('消息页面'), findsOneWidget);
      expect(find.byType(FTabs), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('未读')).dx,
        lessThan(tester.getTopLeft(find.text('已读')).dx),
      );
      expect(find.text('暂无内容'), findsOneWidget);
      await tester.tap(find.text('已读'));
      await tester.pumpAndSettle();
      expect(find.text('暂无内容'), findsNothing);
      await tester.tap(find.descendant(of: bar, matching: find.text('收藏')));
      await tester.pumpAndSettle();
      expect(find.text('收藏页面'), findsOneWidget);
      expect(find.text('暂无内容'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [320.0, 390.0]) {
    testWidgets(
      'Home empty regions and configured appearance at $width / 2x text',
      (tester) async {
        final json = _json();
        json['navigation'] = [
          {'pageId': 'home', 'pageType': 'home', 'label': '首页', 'icon': 'home'},
        ];
        json['pages'] = [
          {
            'pageId': 'home',
            'pageType': 'home',
            'title': '隐藏的标题',
            'regions': {'introduction': false},
            'appearance': {'showTitle': false},
          },
        ];
        await pumpTestAdmin9App(
          tester,
          pageConfiguration: PageConfiguration.fromJson(json)!,
          size: Size(width, 844),
          textScale: 2,
        );
        expect(find.text('隐藏的标题'), findsNothing);
        expect(find.byKey(const ValueKey('home-product-name')), findsNothing);
        expect(find.text('暂无内容'), findsOneWidget);
        expect(find.byKey(const ValueKey('home-open-settings')), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'invalid local configuration shows a configuration error without retry routes',
    (tester) async {
      await pumpTestAdmin9App(
        tester,
        configurationError: const FormatException(
          'Unsupported schemaVersion: 7',
        ),
      );
      expect(find.text('页面配置错误'), findsOneWidget);
      expect(find.textContaining('schemaVersion: 7'), findsOneWidget);
      expect(find.byType(FBottomNavigationBar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
