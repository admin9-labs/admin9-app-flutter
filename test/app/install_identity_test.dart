import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _identity = 'dev.admin9.starter';
final _legacyIdentity = ['com', 'admin9', 'app', 'foundation'].join('.');

void main() {
  test('Android uses the Starter installation identity and Kotlin package', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    final activity = File(
      'android/app/src/main/kotlin/dev/admin9/starter/MainActivity.kt',
    );
    final legacyActivity = File(
      'android/app/src/main/kotlin/'
      '${_legacyIdentity.replaceAll('.', '/')}/MainActivity.kt',
    );

    expect(gradle, contains('namespace = "$_identity"'));
    expect(gradle, contains('applicationId = "$_identity"'));
    expect(gradle, isNot(contains(_legacyIdentity)));
    expect(manifest, contains('android:enableOnBackInvokedCallback="true"'));
    expect(activity.existsSync(), isTrue);
    expect(activity.readAsStringSync(), contains('package $_identity'));
    expect(legacyActivity.existsSync(), isFalse);
  });

  test('iOS uses the Starter identity without changing signing ownership', () {
    final project = File('ios/Runner.xcodeproj/project.pbxproj')
        .readAsStringSync();

    expect(_occurrences(project, 'PRODUCT_BUNDLE_IDENTIFIER = $_identity;'), 3);
    expect(
      _occurrences(
        project,
        'PRODUCT_BUNDLE_IDENTIFIER = $_identity.RunnerTests;',
      ),
      3,
    );
    expect(project, isNot(contains(_legacyIdentity)));
    expect(_occurrences(project, 'DEVELOPMENT_TEAM = J25XZRW743;'), 3);
    expect(_occurrences(project, 'CODE_SIGN_STYLE = Automatic;'), 6);
    expect(
      _occurrences(
        project,
        '"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Developer";',
      ),
      3,
    );
  });

  test('current repository text sources contain no legacy ID', () {
    for (final file in _repositoryTextFiles()) {
      expect(
        file.readAsStringSync(),
        isNot(contains(_legacyIdentity)),
        reason:
            '${file.path} still references the legacy installation identity.',
      );
    }
  });
}

int _occurrences(String source, String pattern) =>
    RegExp(RegExp.escape(pattern)).allMatches(source).length;

Iterable<File> _repositoryTextFiles() {
  final result = Process.runSync('git', [
    'ls-files',
    '--cached',
    '--others',
    '--exclude-standard',
  ]);
  expect(result.exitCode, 0, reason: '${result.stderr}');

  return (result.stdout as String)
      .split('\n')
      .where((path) => path.isNotEmpty)
      .map(File.new)
      .where((file) => file.existsSync())
      .where(_isTextFile);
}

bool _isTextFile(File file) {
  final bytes = file.readAsBytesSync();
  if (bytes.contains(0)) {
    return false;
  }
  try {
    utf8.decode(bytes);
    return true;
  } on FormatException {
    return false;
  }
}
