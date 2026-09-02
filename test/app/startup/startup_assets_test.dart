import 'dart:io';
import 'dart:ui';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('onboarding uses three distinct licensed 1080x1600 bitmaps', () async {
    final hashes = <String>{};
    for (final filename in ['collaborate.jpg', 'read.jpg', 'act.jpg']) {
      final file = File('assets/images/onboarding/$filename');
      expect(file.existsSync(), isTrue);
      final bytes = await file.readAsBytes();
      hashes.add(sha256.convert(bytes).toString());
      final codec = await instantiateImageCodec(bytes);
      addTearDown(codec.dispose);
      final frame = await codec.getNextFrame();
      final width = frame.image.width;
      final height = frame.image.height;
      frame.image.dispose();
      expect(width, 1080);
      expect(height, 1600);
    }
    expect(hashes, hasLength(3));
    expect(
      File('assets/images/onboarding/README.md').readAsStringSync(),
      contains('Unsplash License'),
    );
    expect(File('assets/images/onboarding_guide.png').existsSync(), isFalse);
  });

  test('native and Flutter initialization use the same brand bitmap', () async {
    final hashes = <String>{};
    for (final path in [
      'android/app/src/main/res/drawable-nodpi/admin9_launch_logo.png',
      'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png',
      'assets/images/brand/admin9_launch_logo.png',
    ]) {
      hashes.add(sha256.convert(await File(path).readAsBytes()).toString());
    }
    expect(hashes, hasLength(1));
  });
}
