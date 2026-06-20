import 'package:flutter/material.dart';

abstract final class AppNavigator {
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.of(
      context,
    ).push<T>(MaterialPageRoute(builder: (_) => page));
  }
}
