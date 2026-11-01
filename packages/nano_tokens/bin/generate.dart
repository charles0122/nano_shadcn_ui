/// Codegen CLI for the nano token pipeline.
///
/// Usage (from anywhere in the workspace):
///
/// ```
/// dart run nano_tokens:generate
/// ```
///
/// Reads `packages/nano_tokens/tokens/*.json`, resolves references per mode,
/// validates cross-mode consistency, then writes:
/// * `lib/src/generated/tokens.g.dart` — typed Dart constants
/// * `dist/tokens.<mode>.json` — resolved, machine-readable token sets
import 'dart:convert';
import 'dart:io';

import 'package:nano_tokens/src/dtcg/dtcg_parser.dart';
import 'package:nano_tokens/src/dtcg/dtcg_resolver.dart';
import 'package:nano_tokens/src/dtcg/dtcg_token.dart';

void main(List<String> args) {
  final sourceIdx = args.indexOf('--source');
  if (sourceIdx != -1) {
    if (sourceIdx + 1 >= args.length) {
      stderr.writeln(
        '--source requires a directory containing '
        '\$themes.json (a multi-set design-tool export)',
      );
      exitCode = 64;
      return;
    }
    _runExportMode(
      Directory(args[sourceIdx + 1]),
      writeDart: !args.contains('--no-dart'),
    );
    return;
  }
  _runSimpleMode();
}

void _runSimpleMode() {
  final tokensDir = _findTokensDir();
  final packageDir = tokensDir.parent;
  final generatedFile = File.fromUri(
    packageDir.uri.resolve('lib/src/generated/tokens.g.dart'),
  );
  final distDir = Directory.fromUri(packageDir.uri.resolve('dist'));

  final files =
      tokensDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  if (files.isEmpty) {
    throw StateError('No token files found in ${tokensDir.path}');
  }

  // Split files into mode-independent bases and per-mode sets.
  // Naming convention: `<name>.<mode>.json` where mode is e.g. light/dark.
  final bases = <_TokenFile>[];
  final modes = <String, Map<String, _TokenFile>>{};
  for (final file in files) {
    final name = _basename(file.path).replaceAll(RegExp(r'\.json$'), '');
    final match = RegExp(r'^(.+)\.(light|dark|high-contrast)$')
        .firstMatch(name);
    if (match == null) {
      bases.add(_TokenFile(base: name, mode: null, file: file));
    } else {
      modes.putIfAbsent(match.group(2)!, () => {})[match.group(1)!] =
          _TokenFile(base: match.group(1)!, mode: match.group(2)!, file: file);
    }
  }

  final modeNames = modes.keys.toList()..sort();
  final resolvers = <String, DtcgResolver>{};
  final resolvedPerMode = <String, Map<String, DtcgValue>>{};

  if (modeNames.isEmpty) {
    resolvers['default'] = DtcgResolver(bases.map((f) => f.parse()).toList());
  } else {
    final baseGroups = bases.map((f) => f.parse()).toList();
    for (final mode in modeNames) {
      final modeGroups = modes[mode]!.values.map((f) => f.parse()).toList();
      resolvers[mode] = DtcgResolver([...baseGroups, ...modeGroups]);
    }
    // Cross-mode drift check: every mode must define the same token paths.
    final expected = resolvers[modeNames.first]!.tokenPaths;
    for (final mode in modeNames.skip(1)) {
      final actual = resolvers[mode]!.tokenPaths;
      final missing = expected.difference(actual);
      final extra = actual.difference(expected);
      if (missing.isNotEmpty || extra.isNotEmpty) {
        throw StateError(
          'Mode drift between "$modeNames.first" and "$mode": '
          'missing in this mode: $missing — extra: $extra',
        );
      }
    }
  }
  for (final entry in resolvers.entries) {
    resolvedPerMode[entry.key] = entry.value.resolveAll();
  }

  final buffer = StringBuffer()
    ..writeln('// GENERATED FILE — do not edit.')
    ..writeln('// Regenerate with: dart run nano_tokens:generate')
    ..writeln('// coverage:ignore-file')
    ..writeln();
  for (final entry in bases) {
    _writeClass(buffer, entry, resolvedPerMode, modeNames);
  }
  for (final mode in modeNames) {
    for (final entry in modes[mode]!.values) {
      _writeClass(buffer, entry, resolvedPerMode, modeNames);
    }
  }

  generatedFile.parent.createSync(recursive: true);
  generatedFile.writeAsStringSync(buffer.toString());

  distDir.createSync(recursive: true);
  for (final entry in resolvedPerMode.entries) {
    final out = File.fromUri(distDir.uri.resolve('tokens.${entry.key}.json'));
    out.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(_toPlainJson(entry.value)),
    );
  }

  stdout.writeln(
    'nano_tokens: generated ${generatedFile.path} '
    '(${bases.length} base file(s), ${modeNames.length} mode(s): '
    '${modeNames.isEmpty ? 'default' : modeNames.join(', ')}) '
    'and ${resolvedPerMode.length} dist file(s).',
  );
}

