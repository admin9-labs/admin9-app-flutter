import 'package:admin9_app_flutter/app/admin9_app.dart';
import 'package:admin9_app_flutter/core/design_system/gallery/app_gallery_page.dart';
import 'package:admin9_app_flutter/core/design_system/gallery/app_gallery_registry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('profile build registers and opens the internal Gallery', (
    tester,
  ) async {
    expect(kProfileMode, isTrue);
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    await preferences.setBool('admin9.privacy.accepted', true);
    await tester.pumpWidget(Admin9App(preferences: preferences));
    await tester.pumpAndSettle();

    expect(AppGalleryRegistry.isRegistered, isTrue);
    Navigator.of(
      tester.element(find.byType(Scaffold).first),
    ).pushNamed(AppGalleryRegistry.routeName);
    await tester.pumpAndSettle();

    expect(find.byType(AppGalleryPage), findsOneWidget);
    expect(find.text('Admin9 Gallery'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
