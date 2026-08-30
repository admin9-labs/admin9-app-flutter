import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/features/forms/presentation/pages/forms_page.dart';
import 'package:admin9_app_flutter/features/forms/presentation/pages/text_input_page.dart';
import 'package:admin9_app_flutter/features/settings/data/repositories/theme_preference_repository.dart';
import 'package:admin9_app_flutter/features/settings/data/services/theme_preference_service.dart';
import 'package:admin9_app_flutter/features/settings/presentation/providers/theme_preference_provider.dart';
import 'package:easy_localization/easy_localization.dart';
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
    final repository = SharedPreferencesThemePreferenceRepository(
      ThemePreferenceService(SharedPreferencesAsync()),
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
            themePreferenceRepositoryProvider.overrideWithValue(repository),
          ],
          child: const Admin9App(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FBottomNavigationBarItem), findsNWidgets(5));

    await _selectDestination(tester, '表单');
    expect(find.byType(FormsPage), findsOneWidget);
    await tester.tap(find.text('文本输入'));
    await tester.pumpAndSettle();
    expect(find.byType(TextInputPage), findsOneWidget);
    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(find.byType(FormsPage), findsOneWidget);

    await _selectDestination(tester, '设置');
    await tester.tap(find.text('暗色'));
    await tester.pumpAndSettle();

    expect(
      await preferences.getString(
        ThemePreferenceService.key,
        const SharedPreferencesOptions(),
      ),
      'dark',
    );
  });
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
