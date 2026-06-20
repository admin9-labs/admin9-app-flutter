import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/core/widgets/live_stream_player.dart';

void main() {
  testWidgets(
    'Admin9Shell keeps hidden live tab from building stream players',
    (tester) async {
      final playerBuilds = <String>[];
      await _pumpApp(
        tester,
        liveStreamPlayerBuilder: (context, config, muted, onMutedChanged) {
          playerBuilds.add(config.title);
          return ColoredBox(
            key: Key('recording-live-player-${config.title}'),
            color: Colors.black,
            child: Text(config.url),
          );
        },
      );

      expect(playerBuilds, isEmpty);
      await _login(tester);
      expect(playerBuilds, isEmpty);

      await tester.tap(find.text('直播').last);
      await tester.pumpAndSettle();

      expect(playerBuilds, contains('四川卫视'));
      expect(
        find.byKey(const Key('recording-live-player-四川卫视')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('tv-live-inactive-gate')), findsNothing);

      await tester.tap(find.text('首页').last);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('recording-live-player-四川卫视')), findsNothing);
      expect(
        find.byKey(const Key('tv-live-inactive-gate'), skipOffstage: false),
        findsOneWidget,
      );
    },
  );
}

Future<void> _pumpApp(
  WidgetTester tester, {
  required LiveStreamPlayerBuilder liveStreamPlayerBuilder,
}) async {
  SharedPreferences.setMockInitialValues({
    'privacy_guide_accepted': true,
    'onboarding_completed': true,
  });
  final preferences = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    Admin9App(
      preferences: preferences,
      channelH5WebViewBuilder: _fakeChannelH5WebViewBuilder,
      liveStreamPlayerBuilder: liveStreamPlayerBuilder,
    ),
  );
  await tester.pump();
  final splashSkip = find.byKey(const Key('splash-skip'));
  if (splashSkip.evaluate().isNotEmpty) {
    await tester.tap(splashSkip);
  }
  await tester.pumpAndSettle();
}

Widget _fakeChannelH5WebViewBuilder(
  BuildContext context,
  Uri uri,
  String channelId,
  String channelLabel,
) {
  return SizedBox.expand(
    child: Text(uri.toString(), key: Key('fake-channel-h5-url-$channelId')),
  );
}

Future<void> _login(WidgetTester tester) async {
  await tester.tap(find.text('我的').last);
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.widgetWithText(FilledButton, '登录'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, '登录'));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('auth-code-field')), findsOneWidget);
  await tester.tap(find.bySemanticsLabel('同意登录协议'));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const Key('auth-phone-field')),
    '13800138000',
  );
  await tester.enterText(find.byKey(const Key('auth-code-field')), '123456');
  await tester.ensureVisible(find.byKey(const Key('auth-submit')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('auth-submit')));
  await tester.pumpAndSettle();
}
