import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../foundation/app_contracts.dart';
import '../foundation/app_design_tokens.dart';
import 'app_icon.dart';

final class AppFeedbackPresenterController implements AppFeedbackController {
  _AppFeedbackState? _state;
  AppFeedbackRequest? _pending;
  int _generation = 0;

  @override
  void show(AppFeedbackRequest request) {
    _generation += 1;
    final state = _state;
    if (state == null) {
      _pending = request;
      return;
    }
    state.show(request);
  }

  @override
  void dismiss() {
    _generation += 1;
    _pending = null;
    _state?.dismiss();
  }

  void _attach(_AppFeedbackState state) {
    _state = state;
    final pending = _pending;
    final generation = _generation;
    _pending = null;
    if (pending != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (state.mounted &&
            identical(_state, state) &&
            _generation == generation) {
          state.show(pending);
        }
      });
    }
  }

  void _detach(_AppFeedbackState state) {
    if (identical(_state, state)) _state = null;
  }
}

class AppFeedback extends StatefulWidget {
  const AppFeedback({
    super.key,
    required this.controller,
    required this.navigatorKey,
    required this.child,
  });

  final AppFeedbackController controller;
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<AppFeedback> createState() => _AppFeedbackState();
}

class _AppFeedbackState extends State<AppFeedback> {
  final GlobalKey<ScaffoldMessengerState> _messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  AppFeedbackRequest? _request;
  Timer? _timer;
  bool _actionDispatched = false;
  bool? _accessibleNavigation;
  OverlayEntry? _cupertinoEntry;

  AppFeedbackPresenterController? get _presenter =>
      widget.controller is AppFeedbackPresenterController
      ? widget.controller as AppFeedbackPresenterController
      : null;

  @override
  void initState() {
    super.initState();
    _presenter?._attach(this);
  }

  @override
  void didUpdateWidget(AppFeedback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      if (oldWidget.controller is AppFeedbackPresenterController) {
        (oldWidget.controller as AppFeedbackPresenterController)._detach(this);
      }
      _presenter?._attach(this);
    }
    if (!identical(oldWidget.navigatorKey, widget.navigatorKey) &&
        _cupertinoEntry != null) {
      _removeCupertinoFeedback();
      _showCupertinoFeedback();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final previous = _accessibleNavigation;
    _accessibleNavigation = MediaQuery.accessibleNavigationOf(context);
    _scheduleDismissal();
    final request = _request;
    if (previous != null &&
        previous != _accessibleNavigation &&
        request != null &&
        Theme.of(context).platform != TargetPlatform.iOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !identical(_request, request)) return;
        _clearMaterialFeedback();
        _showMaterialFeedback(request, announce: false);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _removeCupertinoFeedback();
    _presenter?._detach(this);
    super.dispose();
  }

  void show(AppFeedbackRequest request) {
    _timer?.cancel();
    _clearMaterialFeedback();
    setState(() {
      _request = request;
      _actionDispatched = false;
    });
    _scheduleDismissal();
    if (Theme.of(context).platform != TargetPlatform.iOS) {
      _showMaterialFeedback(request, announce: true);
    } else {
      _showCupertinoFeedback();
    }
  }

  void dismiss() {
    _timer?.cancel();
    _clearMaterialFeedback();
    _removeCupertinoFeedback();
    if (_request == null || !mounted) return;
    setState(() => _request = null);
  }

  void _scheduleDismissal() {
    _timer?.cancel();
    final request = _request;
    if (!mounted || request == null) return;
    if (request.onAction != null || (_accessibleNavigation ?? false)) {
      return;
    }
    final duration = switch (request.tone) {
      AppTone.info || AppTone.success => const Duration(seconds: 3),
      AppTone.warning || AppTone.error => const Duration(seconds: 5),
    };
    _timer = Timer(duration, dismiss);
  }

  void _activateAction() {
    final action = _request?.onAction;
    if (action == null || _actionDispatched) return;
    _actionDispatched = true;
    action();
    dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return AppFeedbackHost(
      controller: widget.controller,
      child: ScaffoldMessenger(key: _messengerKey, child: widget.child),
    );
  }

  Widget _liveRegion(
    String message,
    Widget child, {
    required bool announce,
    OrdinalSortKey? sortKey,
  }) => Semantics(
    container: true,
    liveRegion: announce,
    label: message,
    sortKey: sortKey,
    child: ExcludeSemantics(child: child),
  );

