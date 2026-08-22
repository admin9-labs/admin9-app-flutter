import 'package:flutter/material.dart';

import '../foundation/app_contracts.dart';
import 'app_icon.dart';

final class AppInteractionPresenterController
    implements AppInteractionController {
  AppInteractionPresenterController({required this.navigatorKey});

  final GlobalKey<NavigatorState> navigatorKey;

  BuildContext get _context {
    final context = navigatorKey.currentContext;
    if (context == null) {
      throw FlutterError('App interaction Navigator is not attached.');
    }
    return context;
  }

  @override
  Future<void> showInformation({
    required String title,
    required String message,
  }) async {
    final context = _context;
    final previousFocus = FocusManager.instance.primaryFocus;
    final dialog = AppDialog(
      variant: AppDialogVariant.information,
      title: title,
      body: Text(message),
      confirmLabel: '知道了',
    );
    await showDialog<void>(context: context, builder: (_) => dialog);
    _restoreFocus(previousFocus);
  }

  @override
  Future<bool> showConfirmation({
    required String title,
    required String message,
    required String confirmLabel,
  }) => _showDecision(
    variant: AppDialogVariant.confirmation,
    title: title,
    message: message,
    confirmLabel: confirmLabel,
  );

  @override
  Future<bool> showDestructive({
    required String title,
    required String message,
    required String confirmLabel,
  }) => _showDecision(
    variant: AppDialogVariant.destructive,
    title: title,
    message: message,
    confirmLabel: confirmLabel,
  );

  Future<bool> _showDecision({
    required AppDialogVariant variant,
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final context = _context;
    final previousFocus = FocusManager.instance.primaryFocus;
    final barrierDismissible = variant != AppDialogVariant.destructive;
    final dialog = AppDialog(
      variant: variant,
      title: title,
      body: Text(message),
      cancelLabel: '取消',
      confirmLabel: confirmLabel,
    );
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => dialog,
    );
    _restoreFocus(previousFocus);
    return result ?? false;
  }

  @override
  Future<T?> showActionMenu<T extends Object>({
    String? title,
    required List<AppActionMenuItem<T>> items,
    String cancelLabel = '取消',
  }) async {
    assert(items.length >= 2 && items.length <= 6);
    assert(cancelLabel.isNotEmpty);
    final context = _context;
    final previousFocus = FocusManager.instance.primaryFocus;
    final result = await showModalBottomSheet<T>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => AppActionMenu<T>(
        title: title,
        items: items,
        cancelLabel: cancelLabel,
        onSelected: (value) => Navigator.of(context).pop(value),
      ),
    );
    _restoreFocus(previousFocus);
    return result;
  }

  void _restoreFocus(FocusNode? previousFocus) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (previousFocus?.canRequestFocus ?? false) {
        previousFocus!.requestFocus();
      }
    });
  }
}

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.variant,
    required this.title,
    required this.body,
    required this.confirmLabel,
    this.cancelLabel,
  }) : assert(confirmLabel != ''),
       assert(
         (variant == AppDialogVariant.information && cancelLabel == null) ||
             (variant != AppDialogVariant.information &&
                 cancelLabel != null &&
                 cancelLabel != ''),
       );

  final AppDialogVariant variant;
  final String title;
  final Widget body;
  final String confirmLabel;
  final String? cancelLabel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: body,
      actions: _actions(context),
    );
  }

  List<Widget> _actions(BuildContext context) => [
    if (cancelLabel != null)
      OutlinedButton(
        style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
        onPressed: () => Navigator.of(context).pop(false),
        child: Text(cancelLabel!),
      ),
    FilledButton(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        backgroundColor: variant == AppDialogVariant.destructive
            ? Theme.of(context).colorScheme.error
            : null,
        foregroundColor: variant == AppDialogVariant.destructive
            ? Theme.of(context).colorScheme.onError
            : null,
      ),
      onPressed: () => Navigator.of(context).pop(true),
      child: Text(confirmLabel),
    ),
  ];
}

class AppActionMenu<T extends Object> extends StatefulWidget {
  const AppActionMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.title,
    this.cancelLabel = '取消',
  }) : assert(items.length >= 2 && items.length <= 6),
       assert(cancelLabel != '');

  final String? title;
  final List<AppActionMenuItem<T>> items;
  final AppValueChanged<T> onSelected;
  final String cancelLabel;

  @override
  State<AppActionMenu<T>> createState() => _AppActionMenuState<T>();
}

class _AppActionMenuState<T extends Object> extends State<AppActionMenu<T>> {
  bool _selectionDispatched = false;

  void _select(T value) {
    if (_selectionDispatched) return;
    _selectionDispatched = true;
    widget.onSelected(value);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListView(
        shrinkWrap: true,
        children: [
          if (widget.title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Text(
                widget.title!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          for (final item in widget.items)
            ListTile(
              enabled: item.enabled,
              leading: item.icon == null
                  ? null
                  : Icon(
                      resolveAppIcon(item.icon!, Theme.of(context).platform),
                    ),
              title: Text(item.label),
              textColor: item.destructive
                  ? Theme.of(context).colorScheme.error
                  : null,
              iconColor: item.destructive
                  ? Theme.of(context).colorScheme.error
                  : null,
              onTap: item.enabled ? () => _select(item.value) : null,
            ),
          ListTile(
            title: Text(widget.cancelLabel),
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
