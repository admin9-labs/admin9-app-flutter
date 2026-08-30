import 'dart:convert';
import 'dart:io';

final _linkPattern = RegExp(r'!?\[[^\]]*\]\(([^)]+)\)');
final _headingPattern = RegExp(r'^ {0,3}#{1,6}\s+(.+?)\s*#*\s*$');

Future<void> main() async {
  final repository = Directory.current.absolute;
  final files = await _markdownFiles();
  final failures = <String>[];

  for (final path in files) {
    final source = File(_join(repository.path, path));
    if (!source.existsSync()) {
      continue;
    }
    final contents = source.readAsStringSync();
    for (final match in _linkPattern.allMatches(contents)) {
      final target = _linkTarget(match.group(1)!);
      if (_isExternal(target)) {
        continue;
      }

      final hash = target.indexOf('#');
      final rawPath = hash == -1 ? target : target.substring(0, hash);
      final fragment = hash == -1 ? '' : target.substring(hash + 1);
      final targetPath = Uri.decodeComponent(rawPath);
      final destination = targetPath.isEmpty
          ? source
          : File(
              targetPath.startsWith('/')
                  ? _join(repository.path, targetPath.substring(1))
                  : _join(source.parent.path, targetPath),
            );

      if (!destination.existsSync() &&
          !Directory(destination.path).existsSync()) {
        failures.add(
          '${source.path}:${_lineOf(contents, match.start)}: '
          'missing local target $target',
        );
        continue;
      }

      if (fragment.isNotEmpty &&
          destination.existsSync() &&
          destination.path.toLowerCase().endsWith('.md')) {
        final anchor = Uri.decodeComponent(fragment).toLowerCase();
        final anchors = _markdownAnchors(destination.readAsStringSync());
        if (!anchors.contains(anchor)) {
          failures.add(
            '${source.path}:${_lineOf(contents, match.start)}: '
            'missing anchor #$anchor in ${destination.path}',
          );
        }
      }
    }
  }

  if (failures.isNotEmpty) {
    stderr.writeln(failures.join('\n'));
    exitCode = 1;
    return;
  }

  stdout.writeln('Checked ${files.length} Markdown files.');
}

Future<List<String>> _markdownFiles() async {
  final result = await Process.run('git', [
    'ls-files',
    '--cached',
    '--others',
    '--exclude-standard',
    '*.md',
  ]);
  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    exitCode = result.exitCode;
    return const [];
  }

  return const LineSplitter()
      .convert(result.stdout as String)
      .where((path) => path.isNotEmpty)
      .toList()
    ..sort();
}

String _linkTarget(String value) {
  final trimmed = value.trim();
  if (trimmed.startsWith('<')) {
    final end = trimmed.indexOf('>');
    return end == -1 ? trimmed : trimmed.substring(1, end);
  }
  return trimmed.split(RegExp(r'\s+')).first;
}

bool _isExternal(String target) {
  if (target.isEmpty) {
    return true;
  }
  final lower = target.toLowerCase();
  return lower.startsWith('http://') ||
      lower.startsWith('https://') ||
      lower.startsWith('mailto:') ||
      lower.startsWith('tel:') ||
      lower.startsWith('data:') ||
      lower.startsWith('//');
}

Set<String> _markdownAnchors(String contents) {
  final anchors = <String>{};
  final counts = <String, int>{};
  for (final line in const LineSplitter().convert(contents)) {
    final match = _headingPattern.firstMatch(line);
    if (match == null) {
      continue;
    }
    final base = _slug(match.group(1)!);
    final count = counts.update(base, (value) => value + 1, ifAbsent: () => 0);
    anchors.add(count == 0 ? base : '$base-$count');
  }
  return anchors;
}

String _slug(String heading) => heading
    .replaceAll(RegExp(r'[`*_~]'), '')
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9\u4e00-\u9fff\s-]'), '')
    .trim()
    .replaceAll(RegExp(r'\s'), '-');

int _lineOf(String contents, int offset) =>
    '\n'.allMatches(contents.substring(0, offset)).length + 1;

String _join(String parent, String child) {
  final separator = Platform.pathSeparator;
  return parent.endsWith(separator)
      ? '$parent$child'
      : '$parent$separator$child';
}
