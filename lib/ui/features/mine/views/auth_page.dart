import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/navigation/app_navigator.dart';
import '../../../../core/theme/app_appearance.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_pill_button.dart';
import '../../../../data/repositories/foundation_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../foundation/views/agreement_page.dart';
import '../view_models/session_view_model.dart';

enum _AuthLoginStep { oneTap, smsCode }

class AuthPage extends StatefulWidget {
  const AuthPage({
    super.key,
    this.oneTapAvailable = false,
    this.prototypeAuthConfig,
  });

  final bool oneTapAvailable;
  final PrototypeAuthConfig? prototypeAuthConfig;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  late _AuthLoginStep _step = widget.oneTapAvailable
      ? _AuthLoginStep.oneTap
      : _AuthLoginStep.smsCode;

  bool _agreed = false;

  PrototypeAuthConfig get _authConfig =>
      widget.prototypeAuthConfig ??
      context.read<UserRepository>().prototypeAuthConfig;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _AuthPalette.resolve(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: '关闭',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(_step == _AuthLoginStep.oneTap ? '本机号码登录' : '手机号登录'),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 660;
            final horizontalPadding = constraints.maxWidth < 360
                ? AppSpacing.xl
                : AppSpacing.xxl;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                compact ? AppSpacing.lg : AppSpacing.xxl,
                horizontalPadding,
                AppSpacing.xxxl,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 430,
                    minHeight: constraints.maxHeight - AppSpacing.xxxl,
                  ),
                  child: _step == _AuthLoginStep.oneTap
                      ? _buildOneTapPage(context, compact: compact)
                      : _buildSmsCodePage(context, compact: compact),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOneTapPage(BuildContext context, {required bool compact}) {
    final colors = _AuthPalette.resolve(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _PrototypeAuthNotice(),
        const SizedBox(height: AppSpacing.lg),
        const _AuthIdentity(),
        SizedBox(height: compact ? AppSpacing.xxl : 44),
        Text('当前号码', style: _sectionLabelStyle(context)),
        const SizedBox(height: AppSpacing.md),
        _PhonePreview(phone: _authConfig.oneTapMaskedPhone),
        const SizedBox(height: AppSpacing.xxl),
        _AgreementConsent(
          agreed: _agreed,
          variant: _AgreementVariant.oneTap,
          onChanged: _setAgreed,
          onOpen: _openAgreement,
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryPillButton(
          key: const Key('one-tap-login'),
          label: '原型本机号码一键登录',
          onPressed: () => _loginWithAgreement(_authConfig.oneTapPhone),
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton(
          key: const Key('other-phone-login'),
          onPressed: () => setState(() => _step = _AuthLoginStep.smsCode),
          style: TextButton.styleFrom(
            foregroundColor: colors.textSecondary,
            minimumSize: const Size.fromHeight(44),
            textStyle: context.typography.buttonLabel,
          ),
          child: const Text('其他手机号登录'),
        ),
      ],
    );
  }

  Widget _buildSmsCodePage(BuildContext context, {required bool compact}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _PrototypeAuthNotice(),
        const SizedBox(height: AppSpacing.lg),
        const _AuthIdentity(),
        SizedBox(height: compact ? AppSpacing.xxl : 44),
        Text('手机号码', style: _sectionLabelStyle(context)),
        const SizedBox(height: AppSpacing.md),
        TextField(
          key: const Key('auth-phone-field'),
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: _authInputDecoration(context, hintText: '请输入手机号'),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          key: const Key('auth-code-field'),
          controller: _codeController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          decoration: _authInputDecoration(
            context,
            hintText: '请输入验证码',
            suffix: _VerificationCodeButton(onPressed: _fillVerificationCode),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _AgreementConsent(
          agreed: _agreed,
          variant: _AgreementVariant.smsCode,
          onChanged: _setAgreed,
          onOpen: _openAgreement,
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryPillButton(
          key: const Key('auth-submit'),
          label: '登录',
          onPressed: _submit,
        ),
        SizedBox(height: compact ? 44 : 96),
        _OtherLoginMethods(onLogin: _thirdPartyLogin),
      ],
    );
  }

  InputDecoration _authInputDecoration(
    BuildContext context, {
    required String hintText,
    Widget? suffix,
  }) {
    final colors = _AuthPalette.resolve(context);
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: colors.inputFill,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      suffixIcon: suffix,
      suffixIconConstraints: const BoxConstraints(minWidth: 104),
      hintStyle: TextStyle(
        color: colors.hint,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: colors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: colors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: colors.primary.withValues(alpha: 0.36)),
      ),
    );
  }

