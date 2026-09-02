import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({
    super.key,
    required this.onAccept,
    required this.onContinueLimited,
    required this.onOpenUserAgreement,
    required this.onOpenPrivacyPolicy,
    this.persistenceWarning = false,
  });

  final Future<void> Function() onAccept;
  final VoidCallback onContinueLimited;
  final VoidCallback onOpenUserAgreement;
  final VoidCallback onOpenPrivacyPolicy;
  final bool persistenceWarning;

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    return ColoredBox(
      key: const ValueKey('privacy-page'),
      color: theme.colors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 20,
                      children: [
                        Icon(
                          FLucideIcons.shieldCheck,
                          size: 40,
                          color: theme.colors.primary,
                        ),
                        Text(
                          context.tr('privacy.title'),
                          style: theme.typography.display.lg,
                        ),
                        Text(
                          context.tr('privacy.summary'),
                          style: theme.typography.body.lg.copyWith(height: 1.6),
                        ),
                        _PrivacyPoint(
                          icon: FLucideIcons.eye,
                          text: context.tr('privacy.point_public'),
                        ),
                        _PrivacyPoint(
                          icon: FLucideIcons.userRoundCheck,
                          text: context.tr('privacy.point_optional'),
                        ),
                        _PrivacyPoint(
                          icon: FLucideIcons.database,
                          text: context.tr('privacy.point_storage'),
                        ),
                        if (persistenceWarning)
                          Text(
                            context.tr('privacy.storage_warning'),
                            key: const ValueKey('privacy-storage-warning'),
                            style: theme.typography.body.sm.copyWith(
                              color: theme.colors.destructive,
                            ),
                          ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FButton(
                              key: const ValueKey('privacy-user-agreement'),
                              variant: .ghost,
                              mainAxisSize: MainAxisSize.min,
                              onPress: onOpenUserAgreement,
                              child: Text(context.tr('privacy.user_agreement')),
                            ),
                            FButton(
                              key: const ValueKey('privacy-policy'),
                              variant: .ghost,
                              mainAxisSize: MainAxisSize.min,
                              onPress: onOpenPrivacyPolicy,
                              child: Text(context.tr('privacy.policy')),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.background,
                border: Border(top: BorderSide(color: theme.colors.border)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 10,
                      children: [
                        FButton(
                          key: const ValueKey('privacy-accept'),
                          onPress: onAccept,
                          child: Text(context.tr('privacy.accept')),
                        ),
                        FButton(
                          key: const ValueKey('privacy-limited'),
                          variant: .outline,
                          onPress: onContinueLimited,
                          child: Text(context.tr('privacy.continue_limited')),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyPoint extends StatelessWidget {
  const _PrivacyPoint({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 12,
    children: [
      Icon(icon, size: 22, color: FTheme.of(context).colors.primary),
      Expanded(
        child: Text(
          text,
          style: FTheme.of(context).typography.body.md.copyWith(height: 1.55),
        ),
      ),
    ],
  );
}