class _TokenFile {
  _TokenFile({required this.base, required this.mode, required this.file});

  final String base;
  final String? mode;
  final File file;

  DtcgGroup parse() =>
      DtcgParser.parse(file.readAsStringSync(), fileName: _basename(file.path));
}

String _basename(String path) => path.split(Platform.pathSeparator).last;

/// One Dart class per token file: `semantic.color.light.json` →
/// `NanoSemanticColorLight`, `primitives.color.json` → `NanoPrimitivesColor`,
/// `spacing.json` → `NanoSpacing`.
void _writeClass(
  StringBuffer buffer,
  _TokenFile entry,
  Map<String, Map<String, DtcgValue>> resolvedPerMode,
  List<String> modeNames,
) {
  // Base files are mode-independent — any mode's resolver yields the same
  // values for them, so default to the first mode.
  final resolved = modeNames.isEmpty
      ? resolvedPerMode['default']!
      : resolvedPerMode[entry.mode ?? modeNames.first]!;
  final className =
      'Nano${_pascal(entry.base)}'
      '${entry.mode == null ? '' : _pascal(entry.mode!)}';

  final members = <String, DtcgToken>{};
  entry.parse().visit((token) => members[_memberName(token.path)] = token);

  buffer
    ..writeln('/// Tokens from `${_basename(entry.file.path)}`.')
    ..writeln('abstract final class $className {');
  for (final member in members.entries) {
    final value = resolved[member.value.path]!;
    buffer
      ..writeln('  /// `${member.value.path}`')
      ..writeln(
        '  static const ${_dartTypeOf(value)} ${member.key} = ${_literal(value)};',
      );
  }
  buffer
    ..writeln('}')
    ..writeln();
}

String _dartTypeOf(DtcgValue value) => switch (value) {
  DtcgColorValue() => 'int',
  DtcgDimensionValue() => 'double',
  DtcgNumberValue() => 'double',
  DtcgFontWeightValue() => 'int',
  DtcgDurationValue() => 'int',
  DtcgCubicBezierValue() => 'List<double>',
  DtcgFontFamilyValue() => 'String',
  DtcgTypographyValue() => 'Map<String, Object?>',
  DtcgShadowValue() => 'Map<String, Object?>',
  DtcgStringValue() => 'String',
  DtcgRawValue() => 'Object?',
};

String _literal(DtcgValue value) => switch (value) {
  DtcgColorValue(:final argb) => '0x${argb.toRadixString(16).padLeft(8, '0')}',
  DtcgDimensionValue(:final value) => value.toString(),
  DtcgNumberValue(:final value) => value.toString(),
  DtcgFontWeightValue(:final value) => value.toString(),
  DtcgDurationValue(:final ms) => ms.toString(),
  DtcgCubicBezierValue(:final points) => 'const <double>[${points.join(', ')}]',
  DtcgFontFamilyValue(:final families) =>
    families.length == 1
        ? "'${families.single}'"
        : "const <String>[${families.map((f) => "'$f'").join(', ')}]",
  DtcgTypographyValue(:final members) =>
    'const <String, Object?>{${members.entries.map((e) => "'${e.key}': ${_literal(e.value)}").join(', ')}}',
  DtcgShadowValue(
    :final color,
    :final offsetX,
    :final offsetY,
    :final blur,
    :final spread,
    :final inset,
  ) =>
    "const <String, Object?>{'color': "
        "'0x${color.toRadixString(16).padLeft(8, '0')}', 'offsetX': $offsetX, "
        "'offsetY': $offsetY, 'blur': $blur, 'spread': $spread, "
        "'inset': $inset}",
  DtcgStringValue(:final value) => "'${_escapeSingleQuoted(value)}'",
  DtcgRawValue(:final value) => jsonEncode(value),
};

