import 'package:flutter/foundation.dart';

abstract final class AppGalleryRegistry {
  static const routeName = '/__admin9/gallery';

  static bool get isRegistered => !kReleaseMode;

  static Set<String> get registeredRouteNames =>
      kReleaseMode ? const <String>{} : const <String>{routeName};
}
