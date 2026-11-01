import 'package:admin9_app_flutter/features/authentication/domain/authentication_state.dart';
import 'package:admin9_app_flutter/features/authentication/presentation/providers/authentication_provider.dart';
import 'package:admin9_app_flutter/shared/ui/responsive_page_body.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

class AuthenticationForm extends ConsumerStatefulWidget {
  const AuthenticationForm({
    required this.register,
    required this.onAuthenticated,
    required this.onSwitchMode,
    super.key,
  });

  final bool register;
  final VoidCallback onAuthenticated;
  final VoidCallback onSwitchMode;

  @override
  ConsumerState<AuthenticationForm> createState() => _AuthenticationFormState();
}

class _AuthenticationFormState extends ConsumerState<AuthenticationForm> {
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _validationError = false;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authenticationProvider);
    final busy = state.status == AuthenticationStatus.submitting;
    return ResponsivePageBody(
      children: [
        FTextField.email(
          key: const ValueKey('authentication-identifier'),
          control: .managed(controller: _identifier),
          enabled: !busy,
          label: Text(context.tr('authentication.identifier')),
        ),
        FTextField.password(
          key: const ValueKey('authentication-password'),
          control: .managed(controller: _password),
          enabled: !busy,
          label: Text(context.tr('authentication.password')),
        ),
        if (_validationError || state.status == AuthenticationStatus.failure)
          Text(
            context.tr(
              _validationError
                  ? 'authentication.invalid_input'
                  : 'authentication.failed',
            ),
            key: const ValueKey('authentication-error'),
            style: FTheme.of(context).typography.body.sm
                .copyWith(color: FTheme.of(context).colors.destructive),
          ),
        FButton(
          key: const ValueKey('authentication-submit'),
          onPress: busy ? null : _submit,
          child: Text(
            context.tr(
              widget.register
                  ? 'authentication.register'
                  : 'authentication.login',
            ),
          ),
        ),
        FButton(
          key: const ValueKey('authentication-switch-mode'),
          variant: .ghost,
          onPress: busy ? null : widget.onSwitchMode,
          child: Flexible(
            child: Text(
              context.tr(
                widget.register
                    ? 'authentication.have_account'
                    : 'authentication.need_account',
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final identifier = _identifier.text.trim();
    final password = _password.text;
    setState(() {
      _validationError = identifier.length < 3 || password.length < 6;
    });
    if (_validationError) return;
    final succeeded = widget.register
        ? await ref
              .read(authenticationProvider.notifier)
              .register(identifier, password)
        : await ref
              .read(authenticationProvider.notifier)
              .login(identifier, password);
    if (succeeded && mounted) widget.onAuthenticated();
  }
}
