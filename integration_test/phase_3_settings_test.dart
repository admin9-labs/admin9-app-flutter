import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/core/theme/app_appearance.dart';
import 'package:admin9_app_flutter/core/theme/appearance_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'settings preferences apply immediately and survive host reconstruction',
    (tester) async {
      final preferences = await SharedPreferences.getInstance();
      await preferences.clear();
      await preferences.setBool('admin9.privacy.accepted', true);
      await tester.pumpWidget(Admin9App(preferences: preferences));
      await tester.pumpAndSettle();

      await tester.tap(find.text('我的'));
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const Key('account-page-list')),
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('设置'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('settings-theme')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('深色'));
      await tester.pumpAndSettle();
      expect(preferences.getString('admin9.appearance.theme_mode'), 'dark');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('settings-font-scale')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('特大'));
      await tester.pumpAndSettle();
      expect(
        preferences.getString('admin9.appearance.font_scale'),
        'extraLarge',
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      await tester.tap(find.text('高对比度'));
      await tester.pumpAndSettle();
      expect(preferences.getBool('admin9.accessibility.high_contrast'), isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(Admin9App(preferences: preferences));
      await tester.pumpAndSettle();
      final restored = tester
          .element(find.byType(MaterialApp))
          .read<AppearanceController>()
          .appearance;
      expect(restored.theme, AppThemePreference.dark);
      expect(restored.fontScale, AppFontScale.extraLarge);
      expect(restored.highContrast, isTrue);
    },
  );
}
