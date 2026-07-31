import 'package:admin9_app_flutter/admin9_ui.dart';
import 'package:admin9_app_flutter/app/brand/app_brand_theme.dart';
import 'package:admin9_app_flutter/core/design_system/components/app_feedback.dart';
import 'package:flutter/widgets.dart';

Widget instantiateDesignScope(AppDesignTokens tokens) =>
    AppDesignScope(tokens: tokens, child: const SizedBox.shrink());

Widget instantiateFeedbackHost(AppFeedbackController controller) =>
    AppFeedbackHost(controller: controller, child: const SizedBox.shrink());

Widget instantiateFeedback(
  AppFeedbackController controller,
  GlobalKey<NavigatorState> navigatorKey,
) => AppFeedback(
  controller: controller,
  navigatorKey: navigatorKey,
  child: const SizedBox.shrink(),
);

Widget instantiateInteractionHost(AppInteractionController controller) =>
    AppInteractionHost(controller: controller, child: const SizedBox.shrink());

const pageAction = AppPageAction(
  label: '关闭',
  icon: AppIconRole.close,
  onPressed: _noOp,
);

const navigationDestination = AppNavigationDestination(
  label: '首页',
  icon: AppIconRole.home,
  selectedIcon: AppIconRole.homeSelected,
);

const actionMenuItem = AppActionMenuItem<int>(value: 1, label: '操作');
const feedbackRequest = AppFeedbackRequest(
  message: '状态已更新',
  tone: AppTone.info,
);
const appearanceContract = AppAppearance(
  theme: AppThemePreference.system,
  fontScale: AppFontScale.extraLarge,
);

const brandContract = appBrandTheme;

void _noOp() {}

void main() {
  assert(pageAction.label.isNotEmpty);
  assert(navigationDestination.label.isNotEmpty);
  assert(actionMenuItem.value == 1);
  assert(feedbackRequest.actionLabel == null);
  assert(appearanceContract.fontScale.factor == 1.24);
  assert(brandContract.radiusDelta == 0);
}
