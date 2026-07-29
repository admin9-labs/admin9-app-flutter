import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/admin9_app.dart';
import 'core/errors/app_error_boundary.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    AppErrorBoundary.install();
    final preferences = await SharedPreferences.getInstance();
    runApp(Admin9App(preferences: preferences));
  }, AppErrorBoundary.report);
}
