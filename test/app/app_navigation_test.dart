import 'package:admin9_app_flutter/features/content/presentation/pages/content_page.dart';
import 'package:admin9_app_flutter/features/feedback/presentation/pages/feedback_page.dart';
import 'package:admin9_app_flutter/features/forms/presentation/pages/forms_page.dart';
import 'package:admin9_app_flutter/features/forms/presentation/pages/text_input_page.dart';
import 'package:admin9_app_flutter/features/foundation/presentation/pages/foundation_page.dart';
import 'package:admin9_app_flutter/features/settings/presentation/pages/settings_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';

import 'support/test_admin9_app.dart';

void main() {
  testWidgets('starts five tabs and retains a typed detail route per branch', (
    tester,
  ) async {
    await pumpTestAdmin9App(tester);

    final navigation = find.byType(FBottomNavigationBar);
    expect(navigation, findsOneWidget);
    expect(
      find.descendant(
        of: navigation,
        matching: find.byType(FBottomNavigationBarItem),
      ),
      findsNWidgets(5),
    );
    for (final label in ['基础', '表单', '内容', '反馈', '设置']) {
      expect(
        find.descendant(of: navigation, matching: find.text(label)),
        findsOneWidget,
      );
    }
    expect(find.byType(FoundationPage), findsOneWidget);

    await _selectDestination(tester, '表单');
    expect(find.byType(FormsPage), findsOneWidget);

    await tester.tap(find.text('文本输入'));
    await tester.pumpAndSettle();
    expect(find.byType(TextInputPage), findsOneWidget);

    await _selectDestination(tester, '内容');
    expect(find.byType(ContentPage), findsOneWidget);

    await _selectDestination(tester, '反馈');
    expect(find.byType(FeedbackPage), findsOneWidget);

    await _selectDestination(tester, '设置');
    expect(find.byType(SettingsPage), findsOneWidget);

    await _selectDestination(tester, '表单');
    expect(find.byType(TextInputPage), findsOneWidget);

    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(find.byType(FormsPage), findsOneWidget);
    expect(find.byType(TextInputPage), findsNothing);
  });
}

Future<void> _selectDestination(WidgetTester tester, String label) async {
  final navigation = find.byType(FBottomNavigationBar);
  await tester.tap(find.descendant(of: navigation, matching: find.text(label)));
  await tester.pumpAndSettle();
}
