import 'dart:io';

import 'brand_contract_support.dart';

Never _usage() {
  stderr.writeln(
    'usage: dart run tool/design_system/generate_brand_entry.dart '
    '<admin9-foundation.yaml> <derived-repository-root>',
  );
  exit(64);
}

void main(List<String> arguments) {
  if (arguments.length != 2) _usage();
  final manifestPath = arguments[0];
  final repositoryRoot = Directory(arguments[1]);
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
  final errors = synchronizeDerivedBrand(
    data,
    repositoryRoot.path,
    write: true,
  );
  if (errors.isNotEmpty) {
    errors.forEach(stderr.writeln);
    exit(1);
  }
  stdout.writeln('Derived brand and native identity generated from manifest');
}