String _escapeSingleQuoted(String raw) =>
    raw.replaceAll(r'\', r'\\').replaceAll("'", r"\'");

Map<String, Object?> _toPlainJson(Map<String, DtcgValue> resolved) {
  final out = <String, Object?>{};
  for (final entry in resolved.entries) {
    out[entry.key] = switch (entry.value) {
      DtcgColorValue(:final argb) => {
        'type': 'color',
        'argb': argb,
        'hex': '#${argb.toRadixString(16).padLeft(8, '0').toUpperCase()}',
      },
      DtcgDimensionValue(:final value) => {'type': 'dimension', 'value': value},
      DtcgNumberValue(:final value) => {'type': 'number', 'value': value},
      DtcgFontWeightValue(:final value) => {
        'type': 'fontWeight',
        'value': value,
      },
      DtcgDurationValue(:final ms) => {'type': 'duration', 'ms': ms},
      DtcgCubicBezierValue(:final points) => {
        'type': 'cubicBezier',
        'value': points,
      },
      DtcgFontFamilyValue(:final families) => {
        'type': 'fontFamily',
        'value': families,
      },
      DtcgStringValue(:final value) => {'type': 'text', 'value': value},
      DtcgShadowValue(
        :final color,
        :final offsetX,
        :final offsetY,
        :final blur,
        :final spread,
        :final inset,
      ) =>
        {
          'type': 'boxShadow',
          'color': '#${color.toRadixString(16).padLeft(8, '0').toUpperCase()}',
          'offsetX': offsetX,
          'offsetY': offsetY,
          'blur': blur,
          'spread': spread,
          'inset': inset,
        },
      DtcgTypographyValue(:final members) => {
        'type': 'typography',
        'members': {
          for (final m in members.entries)
            m.key: _toPlainJson({m.key: m.value}).values.first,
        },
      },
      DtcgRawValue(:final value) => {'type': 'other', 'value': value},
    };
  }
  return out;
}

String _memberName(String path) {
  // Token paths may contain '-', '_', '.', and spaces (Figma variable names)
  // — split on every non-alphanumeric run: `font-weight.regular` →
  // `fontWeightRegular`, `Font specimen.Body` → `FontSpecimenBody`.
  final words = path.split(RegExp(r'[^A-Za-z0-9]+')).where((w) => w.isNotEmpty);
  // Keep the first word's casing — token paths like `accentPressed` are
  // already camelCase.
  final buffer = StringBuffer(words.first);
  for (final word in words.skip(1)) {
    buffer.write('${word[0].toUpperCase()}${word.substring(1)}');
  }
  var name = buffer.toString();
  if (RegExp(r'^[0-9]').hasMatch(name)) name = 'token$name';
  return name;
}

String _pascal(String raw) => raw
    .split(RegExp(r'[-_.]'))
    .where((s) => s.isNotEmpty)
    .map((s) => '${s[0].toUpperCase()}${s.substring(1)}')
    .join();

/// Locates the `tokens/` directory by walking up from the current directory,
/// then by probing common workspace locations.
Directory _findTokensDir() {
  final candidates = <Directory>[];
  var dir = Directory.current;
  for (var i = 0; i < 8; i++) {
    candidates.add(Directory.fromUri(dir.uri.resolve('tokens')));
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  final cwd = Directory.current.path;
  try {
    final result = Process.runSync('sh', [
      '-c',
      'ls -d packages/*/tokens */packages/*/tokens 2>/dev/null',
    ], workingDirectory: cwd);
    for (final line in (result.stdout as String).split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty) candidates.add(Directory(trimmed));
    }
  } on ProcessException {
    // Non-POSIX fallback — the walk-up search above may still find it.
  }
  for (final candidate in candidates) {
    if (candidate.existsSync() &&
        candidate.listSync().whereType<File>().any(
          (f) => f.path.endsWith('.json'),
        )) {
      return candidate;
    }
  }
  throw StateError(
    'Could not locate a tokens/ directory with JSON files. '
    'Run this command from the repository root or packages/nano_tokens.',
  );
}

// ---------------------------------------------------------------------------
// Multi-set export mode (--source)
// ---------------------------------------------------------------------------

/// Resolves a multi-set design-tool export (Tokens Studio / Figma variables):
/// `$themes.json` defines themes per dimension group; each theme's forest is
/// its `source` sets plus its `enabled` sets (the latter win path conflicts).
///
/// Outputs (into the nano_tokens package):
/// * `lib/src/generated/export.g.dart` — typed class per participating set
///   (skipped with `--no-dart`: combo-heavy exports consume the JSON dist
///   only, and thousands of typed constants would bloat analysis)
/// * `dist/tokens.<group>.<theme>.json` — resolved tokens per theme
/// * `dist/themes.manifest.json` — machine-readable theme index
void _runExportMode(Directory sourceDir, {required bool writeDart}) {
  if (!sourceDir.existsSync()) {
    throw StateError('Source directory not found: ${sourceDir.path}');
  }
  final themesFile = File.fromUri(sourceDir.uri.resolve(r'$themes.json'));
  if (!themesFile.existsSync()) {
    throw StateError(
      'No \$themes.json in ${sourceDir.path} — not a multi-set export. '
      'Use plain mode (no --source) for simple token directories.',
    );
  }
  final themes = (jsonDecode(themesFile.readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();

  // Discover sets: every non-$ json file, named by its relative path.
  final sets = <String, DtcgGroup>{};
  void walk(Directory dir, String prefix) {
    for (final entity
        in dir.listSync()..sort((a, b) => a.path.compareTo(b.path))) {
      final name = _basename(entity.path);
      if (name.startsWith(r'$')) continue;
      if (entity is Directory) {
        walk(entity, prefix.isEmpty ? name : '$prefix/$name');
      } else if (entity is File && name.endsWith('.json')) {
        final setName = prefix.isEmpty
            ? name.substring(0, name.length - 5)
            : '$prefix/${name.substring(0, name.length - 5)}';
        sets[setName] = DtcgParser.parse(
          entity.readAsStringSync(),
          fileName: setName,
        );
      }
    }
  }

  walk(sourceDir, '');

  // Partition themes into dimension groups (SemanticColor, Brand, …).
  final groups = <String, List<Map<String, dynamic>>>{};
  for (final theme in themes) {
    groups
        .putIfAbsent(theme['group'] as String? ?? 'default', () => [])
        .add(theme);
  }
  final groupNames = groups.keys.toList()..sort();

  // Sets selected by no theme form the fallback layer: they satisfy
  // cross-dimension references (platform fonts, localizations, legacy
  // primitives) but always lose conflicts against theme-selected sets.
  final selectedSets = <String>{};
  for (final theme in themes) {
    selectedSets.addAll(
      (theme['selectedTokenSets'] as Map<String, dynamic>? ?? {}).keys,
    );
  }
  final unboundSets = sets.keys.where((s) => !selectedSets.contains(s)).toList()
    ..sort();

  // Cartesian product over dimension groups = full theme combinations.
  // A full theme is one selection per group; references resolve across the
  // union, which is how `{brand.…}` refs inside SemanticColor/Light work.
  var combinations = <Map<String, Map<String, dynamic>>>[
    <String, Map<String, dynamic>>{},
  ];
  for (final group in groupNames) {
    combinations = [
      for (final combo in combinations)
        for (final theme in groups[group]!) {...combo, group: theme},
    ];
  }

  String comboName(Map<String, Map<String, dynamic>> selection) =>
      groupNames.map((g) => selection[g]!['name'] as String).join('+');

  /// Forest for one combination: fallback layer first, then each dimension's
  /// source sets and enabled set — later roots win conflicts (lastSetWins).
  List<String> forestSetsFor(Map<String, Map<String, dynamic>> selection) {
    final names = <String>[...unboundSets];
    for (final group in groupNames) {
      final theme = selection[group]!;
      final selected =
          (theme['selectedTokenSets'] as Map<String, dynamic>? ?? {});
      final sources = selected.entries
          .where((e) => e.value == 'source')
          .map((e) => e.key)
          .toList();
      final enabled = selected.entries
          .where((e) => e.value == 'enabled')
          .map((e) => e.key)
          .toList();
      // A source set that is a path-prefix of another selected source set is
      // an older revision of the same layer ('Global' vs 'Global/Value').
      final kept = sources
          .where((s) => !sources.any((o) => o != s && o.startsWith('$s/')))
          .toList();
      names.addAll([...kept, ...enabled]);
    }
    return names;
  }

  stdout.writeln(
    'nano_tokens: ${sets.length} set(s), ${groups.length} '
    'dimension group(s), ${combinations.length} theme combination(s)',
  );

  final okCombos = <String, Map<String, DtcgValue>>{};
  final failedCombos = <String, String>{};
  for (final selection in combinations) {
    final name = comboName(selection);
    final forestSetNames = forestSetsFor(selection);
    final missing = forestSetNames.where((s) => !sets.containsKey(s)).toList();
    if (missing.isNotEmpty) {
      failedCombos[name] = 'missing sets: $missing';
      continue;
    }
    try {
      final resolved = DtcgResolver(
        forestSetNames.map((s) => sets[s]!).toList(),
        lastSetWins: true,
      ).resolveAll();
      okCombos[name] = resolved;
      stdout.writeln('  ✓ $name — ${resolved.length} tokens');
    } on Exception catch (e) {
      failedCombos[name] = e.toString();
      stdout.writeln('  ✗ $name — ${e.toString().split('\n').first}');
    }
  }

  final packageDir = _findNanoTokensPackage();
  final distDir = Directory.fromUri(packageDir.uri.resolve('dist'));
  distDir.createSync(recursive: true);
  String sanitize(String raw) => raw.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '-');
  for (final combo in okCombos.entries) {
    File.fromUri(
      distDir.uri.resolve('tokens.combo.${sanitize(combo.key)}.json'),
    ).writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(_toPlainJson(combo.value)),
    );
  }
  File.fromUri(distDir.uri.resolve('themes.manifest.json')).writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({
      'source': sourceDir.path,
      'sets': sets.keys.toList(),
      'unboundSets': unboundSets,
      'groups': {
        for (final group in groupNames)
          group: [for (final t in groups[group]!) t['name']],
      },
      'combinations': [
        for (final combo in okCombos.keys)
          {'name': combo, 'tokens': okCombos[combo]!.length},
      ],
      'failed': [
        for (final entry in failedCombos.entries)
          {'name': entry.key, 'error': entry.value.split('\n').first},
      ],
    }),
  );

  if (writeDart) {
    final buffer = StringBuffer();
    for (final combo in okCombos.entries) {
      final safeName = combo.key.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
      final className = 'NanoTheme$safeName';
      final forestSetNames = forestSetsFor(
        combinations.firstWhere((c) => comboName(c) == combo.key),
      );
      final members = <String, DtcgToken>{};
      final seenMembers = <String>{};
      var collisions = 0;
      for (final setName in forestSetNames) {
        sets[setName]!.visit((token) {
          final member = _memberName(token.path);
          if (!seenMembers.add(member)) {
            collisions++;
            return; // keep the first member name; later sets override by path
          }
          members[member] = token;
        });
      }
      buffer
        ..writeln('// GENERATED FILE — do not edit.')
        ..writeln(
          '// Source: ${sourceDir.path} — multi-set export, '
          '${combinations.length} theme combinations',
        )
        ..writeln(
          '// Regenerate with: dart run nano_tokens:generate --source <dir>',
        )
        ..writeln('// coverage:ignore-file')
        ..writeln();
      buffer
        ..writeln(
          '/// Full theme "${combo.key}" — ${members.length} tokens'
          '${collisions > 0 ? ' ($collisions member-name collisions skipped)' : ''}.',
        )
        ..writeln('abstract final class $className {');
      for (final member in members.entries) {
        final value = combo.value[member.value.path]!;
        buffer
          ..writeln('  /// `${member.value.path}`')
          ..writeln(
            '  static const ${_dartTypeOf(value)} ${member.key} = ${_literal(value)};',
          );
      }
      buffer
        ..writeln('}')
        ..writeln();
    }
    final exportFile = File.fromUri(
      packageDir.uri.resolve('lib/src/generated/export.g.dart'),
    );
    exportFile.parent.createSync(recursive: true);
    exportFile.writeAsStringSync(buffer.toString());
  }

  if (failedCombos.isNotEmpty) {
    stderr.writeln(
      'nano_tokens: ${failedCombos.length}/${combinations.length} theme '
      'combination(s) FAILED — see themes.manifest.json',
    );
    exitCode = 1;
  } else {
    stdout.writeln(
      'nano_tokens: export OK — ${okCombos.length} combination(s), '
      '${writeDart ? 'typed classes → lib/src/generated/export.g.dart' : 'JSON dist only (--no-dart)'}',
    );
  }
}

Directory _findNanoTokensPackage() {
  var dir = Directory.current;
  for (var i = 0; i < 8; i++) {
    final pubspec = File.fromUri(dir.uri.resolve('pubspec.yaml'));
    if (pubspec.existsSync() &&
        pubspec.readAsStringSync().startsWith('name: nano_tokens')) {
      return dir;
    }
    final nested = Directory.fromUri(dir.uri.resolve('packages/nano_tokens'));
    if (nested.existsSync()) return nested;
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  throw StateError(
    'Could not locate the nano_tokens package from '
    '${Directory.current.path}',
  );
}
