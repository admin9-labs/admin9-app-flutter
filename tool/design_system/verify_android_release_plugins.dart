import 'dart:convert';
import 'dart:io';

final class PluginRegistration {
  const PluginRegistration({required this.name, required this.className});

  final String name;
  final String className;

  @override
  bool operator ==(Object other) =>
      other is PluginRegistration &&
      name == other.name &&
      className == other.className;

  @override
  int get hashCode => Object.hash(name, className);

  @override
  String toString() => '$name -> $className';
}

void main(List<String> arguments) {
  if (arguments.contains('--self-test')) {
    _runSelfTest();
    return;
  }

  final dependenciesFile = File('.flutter-plugins-dependencies');
  final generatedRegistryFile = File(
    'android/app/src/main/java/io/flutter/plugins/'
    'GeneratedPluginRegistrant.java',
  );
  final registryFile = _findAndroidSource('ReleasePluginRegistry.kt');
  final activityFile = _findAndroidSource('MainActivity.kt');
  final gradleFile = File('android/app/build.gradle.kts');
  final inputs = [
    dependenciesFile,
    generatedRegistryFile,
    registryFile,
    activityFile,
    gradleFile,
  ];
  if (inputs.any((file) => !file.existsSync())) {
    stderr.writeln('Android release plugin inputs are missing.');
    exitCode = 1;
    return;
  }

  final errors = <String>[
    ..._validateRegistry(
      expected: _expectedRegistrations(dependenciesFile, generatedRegistryFile),
      registry: registryFile.readAsStringSync(),
    ),
    ..._validateWiring(
      activity: activityFile.readAsStringSync(),
      gradle: gradleFile.readAsStringSync(),
    ),
  ];
  if (errors.isNotEmpty) {
    stderr.writeln('Android release plugin registry is invalid:');
    for (final error in errors) {
      stderr.writeln('- $error');
    }
    exitCode = 1;
    return;
  }

  final expected = _expectedRegistrations(
    dependenciesFile,
    generatedRegistryFile,
  ).toList()..sort((left, right) => left.name.compareTo(right.name));
  stdout.writeln('Android release plugins verified: $expected');
}

File _findAndroidSource(String filename) {
  final root = Directory('android/app/src/main');
  final matches = root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.uri.pathSegments.last == filename)
      .toList();
  if (matches.length != 1) {
    throw FormatException(
      'Expected exactly one Android $filename, found ${matches.length}.',
    );
  }
  return matches.single;
}

Set<PluginRegistration> _expectedRegistrations(
  File dependenciesFile,
  File generatedRegistryFile,
) {
  final manifest =
      jsonDecode(dependenciesFile.readAsStringSync()) as Map<String, Object?>;
  final platforms = manifest['plugins'] as Map<String, Object?>;
  final androidPlugins = platforms['android'] as List<Object?>;
  final productionPluginNames = androidPlugins
      .cast<Map<String, Object?>>()
      .where(
        (plugin) =>
            plugin['native_build'] == true && plugin['dev_dependency'] == false,
      )
      .map((plugin) => plugin['name'] as String)
      .toSet();
  final generatedRegistry = generatedRegistryFile.readAsStringSync();
  final generatedPattern = RegExp(
    r'getPlugins\(\)\.add\(new ([A-Za-z0-9_.]+)\(\)\);\s*'
    r'} catch \(Exception e\) \{\s*'
    r'Log\.e\(TAG, "Error registering plugin ([^,]+),',
    multiLine: true,
  );
  final generated = <PluginRegistration>[];
  for (final match in generatedPattern.allMatches(generatedRegistry)) {
    generated.add(
      PluginRegistration(name: match.group(2)!, className: match.group(1)!),
    );
  }
  if (generated.isEmpty && productionPluginNames.isNotEmpty) {
    throw const FormatException(
      'Flutter generated plugin registrant contains no parseable entries.',
    );
  }
  final duplicateGenerated = generated.toSet().length != generated.length;
  if (duplicateGenerated) {
    throw const FormatException(
      'Flutter generated plugin registrations must be unique.',
    );
  }
  return generated
      .where((plugin) => productionPluginNames.contains(plugin.name))
      .toSet();
}

