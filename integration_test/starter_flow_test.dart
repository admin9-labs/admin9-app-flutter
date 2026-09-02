import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_provider.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_repository.dart';
import 'package:admin9_app_flutter/app/appearance/app_appearance_service.dart';
import 'package:admin9_app_flutter/app/startup/startup_preferences.dart';
import 'package:admin9_app_flutter/app/startup/startup_preferences_repository.dart';
import 'package:admin9_app_flutter/app/startup/startup_preferences_service.dart';
import 'package:admin9_app_flutter/app/startup/startup_provider.dart';
import 'package:admin9_app_flutter/features/home/presentation/pages/home_page.dart';
import 'package:admin9_app_flutter/features/media/presentation/pages/article_page.dart';
import 'package:admin9_app_flutter/features/media/presentation/pages/media_page.dart';
import 'package:admin9_app_flutter/features/settings/presentation/pages/settings_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(EasyLocalization.ensureInitialized);

  testWidgets('navigates the starter and persists its theme preference', (
    tester,
  ) async {
    final previousPlatform = SharedPreferencesAsyncPlatform.instance;
    final preferences = InMemorySharedPreferencesAsync.empty();
    SharedPreferencesAsyncPlatform.instance = preferences;
    addTearDown(() {
      SharedPreferencesAsyncPlatform.instance = previousPlatform;
    });
    final repository = SharedPreferencesAppAppearanceRepository(
      AppAppearanceService(SharedPreferencesAsync()),
    );
    final startupRepository = SharedPreferencesStartupRepository(
      StartupPreferencesService(SharedPreferencesAsync()),
    );
    await startupRepository.save(
      StartupPreferences(
        privacyConsent: PrivacyConsentRecord(
          policyVersion: currentPrivacyPolicyVersion,
          acceptedAt: DateTime.utc(2026, 9, 1),
        ),
        onboardingVersion: currentOnboardingVersion,
      ),
    );

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('zh', 'CN')],
        fallbackLocale: const Locale('zh', 'CN'),
        startLocale: const Locale('zh', 'CN'),
        path: 'assets/translations',
        saveLocale: false,
        child: ProviderScope(
          overrides: [
            appAppearanceRepositoryProvider.overrideWithValue(repository),
            startupPreferencesRepositoryProvider.overrideWithValue(
              startupRepository,
            ),
          ],
          child: const Admin9App(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.byType(FBottomNavigationBarItem), findsNWidgets(4));

    await _selectDestination(tester, '媒体');
    expect(find.byType(MediaPage), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('media-open-article')));
    await tester.pumpAndSettle();
    expect(find.byType(ArticlePage), findsOneWidget);
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _verifyIosEdgeBack(tester);
    } else {
      expect(await tester.binding.handlePopRoute(), isTrue);
      await tester.pumpAndSettle();
    }
    expect(find.byType(MediaPage), findsOneWidget);

    await _selectDestination(tester, '设置');
    expect(find.byType(SettingsPage), findsOneWidget);
    await tester.tap(find.text('暗色'));
    await tester.pumpAndSettle();

    expect(
      await preferences.getString(
        AppAppearanceService.key,
        const SharedPreferencesOptions(),
      ),
      contains('"brightness":"dark"'),
    );
  });
}

Future<void> _verifyIosEdgeBack(WidgetTester tester) async {
  final viewSize = tester.view.physicalSize / tester.view.devicePixelRatio;
  final start = Offset(1, viewSize.height / 2);
  final cancelDistance = viewSize.width * 0.2;
  final cancelGesture = await tester.startGesture(start);
  await cancelGesture.moveBy(Offset(cancelDistance, 0));
  await tester.pump(const Duration(milliseconds: 120));
  await cancelGesture.moveBy(Offset(-cancelDistance, 0));
  await cancelGesture.up();
  await tester.pumpAndSettle();
  expect(find.byType(ArticlePage), findsOneWidget);

  await tester.timedDragFrom(
    start,
    Offset(viewSize.width * 0.9, 0),
    const Duration(milliseconds: 300),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectDestination(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(FBottomNavigationBar),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}