  void _showCupertinoFeedback() {
    final tokens = AppDesignScope.of(context);
    final topInset = MediaQuery.paddingOf(context).top + 44;
    void insert(OverlayState overlay) {
      if (!mounted || _request == null || _cupertinoEntry != null) return;
      final entry = OverlayEntry(
        builder: (context) {
          final request = _request;
          if (request == null) return const SizedBox.shrink();
          return Positioned(
            left: 0,
            top: topInset,
            right: 0,
            child: _cupertinoOverlay(context, request, tokens),
          );
        },
      );
      _cupertinoEntry = entry;
      overlay.insert(entry);
    }

    final overlay = widget.navigatorKey.currentState?.overlay;
    if (overlay != null) {
      insert(overlay);
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final deferredOverlay = widget.navigatorKey.currentState?.overlay;
      if (deferredOverlay != null) insert(deferredOverlay);
    });
  }

  void _removeCupertinoFeedback() {
    _cupertinoEntry?.remove();
    _cupertinoEntry = null;
  }

  void _showMaterialFeedback(
    AppFeedbackRequest request, {
    required bool announce,
  }) {
    final messenger = _messengerKey.currentState;
    if (messenger == null) return;
    final persistent =
        request.onAction != null || (_accessibleNavigation ?? false);
    if (!persistent) {
      final duration = switch (request.tone) {
        AppTone.info || AppTone.success => const Duration(seconds: 3),
        AppTone.warning || AppTone.error => const Duration(seconds: 5),
      };
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: duration,
          content: _liveRegion(
            request.message,
            Text(request.message),
            announce: announce,
          ),
        ),
      );
      return;
    }
    final actions = <Widget>[
      if (request.actionLabel != null)
        Semantics(
          container: true,
          sortKey: const OrdinalSortKey(2),
          button: true,
          label: request.actionLabel,
          child: ExcludeSemantics(
            child: TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: _activateAction,
              child: Text(request.actionLabel!),
            ),
          ),
        ),
      Semantics(
        container: true,
        sortKey: const OrdinalSortKey(3),
        button: true,
        label: '关闭',
        child: ExcludeSemantics(
          child: IconButton(
            tooltip: '关闭',
            constraints: const BoxConstraints.tightFor(width: 48, height: 48),
            onPressed: dismiss,
            icon: Icon(
              resolveAppIcon(AppIconRole.close, TargetPlatform.android),
            ),
          ),
        ),
      ),
    ];
    messenger.showMaterialBanner(
      MaterialBanner(
        content: _liveRegion(
          request.message,
          Text(request.message),
          announce: announce,
          sortKey: const OrdinalSortKey(1),
        ),
        leading: Icon(
          resolveAppIcon(_toneIcon(request.tone), TargetPlatform.android),
        ),
        actions: actions,
      ),
    );
  }

  void _clearMaterialFeedback() {
    final messenger = _messengerKey.currentState;
    messenger?.hideCurrentSnackBar();
    messenger?.hideCurrentMaterialBanner();
  }

  Widget _cupertinoOverlay(
    BuildContext context,
    AppFeedbackRequest request,
    AppDesignTokens tokens,
  ) {
    return SafeArea(
      top: false,
      bottom: false,
      minimum: EdgeInsets.all(tokens.space8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.surfaceContainer,
          border: Border.all(color: tokens.outline),
          borderRadius: BorderRadius.circular(tokens.controlRadius),
        ),
        child: Padding(
          padding: EdgeInsets.all(tokens.space12),
          child: Row(
            children: [
              Icon(
                resolveAppIcon(_toneIcon(request.tone), TargetPlatform.iOS),
                color: _toneColor(tokens, request.tone),
              ),
              SizedBox(width: tokens.space8),
              Expanded(
                child: _liveRegion(
                  request.message,
                  Text(request.message),
                  announce: true,
                  sortKey: const OrdinalSortKey(1),
                ),
              ),
              if (request.actionLabel != null)
                Semantics(
                  container: true,
                  sortKey: const OrdinalSortKey(2),
                  button: true,
                  label: request.actionLabel,
                  child: ExcludeSemantics(
                    child: CupertinoButton(
                      minimumSize: const Size(44, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      onPressed: _activateAction,
                      child: Text(request.actionLabel!),
                    ),
                  ),
                ),
              Semantics(
                container: true,
                sortKey: const OrdinalSortKey(3),
                label: '关闭',
                button: true,
                child: ExcludeSemantics(
                  child: CupertinoButton(
                    minimumSize: const Size(44, 44),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: dismiss,
                    child: Icon(
                      resolveAppIcon(AppIconRole.close, TargetPlatform.iOS),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppIconRole _toneIcon(AppTone tone) => switch (tone) {
    AppTone.info => AppIconRole.info,
    AppTone.success => AppIconRole.success,
    AppTone.warning => AppIconRole.warning,
    AppTone.error => AppIconRole.error,
  };

  Color _toneColor(AppDesignTokens tokens, AppTone tone) => switch (tone) {
    AppTone.info => tokens.info,
    AppTone.success => tokens.success,
    AppTone.warning => tokens.warning,
    AppTone.error => tokens.danger,
  };
}
