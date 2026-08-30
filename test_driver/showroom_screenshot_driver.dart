import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final output = Directory(
    Platform.environment['SHOWROOM_SCREENSHOT_DIR'] ??
        'build/ui_evidence/showroom',
  )..createSync(recursive: true);

  await integrationDriver(
    onScreenshot: (name, bytes, [arguments]) async {
      if (bytes.length < 1024 ||
          bytes[0] != 0x89 ||
          bytes[1] != 0x50 ||
          bytes[2] != 0x4e ||
          bytes[3] != 0x47) {
        return false;
      }
      File('${output.path}/$name.png').writeAsBytesSync(bytes, flush: true);
      return true;
    },
    writeResponseOnFailure: true,
  );
}
