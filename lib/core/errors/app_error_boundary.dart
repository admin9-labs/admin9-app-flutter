import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppErrorBoundary {
  const AppErrorBoundary._();

  static void install() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      report(details.exception, details.stack ?? StackTrace.current);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      report(error, stack);
      return true;
    };
    ErrorWidget.builder = (details) => AppErrorFallback(
      message: kDebugMode ? details.exceptionAsString() : null,
    );
  }

  static void report(Object error, StackTrace stack) {
    debugPrint('Uncaught application error: $error');
    debugPrintStack(stackTrace: stack);
  }
}

class AppErrorFallback extends StatelessWidget {
  const AppErrorFallback({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40),
              const SizedBox(height: 12),
              const Text('页面暂时无法显示'),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(message!, textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