  TextStyle? _sectionLabelStyle(BuildContext context) {
    final colors = _AuthPalette.resolve(context);
    return Theme.of(context).textTheme.titleSmall?.copyWith(
      color: colors.textSecondary,
      fontWeight: FontWeight.w700,
    );
  }

  void _setAgreed(bool value) {
    setState(() => _agreed = value);
  }

  void _openAgreement(String id) {
    final repository = context.read<FoundationRepository>();
    AppNavigator.push(
      context,
      AgreementPage(document: repository.agreement(id)),
    );
  }

  void _submit() {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();
    if (phone.length != 11) {
      _showMessage('请输入 11 位手机号');
      return;
    }
    if (!_agreed) {
      _showMessage('请先同意用户协议和隐私政策');
      return;
    }
    final config = _authConfig;
    if (!config.enabled) {
      _showMessage('原型演示登录已关闭，无法使用本地模拟认证');
      return;
    }
    if (code != config.smsCode) {
      _showMessage('原型演示验证码不正确，请输入本地模拟验证码');
      return;
    }
    _loginWithAgreement(phone);
  }

  void _fillVerificationCode() {
    final config = _authConfig;
    if (!config.enabled) {
      _showMessage('原型演示登录已关闭，无法发送本地模拟验证码');
      return;
    }
    _codeController.text = config.smsCode;
    _showMessage('原型演示验证码已填入：${config.smsCode}');
  }

  void _thirdPartyLogin(String nickname) {
    if (!_agreed) {
      _showMessage('请先同意用户协议和隐私政策');
      return;
    }
    if (!_authConfig.enabled) {
      _showMessage('原型演示登录已关闭，无法使用本地模拟认证');
      return;
    }
    context.read<SessionViewModel>().login(
      phone: _authConfig.oneTapPhone,
      nickname: nickname,
    );
    Navigator.of(context).pop();
  }

  void _loginWithAgreement(String phone) {
    if (!_agreed) {
      _showMessage('请先同意用户协议和隐私政策');
      return;
    }
    if (!_authConfig.enabled) {
      _showMessage('原型演示登录已关闭，无法使用本地模拟认证');
      return;
    }
    context.read<SessionViewModel>().login(phone: phone, nickname: '新闻用户');
    Navigator.of(context).pop();
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PrototypeAuthNotice extends StatelessWidget {
  const _PrototypeAuthNotice();

  @override
  Widget build(BuildContext context) {
    final colors = _AuthPalette.resolve(context);
    return Container(
      key: const Key('prototype-auth-notice'),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.primary.withValues(alpha: 0.24)),
      ),
      child: Text(
        '原型演示登录：SMS、一键登录和第三方入口均为本地模拟，不代表真实认证。',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colors.textSecondary,
          height: 1.45,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AuthIdentity extends StatelessWidget {
  const _AuthIdentity();

  @override
  Widget build(BuildContext context) {
    final colors = _AuthPalette.resolve(context);
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colors.primarySoft,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '融',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '西昌发布',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '账号登录（原型）',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.textTertiary),
            ),
          ],
        ),
      ],
    );
  }
}

