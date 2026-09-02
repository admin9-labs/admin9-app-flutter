import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android enables predictive back callbacks', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();

    expect(manifest, contains('android:enableOnBackInvokedCallback="true"'));
  });

  test('Android 12 keeps the native launch screen static in both themes', () {
    for (final path in [
      'android/app/src/main/res/values-v31/styles.xml',
      'android/app/src/main/res/values-night-v31/styles.xml',
    ]) {
      final styles = File(path).readAsStringSync();
      expect(styles, contains('android:windowSplashScreenAnimatedIcon'));
      expect(
        styles,
        contains('android:windowSplashScreenAnimationDuration">0'),
      );
      expect(styles, isNot(contains('startup_ad')));
    }
  });

  test('iOS native launch background has a dark appearance asset', () {
    final storyboard = File('ios/Runner/Base.lproj/LaunchScreen.storyboard')
        .readAsStringSync();
    final colors = File(
      'ios/Runner/Assets.xcassets/LaunchBackground.colorset/Contents.json',
    ).readAsStringSync();

    expect(storyboard, contains('name="LaunchBackground"'));
    expect(colors, contains('"appearance" : "luminosity"'));
    expect(colors, contains('"value" : "dark"'));
  });

  test('Android declares the real background audio service and controls', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    final activity = File(
      'android/app/src/main/kotlin/dev/admin9/starter/MainActivity.kt',
    ).readAsStringSync();

    expect(manifest, contains('android.permission.INTERNET'));
    expect(manifest, contains('android.permission.FOREGROUND_SERVICE'));
    expect(
      manifest,
      contains('android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK'),
    );
    expect(manifest, contains('com.ryanheise.audioservice.AudioService'));
    expect(manifest, contains('MediaButtonReceiver'));
    expect(activity, contains('AudioServiceActivity'));
  });

  test('iOS declares background audio without unrelated background modes', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();

    expect(plist, contains('<key>UIBackgroundModes</key>'));
    expect(plist, contains('<string>audio</string>'));
    expect(plist, isNot(contains('<string>location</string>')));
    expect(plist, isNot(contains('<string>fetch</string>')));
  });
}
