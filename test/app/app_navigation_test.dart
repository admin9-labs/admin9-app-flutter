import 'package:admin9_app_flutter/features/examples/presentation/pages/catalog/content_page.dart';
import 'package:admin9_app_flutter/features/examples/presentation/pages/catalog/feedback_page.dart';
import 'package:admin9_app_flutter/features/examples/presentation/pages/catalog/forms_page.dart';
import 'package:admin9_app_flutter/features/examples/presentation/pages/catalog/foundation_page.dart';
import 'package:admin9_app_flutter/features/examples/presentation/pages/form/text_input/text_input_playground_page.dart';
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

    final textFieldEntry = find.text('资料表单实验台');
    await tester.ensureVisible(textFieldEntry);
    await tester.tap(textFieldEntry);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(TextInputPlaygroundPage), findsOneWidget);

    await _selectDestination(tester, '内容');
    expect(find.byType(ContentPage), findsOneWidget);

    await _selectDestination(tester, '反馈');
    expect(find.byType(FeedbackPage), findsOneWidget);

    await _selectDestination(tester, '设置');
    expect(find.byType(SettingsPage), findsOneWidget);

    await _selectDestination(tester, '表单');
    expect(find.byType(TextInputPlaygroundPage), findsOneWidget);

    expect(await tester.binding.handlePopRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(find.byType(FormsPage), findsOneWidget);
    expect(find.byType(TextInputPlaygroundPage), findsNothing);
  });
}

Future<void> _selectDestination(WidgetTester tester, String label) async {
  final navigation = find.byType(FBottomNavigationBar);
  await tester.tap(find.descendant(of: navigation, matching: find.text(label)));
  await tester.pumpAndSettle();
}
