import 'package:admin9_app_flutter/app/routing/app_router.gr.dart';
import 'package:admin9_app_flutter/features/authentication/presentation/widgets/authentication_form.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

@RoutePage(name: 'LoginRoute')
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => FScaffold(
    header: FHeader.nested(
      title: Text(context.tr('authentication.login_title')),
      prefixes: [
        FHeaderAction.back(
          key: const ValueKey('authentication-back'),
          onPress: context.router.maybePop,
        ),
      ],
    ),
    child: AuthenticationForm(
      register: false,
      onAuthenticated: () => context.router.maybePop(),
      onSwitchMode: () => context.router.replace(const RegisterRoute()),
    ),
  );
}