class _PhonePreview extends StatelessWidget {
  const _PhonePreview({required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    final colors = _AuthPalette.resolve(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: colors.inputFill,
        border: Border.all(color: colors.divider),
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(
        children: [
          Icon(Icons.phone_iphone_rounded, color: colors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              phone,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
          Text(
            '本地模拟认证',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum _AgreementVariant { oneTap, smsCode }

class _AgreementConsent extends StatelessWidget {
  const _AgreementConsent({
    required this.agreed,
    required this.variant,
    required this.onChanged,
    required this.onOpen,
  });

  final bool agreed;
  final _AgreementVariant variant;
  final ValueChanged<bool> onChanged;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = _AuthPalette.resolve(context);
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: colors.textTertiary,
      fontSize: 14,
      height: 1.45,
    );
    final linkStyle = style?.copyWith(
      color: colors.primary,
      fontWeight: FontWeight.w600,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          checked: agreed,
          button: true,
          label: '同意登录协议',
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: () => onChanged(!agreed),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 2, 8, 8),
              child: Icon(
                agreed ? Icons.check_circle : Icons.radio_button_unchecked,
                color: agreed ? colors.primary : colors.unchecked,
                size: 22,
              ),
            ),
          ),
        ),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('我已阅读并同意 ', style: style),
              if (variant == _AgreementVariant.oneTap) ...[
                _AgreementLink(
                  label: '《中国移动认证服务条款》',
                  style: linkStyle,
                  onTap: () => onOpen('mobile-auth'),
                ),
                Text(' 和 ', style: style),
              ],
              _AgreementLink(
                label: '《用户协议》',
                style: linkStyle,
                onTap: () => onOpen('user'),
              ),
              Text(
                variant == _AgreementVariant.oneTap ? '、' : ' 及 ',
                style: style,
              ),
              _AgreementLink(
                label: '《隐私政策》',
                style: linkStyle,
                onTap: () => onOpen('privacy'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AgreementLink extends StatelessWidget {
  const _AgreementLink({
    required this.label,
    required this.style,
    required this.onTap,
  });

  final String label;
  final TextStyle? style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.xs),
      onTap: onTap,
      child: Text(label, style: style),
    );
  }
}

class _VerificationCodeButton extends StatelessWidget {
  const _VerificationCodeButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = _AuthPalette.resolve(context);
    return TextButton(
      key: const Key('auth-send-code'),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: colors.primary,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      child: const Text('发送验证码'),
    );
  }
}

class _OtherLoginMethods extends StatelessWidget {
  const _OtherLoginMethods({required this.onLogin});

  final ValueChanged<String> onLogin;

  @override
  Widget build(BuildContext context) {
    final colors = _AuthPalette.resolve(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: colors.divider)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '其他登录方式（原型本地模拟）',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(child: Divider(color: colors.divider)),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.md,
          children: [
            _ThirdPartyButton(
              key: const Key('auth-third-party-wechat'),
              icon: Icons.wechat,
              label: '微信登录',
              onTap: () => onLogin('微信用户'),
            ),
            _ThirdPartyButton(
              key: const Key('auth-third-party-qq'),
              icon: Icons.chat_bubble_outline,
              label: 'QQ 登录',
              onTap: () => onLogin('QQ用户'),
            ),
            _ThirdPartyButton(
              key: const Key('auth-third-party-weibo'),
              icon: Icons.alternate_email,
              label: '微博登录',
              onTap: () => onLogin('微博用户'),
            ),
            _ThirdPartyButton(
              key: const Key('auth-third-party-apple'),
              icon: Icons.apple,
              label: '苹果登录',
              onTap: () => onLogin('苹果用户'),
            ),
            _ThirdPartyButton(
              key: const Key('auth-third-party-account'),
              icon: Icons.lock_outline,
              label: '账号登录（原型）',
              onTap: () => onLogin('账号用户'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ThirdPartyButton extends StatelessWidget {
  const _ThirdPartyButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = _AuthPalette.resolve(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Semantics(
        button: true,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: onTap,
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.background,
              border: Border.all(color: colors.divider),
            ),
            child: Icon(icon, size: 21, color: colors.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _AuthPalette {
  const _AuthPalette({
    required this.background,
    required this.primary,
    required this.primarySoft,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.hint,
    required this.unchecked,
    required this.divider,
    required this.inputFill,
  });

  final Color background;
  final Color primary;
  final Color primarySoft;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color hint;
  final Color unchecked;
  final Color divider;
  final Color inputFill;

  static _AuthPalette resolve(BuildContext context) {
    final tokens = context.tokens;
    return _AuthPalette(
      background: tokens.cardBackground,
      primary: tokens.brand.primary,
      primarySoft: tokens.brand.primary.withValues(alpha: 0.10),
      textPrimary: tokens.textPrimary,
      textSecondary: tokens.textSecondary,
      textTertiary: tokens.textTertiary,
      hint: tokens.textTertiary,
      unchecked: tokens.textDisabled,
      divider: tokens.divider,
      inputFill: tokens.cardBackground,
    );
  }
}
