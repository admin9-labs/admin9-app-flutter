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
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => AppGalleryPage(resolveTheme: _resolveGalleryTheme),
      );
    }
    final page = switch (settings.name) {
      AppRoutes.login => const AuthFormPage(flow: AuthFlow.login),
      AppRoutes.register => const AuthFormPage(flow: AuthFlow.register),
      AppRoutes.forgotPassword => const AuthFormPage(
        flow: AuthFlow.forgotPassword,
      ),
      AppRoutes.resetPassword => const AuthFormPage(
        flow: AuthFlow.resetPassword,
      ),
      AppRoutes.changePassword => const AuthFormPage(
        flow: AuthFlow.changePassword,
      ),
      AppRoutes.accountRecovery => const AuthFormPage(
        flow: AuthFlow.accountRecovery,
      ),
      AppRoutes.profile => const ProfilePage(),
      AppRoutes.accountSecurity => const AccountSecurityPage(),
      AppRoutes.accountDeletion => const AccountDeletionPage(),
      AppRoutes.settings => const SettingsPage(),
      AppRoutes.userAgreement => const LegalDocumentPage(
        document: LegalDocument(type: LegalDocumentType.userAgreement),
      ),
      AppRoutes.privacyPolicy => const LegalDocumentPage(
        document: LegalDocument(type: LegalDocumentType.privacyPolicy),
      ),
      AppRoutes.about => const AboutPage(),
      AppRoutes.contact => const ContactPage(),
      _ => _UnknownRoutePage(routeName: settings.name),
    };

    return MaterialPageRoute<void>(settings: settings, builder: (_) => page);
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
