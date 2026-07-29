import 'dart:io';

import 'brand_contract_support.dart';

Never _usage() {
  stderr.writeln(
    'usage: dart run tool/design_system/generate_brand_entry.dart '
    '<admin9-foundation.yaml> <output-lib-app-directory>',
  );
  exit(64);
}

void main(List<String> arguments) {
  if (arguments.length != 2) _usage();
  final manifestPath = arguments[0];
  final outputAppDirectory = Directory(arguments[1]);
  final validation = Process.runSync(Platform.resolvedExecutable, [
    'run',
    'tool/design_system/validate_foundation_manifest.dart',
    manifestPath,
  ]);
  if (validation.exitCode != 0) {
    stderr.write(validation.stderr);
    exit(validation.exitCode);
  }
  final data = readBrandContract(manifestPath);
  final brandDirectory = Directory('${outputAppDirectory.path}/brand')
    ..createSync(recursive: true);
  File(
    '${brandDirectory.path}/app_brand_theme.dart',
  ).writeAsStringSync(renderBrandTheme(data));
  File(
    '${outputAppDirectory.path}/app_identity.dart',
  ).writeAsStringSync(renderAppIdentity(data));
  stdout.writeln('Brand entry generated from validated manifest');
}
