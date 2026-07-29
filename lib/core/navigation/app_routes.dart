import 'package:flutter/material.dart';

import '../../ui/features/about/views/about_page.dart';
import '../../ui/features/about/views/contact_page.dart';
import '../../ui/features/account/views/account_deletion_page.dart';
import '../../ui/features/account/views/account_security_page.dart';
import '../../ui/features/account/views/profile_page.dart';
import '../../ui/features/auth/views/auth_form_page.dart';
import '../../ui/features/legal/models/legal_document.dart';
import '../../ui/features/legal/views/legal_document_page.dart';
import '../../ui/features/settings/views/settings_page.dart';

class AppRoutes {
  const AppRoutes._();

  static const login = '/auth/login';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';
  static const changePassword = '/auth/change-password';
  static const accountRecovery = '/auth/account-recovery';
  static const profile = '/account/profile';
  static const accountSecurity = '/account/security';
  static const accountDeletion = '/account/deletion';
  static const settings = '/settings';
  static const userAgreement = '/legal/user-agreement';
  static const privacyPolicy = '/legal/privacy-policy';
  static const about = '/about';
  static const contact = '/about/contact';

  static Route<void> onGenerateRoute(RouteSettings settings) {
    final page = switch (settings.name) {
      login => const AuthFormPage(flow: AuthFlow.login),
      register => const AuthFormPage(flow: AuthFlow.register),
      forgotPassword => const AuthFormPage(flow: AuthFlow.forgotPassword),
      resetPassword => const AuthFormPage(flow: AuthFlow.resetPassword),
      changePassword => const AuthFormPage(flow: AuthFlow.changePassword),
      accountRecovery => const AuthFormPage(flow: AuthFlow.accountRecovery),
      profile => const ProfilePage(),
      accountSecurity => const AccountSecurityPage(),
      accountDeletion => const AccountDeletionPage(),
      AppRoutes.settings => const SettingsPage(),
      userAgreement => const LegalDocumentPage(
        document: LegalDocument(type: LegalDocumentType.userAgreement),
      ),
      privacyPolicy => const LegalDocumentPage(
        document: LegalDocument(type: LegalDocumentType.privacyPolicy),
      ),
      about => const AboutPage(),
      contact => const ContactPage(),
      _ => _UnknownRoutePage(routeName: settings.name),
    };

    return MaterialPageRoute<void>(settings: settings, builder: (_) => page);
  }
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
