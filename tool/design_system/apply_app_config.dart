import 'dart:io';

import 'app_config_support.dart';

Never _usage() {
  stderr.writeln(
    'usage: dart run tool/design_system/apply_app_config.dart '
    '<app-config.yaml> <repository-root>',
  );
  exit(64);
}

void main(List<String> arguments) {
  if (arguments.length != 2) _usage();
  final configPath = arguments[0];
  final repositoryRoot = Directory(arguments[1]);
  final validation = Process.runSync(Platform.resolvedExecutable, [
    'run',
    'tool/design_system/validate_app_config.dart',
    configPath,
  ]);
  if (validation.exitCode != 0) {
    stderr.write(validation.stderr);
    exit(validation.exitCode);
  }
  final errors = synchronizeAppConfig(
    readAppConfig(configPath),
    repositoryRoot.path,
    write: true,
  );
  if (errors.isNotEmpty) {
    errors.forEach(stderr.writeln);
    exit(1);
  }
  stdout.writeln('App identity, brand, and native resources generated');
}