List<String> _validateRegistry({
  required Set<PluginRegistration> expected,
  required String registry,
}) {
  final errors = <String>[];
  final actualAddPattern = RegExp(r'flutterEngine\.plugins\.add\(plugin\)');
  final anyAddPattern = RegExp(r'flutterEngine\.plugins\.add\(');
  if (actualAddPattern.allMatches(registry).length != 1 ||
      anyAddPattern.allMatches(registry).length != 1) {
    errors.add(
      'Registry must contain exactly one helper call to '
      'flutterEngine.plugins.add(plugin) and no direct additions.',
    );
  }
  final imports = RegExp(
    r'^import ([A-Za-z0-9_.]+)$',
    multiLine: true,
  ).allMatches(registry).map((match) => match.group(1)!).toSet();
  final registrationPattern = RegExp(
    r'register\(\s*flutterEngine\s*=\s*flutterEngine,\s*'
    r'pluginName\s*=\s*"([^"]+)",\s*'
    r'plugin\s*=\s*([A-Za-z0-9_]+)\(\),\s*\)',
    multiLine: true,
  );
  final actual = <PluginRegistration>[];
  for (final match in registrationPattern.allMatches(registry)) {
    final shortClassName = match.group(2)!;
    final matchingImports = imports
        .where((value) => value.endsWith('.$shortClassName'))
        .toList();
    if (matchingImports.length != 1) {
      errors.add(
        'Registration ${match.group(1)} must have exactly one import for '
        '$shortClassName; found ${matchingImports.length}.',
      );
      continue;
    }
    actual.add(
      PluginRegistration(
        name: match.group(1)!,
        className: matchingImports.single,
      ),
    );
  }

  final duplicateEntries = actual.toSet().length != actual.length;
  if (duplicateEntries) {
    errors.add('Release plugin registrations must be unique.');
  }
  final actualSet = actual.toSet();
  for (final missing in expected.difference(actualSet)) {
    errors.add('Missing registration: $missing.');
  }
  for (final extra in actualSet.difference(expected)) {
    errors.add('Unexpected registration: $extra.');
  }
  return errors;
}

List<String> _validateWiring({
  required String activity,
  required String gradle,
}) {
  final errors = <String>[];
  if (!activity.contains('BuildConfig.BUILD_TYPE == "release"') ||
      !activity.contains('ReleasePluginRegistry.registerWith(flutterEngine)') ||
      !activity.contains('super.configureFlutterEngine(flutterEngine)')) {
    errors.add(
      'MainActivity does not preserve release/manual and debug/auto wiring.',
    );
  }
  if (!gradle.contains('name.startsWith("compile")') ||
      !gradle.contains('name.endsWith("ReleaseJavaWithJavac")') ||
      !gradle.contains(
        'exclude("io/flutter/plugins/GeneratedPluginRegistrant.java")',
      )) {
    errors.add(
      'All release Java variants must exclude the polluted registrant.',
    );
  }
  return errors;
}

void _runSelfTest() {
  final expected = {
    const PluginRegistration(
      name: 'shared_preferences_android',
      className: 'io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin',
    ),
  };
  const valid = '''
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin
register(
  flutterEngine = flutterEngine,
  pluginName = "shared_preferences_android",
  plugin = SharedPreferencesPlugin(),
)
flutterEngine.plugins.add(plugin)
''';
  final invalid = <String, String>{
    'missing': valid.replaceFirst('register(', 'ignored('),
    'wrong class': valid.replaceAll('SharedPreferencesPlugin', 'WrongPlugin'),
    'wrong name': valid.replaceFirst(
      'shared_preferences_android',
      'other_plugin',
    ),
    'duplicate': '$valid\n$valid',
    'extra':
        '$valid\n${valid.replaceFirst('shared_preferences_android', 'other_plugin')}',
    'missing actual add': valid.replaceFirst(
      'flutterEngine.plugins.add(plugin)',
      '',
    ),
    'extra direct add': '$valid\nflutterEngine.plugins.add(OtherPlugin())',
  };
  if (_validateRegistry(expected: expected, registry: valid).isNotEmpty) {
    stderr.writeln('Validator self-test rejected the valid registry.');
    exitCode = 1;
    return;
  }
  for (final entry in invalid.entries) {
    if (_validateRegistry(expected: expected, registry: entry.value).isEmpty) {
      stderr.writeln('Validator self-test accepted ${entry.key}.');
      exitCode = 1;
      return;
    }
  }
  stdout.writeln('Android release plugin validator self-test passed.');
}
