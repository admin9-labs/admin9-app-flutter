import 'package:flutter/material.dart';

import '../foundation/app_contracts.dart';
import '../foundation/app_design_tokens.dart';
import 'app_icon.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.body,
    required this.navigationMode,
    this.actions = const <AppPageAction>[],
    this.parentLabel,
    this.scrollable = true,
  }) : assert(
         (navigationMode == AppPageNavigationMode.root &&
                 parentLabel == null) ||
             (navigationMode == AppPageNavigationMode.child &&
                 parentLabel != null &&
                 parentLabel != ''),
       );

  final String title;
  final Widget body;
  final AppPageNavigationMode navigationMode;
  final List<AppPageAction> actions;
  final String? parentLabel;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: navigationMode == AppPageNavigationMode.child
            ? IconButton(
                tooltip: '返回$parentLabel',
                constraints: const BoxConstraints.tightFor(
                  width: 48,
                  height: 48,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
                icon: Icon(resolveAppIcon(AppIconRole.back, platform)),
              )
            : null,
        title: Text(title),
        actions: actions
            .map(
              (action) => IconButton(
                key: action.key,
                tooltip: action.label,
                constraints: const BoxConstraints.tightFor(
                  width: 48,
                  height: 48,
                ),
                onPressed: action.enabled ? action.onPressed : null,
                icon: Icon(resolveAppIcon(action.icon, platform)),
              ),
            )
            .toList(growable: false),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final tokens = AppDesignScope.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final horizontalInset = width >= 600
        ? tokens.space24
        : width >= 390
        ? 20.0
        : tokens.space16;
    Widget content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 640 + horizontalInset * 2),
        child: scrollable
            ? SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalInset,
                  vertical: tokens.space16,
                ),
                child: body,
              )
            : body,
      ),
    );
    content = SafeArea(
      key: const Key('app-page-body-safe-area'),
      top: false,
      bottom: navigationMode == AppPageNavigationMode.child,
      child: content,
    );
    return content;
  }
}
