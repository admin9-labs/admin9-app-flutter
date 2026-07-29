import 'package:flutter/cupertino.dart';
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
    return platform == TargetPlatform.iOS
        ? _buildCupertino(context)
        : _buildMaterial(context);
  }

  Widget _buildMaterial(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading:
            navigationMode == AppPageNavigationMode.child,
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
                icon: Icon(resolveAppIcon(action.icon, TargetPlatform.android)),
              ),
            )
            .toList(growable: false),
      ),
      body: _body(context),
    );
  }

  Widget _buildCupertino(BuildContext context) {
    final trailing = actions.isEmpty
        ? null
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: actions
                .map(
                  (action) => CupertinoButton(
                    key: action.key,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(44, 44),
                    onPressed: action.enabled ? action.onPressed : null,
                    child: Semantics(
                      label: action.label,
                      button: true,
                      child: ExcludeSemantics(
                        child: Icon(
                          resolveAppIcon(action.icon, TargetPlatform.iOS),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          );
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading:
            navigationMode == AppPageNavigationMode.child,
        transitionBetweenRoutes: navigationMode == AppPageNavigationMode.child,
        previousPageTitle: parentLabel,
        middle: Text(title),
        trailing: trailing,
      ),
      child: _body(context),
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
