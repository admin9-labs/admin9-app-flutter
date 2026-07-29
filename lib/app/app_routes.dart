import 'package:flutter/material.dart';

import '../core/design_system/foundation/app_theme.dart';
import '../core/design_system/gallery/app_gallery_page.dart';
import '../core/design_system/gallery/app_gallery_registry.dart';
import '../ui/features/about/views/about_page.dart';
import '../ui/features/about/views/contact_page.dart';
import '../ui/features/account/views/account_deletion_page.dart';
import '../ui/features/account/views/account_security_page.dart';
import '../ui/features/account/views/profile_page.dart';
import '../ui/features/auth/views/auth_form_page.dart';
import '../ui/features/legal/models/legal_document.dart';
import '../ui/features/legal/views/legal_document_page.dart';
import '../ui/features/settings/views/settings_page.dart';
import 'app_route_names.dart';
import 'brand/app_brand_theme.dart';

abstract final class AppRouteFactory {
  static Route<void> onGenerateRoute(RouteSettings settings) {
    if (settings.name == AppGalleryRegistry.routeName &&
        AppGalleryRegistry.isRegistered) {
      return _platformRoute(
        settings: settings,
        page: AppGalleryPage(resolveTheme: _resolveGalleryTheme),
      );
    }
    final requestedParent = settings.arguments;
    assert(requestedParent == null || requestedParent is String);
    final page = switch (settings.name) {
      AppRoutes.login => AuthFormPage(
        flow: AuthFlow.login,
        parentLabel: _parentLabel(requestedParent, '我的'),
      ),
      AppRoutes.register => AuthFormPage(
        flow: AuthFlow.register,
        parentLabel: _parentLabel(requestedParent, '我的'),
      ),
      AppRoutes.forgotPassword => AuthFormPage(
        flow: AuthFlow.forgotPassword,
        parentLabel: _parentLabel(requestedParent, '登录'),
      ),
      AppRoutes.resetPassword => AuthFormPage(
        flow: AuthFlow.resetPassword,
        parentLabel: _parentLabel(requestedParent, '忘记密码'),
      ),
      AppRoutes.changePassword => AuthFormPage(
        flow: AuthFlow.changePassword,
        parentLabel: _parentLabel(requestedParent, '账号安全'),
      ),
      AppRoutes.accountRecovery => AuthFormPage(
        flow: AuthFlow.accountRecovery,
        parentLabel: _parentLabel(requestedParent, '我的'),
      ),
      AppRoutes.profile => const ProfilePage(),
      AppRoutes.accountSecurity => const AccountSecurityPage(),
      AppRoutes.accountDeletion => const AccountDeletionPage(),
      AppRoutes.settings => const SettingsPage(),
      AppRoutes.theme => const SettingsThemePage(),
      AppRoutes.fontScale => const SettingsFontScalePage(),
      AppRoutes.userAgreement => LegalDocumentPage(
        document: LegalDocument(type: LegalDocumentType.userAgreement),
        parentLabel: _parentLabel(requestedParent, '我的'),
      ),
      AppRoutes.privacyPolicy => LegalDocumentPage(
        document: LegalDocument(type: LegalDocumentType.privacyPolicy),
        parentLabel: _parentLabel(requestedParent, '我的'),
      ),
      AppRoutes.about => const AboutPage(),
      AppRoutes.contact => const ContactPage(),
      _ => _UnknownRoutePage(routeName: settings.name),
    };

    return _platformRoute(settings: settings, page: page);
  }

  static Route<void> _platformRoute({
    required RouteSettings settings,
    required Widget page,
  }) => MaterialPageRoute<void>(settings: settings, builder: (_) => page);

  static String _parentLabel(Object? requested, String fallback) {
    if (requested case final String value when value.isNotEmpty) return value;
    return fallback;
  }

  static AppResolvedTheme _resolveGalleryTheme({
    required Brightness brightness,
    required TargetPlatform platform,
    required bool highContrast,
    required bool reduceMotion,
    required bool boldText,
  }) => AppTheme.resolve(
    brightness: brightness,
    highContrast: highContrast,
    reduceMotion: reduceMotion,
    boldText: boldText,
    platform: platform,
    brandPrimary: brightness == Brightness.dark
        ? appBrandTheme.primaryDark
        : appBrandTheme.primaryLight,
    brandSecondary: brightness == Brightness.dark
        ? appBrandTheme.secondaryDark
        : appBrandTheme.secondaryLight,
    brandFontFamily: appBrandTheme.fontFamily,
    brandRadiusDelta: appBrandTheme.radiusDelta,
  );
}

class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage({this.routeName});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('页面不存在')),
      body: Center(child: Text(routeName ?? '未知页面')),
    );
  }
}
