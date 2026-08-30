import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'admin9_app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  installAppErrorBoundary();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('zh', 'CN')],
      fallbackLocale: const Locale('zh', 'CN'),
      path: 'assets/translations',
      saveLocale: false,
      child: const ProviderScope(child: Admin9App()),
    ),
  );
}

typedef AppAsyncErrorHandler = void Function(Object error, StackTrace stack);

void installAppErrorBoundary({
  FlutterExceptionHandler? onFlutterError,
  AppAsyncErrorHandler? onAsyncError,
}) {
  FlutterError.onError = onFlutterError ?? FlutterError.presentError;
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    (onAsyncError ?? _presentAsyncError)(error, stackTrace);
    return true;
  };
}

void _presentAsyncError(Object error, StackTrace stackTrace) {
  FlutterError.presentError(
    FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: 'Admin9 App Starter',
      context: ErrorDescription('while handling an uncaught async error'),
    ),
  );
}
