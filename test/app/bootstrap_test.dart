import 'dart:ui';

import 'package:admin9_app_flutter/app/bootstrap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlutterExceptionHandler? previousFlutterHandler;
  late ErrorCallback? previousAsyncHandler;

  setUp(() {
    previousFlutterHandler = FlutterError.onError;
    previousAsyncHandler = PlatformDispatcher.instance.onError;
  });

  tearDown(() {
    FlutterError.onError = previousFlutterHandler;
    PlatformDispatcher.instance.onError = previousAsyncHandler;
  });

  test(
    'reports framework and uncaught async errors through installed hooks',
    () {
      final frameworkErrors = <FlutterErrorDetails>[];
      final asyncErrors = <(Object, StackTrace)>[];
      installAppErrorBoundary(
        onFlutterError: frameworkErrors.add,
        onAsyncError: (error, stackTrace) {
          asyncErrors.add((error, stackTrace));
        },
      );
      final frameworkError = FlutterErrorDetails(
        exception: StateError('framework failure'),
      );
      final asyncError = StateError('async failure');
      final asyncStack = StackTrace.current;

      FlutterError.reportError(frameworkError);
      final handled = PlatformDispatcher.instance.onError!(
        asyncError,
        asyncStack,
      );

      expect(frameworkErrors, [same(frameworkError)]);
      expect(handled, isTrue);
      expect(asyncErrors, hasLength(1));
      expect(asyncErrors.single.$1, same(asyncError));
      expect(asyncErrors.single.$2, same(asyncStack));
    },
  );
}
