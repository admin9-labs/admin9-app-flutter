import 'package:admin9_app_flutter/admin9_ui.dart';
import 'package:admin9_app_flutter/app/brand/app_brand_theme.dart';
import 'package:admin9_app_flutter/core/design_system/gallery/app_gallery_registry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('public non-visual contracts are constructible', () {
    const destination = AppNavigationDestination(
      label: '首页',
      icon: AppIconRole.home,
      selectedIcon: AppIconRole.homeSelected,
    );
    const choice = AppChoice<int>(value: 1, label: '选项');
    const menuItem = AppActionMenuItem<int>(value: 1, label: '操作');

    expect(destination.selectedIcon, AppIconRole.homeSelected);
    expect(choice.value, 1);
    expect(menuItem.enabled, isTrue);
    expect(appBrandTheme.radiusDelta, 0);
  });

  testWidgets('token lookup is a real inherited mechanism', (tester) async {
    final tokens = _TestTokens();
    late AppDesignTokens resolved;
    await tester.pumpWidget(
      AppDesignScope(
        tokens: tokens,
        child: Builder(
          builder: (context) {
            resolved = AppDesignScope.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(resolved, same(tokens));
  });

  testWidgets('controller hosts resolve the installed owners', (tester) async {
    final feedback = _FeedbackController();
    final interaction = _InteractionController();
    late AppFeedbackController resolvedFeedback;
    late AppInteractionController resolvedInteraction;
    await tester.pumpWidget(
      AppFeedbackHost(
        controller: feedback,
        child: AppInteractionHost(
          controller: interaction,
          child: Builder(
            builder: (context) {
              resolvedFeedback = AppFeedbackHost.of(context);
              resolvedInteraction = AppInteractionHost.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(resolvedFeedback, same(feedback));
    expect(resolvedInteraction, same(interaction));
  });

  testWidgets('missing lookup hosts fail with named configuration errors', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      Builder(
        builder: (value) {
          context = value;
          return const SizedBox.shrink();
        },
      ),
    );

    expect(() => AppDesignScope.of(context), throwsA(isA<FlutterError>()));
    expect(() => AppFeedbackHost.of(context), throwsA(isA<FlutterError>()));
    expect(() => AppInteractionHost.of(context), throwsA(isA<FlutterError>()));
  });

  test('Gallery registry is present only outside release mode', () {
    expect(AppGalleryRegistry.isRegistered, !kReleaseMode);
    expect(
      AppGalleryRegistry.registeredRouteNames.contains(
        AppGalleryRegistry.routeName,
      ),
      !kReleaseMode,
    );
  });
}

class _TestTokens implements AppDesignTokens {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FeedbackController implements AppFeedbackController {
  @override
  void dismiss() {}

  @override
  void show(AppFeedbackRequest request) {}
}

class _InteractionController implements AppInteractionController {
  @override
  Future<T?> showActionMenu<T extends Object>({
    String? title,
    required List<AppActionMenuItem<T>> items,
    String cancelLabel = '取消',
  }) async => null;

  @override
  Future<bool> showConfirmation({
    required String title,
    required String message,
    required String confirmLabel,
  }) async => false;

  @override
  Future<bool> showDestructive({
    required String title,
    required String message,
    required String confirmLabel,
  }) async => false;

  @override
  Future<void> showInformation({
    required String title,
    required String message,
  }) async {}
}
