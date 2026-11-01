import 'dtcg_token.dart';

/// Resolves `{group.token}` references across a token forest and validates
/// values against their declared [DtcgType].
class DtcgResolver {
  /// [roots] is the forest of one theme mode: mode-independent files plus the
  /// files for that mode.
  ///
  /// With [lastSetWins] (multi-set exports), a token path defined by several
  /// roots resolves to the *last* definition instead of failing — enabled
  /// sets override `source` sets, mirroring design-tool semantics.
  DtcgResolver(List<DtcgGroup> roots, {bool lastSetWins = false})
      : _lastSetWins = lastSetWins {
    for (final root in roots) {
      root.visit((token) {
        if (_tokens.containsKey(token.path) && !_lastSetWins) {
          throw DtcgResolveException(
            'Duplicate token path "${token.path}" (defined in more than one file)',
          );
        }
        _tokens[token.path] = token;
      });
    }
  }

  final bool _lastSetWins;

  final Map<String, DtcgToken> _tokens = {};
  final Map<String, DtcgValue> _resolved = {};
  final Set<String> _visiting = {};

  /// All token paths known to this resolver.
  Set<String> get tokenPaths => Set.unmodifiable(_tokens.keys);

  /// Resolves every token; returns values keyed by token path.
  Map<String, DtcgValue> resolveAll() {
    for (final path in _tokens.keys.toList()..sort()) {
      resolve(path);
    }
    return Map.unmodifiable(_resolved);
  }

  DtcgValue resolve(String path) {
    final cached = _resolved[path];
    if (cached != null) return cached;

    final token = _tokens[path];
    if (token == null) {
      throw DtcgResolveException(
        'Unknown token "{$path}" — no token with this path exists',
      );
    }
    if (!_visiting.add(path)) {
      throw DtcgResolveException(
        'Circular reference detected while resolving "{$path}": '
        '${_visiting.join(' → ')} → $path',
      );
    }
    try {
      final value = _resolveToken(token);
      _resolved[path] = value;
      return value;
    } finally {
      _visiting.remove(path);
    }
  }

  DtcgValue _resolveToken(DtcgToken token) {
    final raw = token.rawValue;
    if (raw is String) {
      final ref = referenceTarget(raw);
      if (ref != null) {
        final target = resolve(ref);
        final declared = token.declaredType;
        if (declared != null && declared != DtcgType.other) {
          final actual = typeOf(target);
          if (!_accepts(declared, actual)) {
            throw DtcgResolveException(
              'Type mismatch at "${token.path}": declared $declared but '
              'reference resolves to $actual',
            );
          }
        }
        return target;
      }
    }
    return parseValue(raw, token.declaredType, token.path);
  }

  /// Real-world exports blur type lines: Figma exports font families as
  /// `text` variables, and numeric scalars alias each other freely. A target
  /// is accepted when its type is in the same family as the declared one.
  static bool _accepts(DtcgType declared, DtcgType actual) {
    if (declared == actual) return true;
    const numeric = {
      DtcgType.number,
      DtcgType.dimension,
      DtcgType.fontWeight,
      DtcgType.duration,
    };
    if (numeric.contains(declared) && numeric.contains(actual)) return true;
    const stringish = {DtcgType.text, DtcgType.fontFamily};
    return stringish.contains(declared) && stringish.contains(actual);
  }

  /// Returns the path inside a `{reference}` string, or null if [raw] is not
  /// a reference.
  static String? referenceTarget(String raw) {
    final match = _referencePattern.firstMatch(raw);
    if (match == null) return null;
    final inner = match.group(1)!;
    if (_referencePattern.firstMatch(inner) != null) {
      throw DtcgResolveException('Nested references are not supported: $raw');
    }
    return inner;
  }

  static final RegExp _referencePattern = RegExp(r'^\{([A-Za-z0-9_.-]+)\}$');

  /// Parses a literal value into a typed [DtcgValue].
  DtcgValue parseValue(Object? raw, DtcgType? type, String path) {
    if (type == null) {
      throw DtcgResolveException(
        'Token "$path" has no \$type (directly or inherited) — add one',
      );
    }
    switch (type) {
      case DtcgType.color:
        return DtcgColorValue(_parseColor(raw, path));
      case DtcgType.dimension:
        return DtcgDimensionValue(_parseDimension(raw, path));
      case DtcgType.number:
        return DtcgNumberValue(_parseDouble(raw, path));
      case DtcgType.fontWeight:
        return DtcgFontWeightValue(_parseFontWeight(raw, path));
      case DtcgType.duration:
        return DtcgDurationValue(_parseDuration(raw, path));
      case DtcgType.cubicBezier:
        return DtcgCubicBezierValue(_parseCubicBezier(raw, path));
      case DtcgType.fontFamily:
        return DtcgFontFamilyValue(_parseFontFamily(raw, path));
      case DtcgType.typography:
        return DtcgTypographyValue(_parseTypography(raw, path));
      case DtcgType.boxShadow:
        return _parseShadow(raw, path);
      case DtcgType.text:
        if (raw is! String) {
          throw DtcgResolveException(
            'text token "$path" must be a string, got "$raw"',
          );
        }
        return DtcgStringValue(raw);
      case DtcgType.other:
        return DtcgRawValue(raw);
    }
  }

  /// Numbers may arrive as `num` or as numeric strings
  /// (`"0"`, `"2"` — how design tools export composite members).
  static double? _numLike(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw.trim());
    return null;
  }

  DtcgValue _resolveCompositeMember(
    Object? raw,
    DtcgType expectedType,
    String path,
  ) {
    if (raw is String) {
      final ref = referenceTarget(raw);
      if (ref != null) {
        final resolved = resolve(ref);
        final actual = typeOf(resolved);
        if (!_accepts(expectedType, actual)) {
          throw DtcgResolveException(
            'Composite member at "$path" expects $expectedType but '
            'reference "{$ref}" resolves to $actual',
          );
        }
        return resolved;
      }
    }
    return parseValue(raw, expectedType, path);
  }

  DtcgShadowValue _parseShadow(Object? raw, String path) {
    if (raw is! Map<String, dynamic>) {
      throw DtcgResolveException(
        'boxShadow token "$path" must be an object, got "$raw"',
      );
    }
    DtcgValue? member(String key, DtcgType type) => raw.containsKey(key)
        ? _resolveCompositeMember(raw[key], type, '$path.$key')
        : null;
    final color = member('color', DtcgType.color);
    final x = member('x', DtcgType.number);
    final y = member('y', DtcgType.number);
    final blur = member('blur', DtcgType.number);
    final spread = member('spread', DtcgType.number);
    if (color is! DtcgColorValue ||
        x is! DtcgNumberValue ||
        y is! DtcgNumberValue) {
      throw DtcgResolveException(
        'boxShadow token "$path" requires color, x and y members '
        '(has: ${raw.keys.join(', ')})',
      );
    }
    return DtcgShadowValue(
      color: color.argb,
      offsetX: x.value,
      offsetY: y.value,
      blur: blur is DtcgNumberValue ? blur.value : 0,
      spread: spread is DtcgNumberValue ? spread.value : 0,
      inset: raw['type'] == 'inset',
    );
  }

  static int _parseColor(Object? raw, String path) {
    if (raw is! String) {
      throw DtcgResolveException(
        'Color token "$path" must be a hex string, got ${raw.runtimeType}',
      );
    }
    final match = _hexColorPattern.firstMatch(raw);
    if (match == null) {
      throw DtcgResolveException(
        'Color token "$path": "$raw" is not supported — '
        'use #RGB, #RRGGBB or #RRGGBBAA',
      );
    }
    var hex = match.group(1)!;
    if (hex.length == 3) {
      hex = hex.split('').map((c) => '$c$c').join();
    }
    if (hex.length == 6) hex = 'FF$hex';
    return int.parse(hex, radix: 16);
  }

  static final RegExp _hexColorPattern =
      RegExp(r'^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');

  static double _parseDimension(Object? raw, String path) {
    final like = _numLike(raw);
    if (like != null) return like;
    if (raw is String && raw.endsWith('px')) {
      final n = double.tryParse(raw.substring(0, raw.length - 2));
      if (n != null) return n;
    }
    throw DtcgResolveException(
      'Dimension token "$path" must be a number or "<n>px", got "$raw"',
    );
  }

  static double _parseDouble(Object? raw, String path) {
    final like = _numLike(raw);
    if (like != null) return like;
    // Percent values (Tokens Studio line heights, opacities) → ratio.
    if (raw is String && raw.trim().endsWith('%')) {
      final pct = double.tryParse(raw.trim().substring(0, raw.trim().length - 1));
      if (pct != null) return pct / 100;
    }
    throw DtcgResolveException(
      'Number token "$path" must be a number, got "$raw"',
    );
  }

  static const Map<String, int> _namedWeights = {
    'thin': 100,
    'extralight': 200,
    'ultralight': 200,
    'light': 300,
    'regular': 400,
    'normal': 400,
    'medium': 500,
    'semibold': 600,
    'demibold': 600,
    'bold': 700,
    'extrabold': 800,
    'ultrabold': 800,
    'black': 900,
    'heavy': 900,
  };

  static int _parseFontWeight(Object? raw, String path) {
    if (raw is int && raw >= 100 && raw <= 1000) return raw;
    if (raw is String) {
      final trimmed = raw.trim();
      final n = int.tryParse(trimmed);
      if (n != null && n >= 100 && n <= 1000) return n;
      if (trimmed.toLowerCase().startsWith('w')) {
        final w = int.tryParse(trimmed.substring(1));
        if (w != null && w >= 100 && w <= 1000) return w;
      }
      final named = _namedWeights[trimmed.toLowerCase().replaceAll(' ', '')];
      if (named != null) return named;
    }
    throw DtcgResolveException(
      'fontWeight token "$path" must be 100–1000, "w<n>" or a named weight, '
      'got "$raw"',
    );
  }

  static int _parseDuration(Object? raw, String path) {
    if (raw is int) return raw;
    if (raw is String && raw.endsWith('ms')) {
      final n = int.tryParse(raw.substring(0, raw.length - 2));
      if (n != null) return n;
    }
    throw DtcgResolveException(
      'duration token "$path" must be milliseconds or "<n>ms", got "$raw"',
    );
  }

  static List<double> _parseCubicBezier(Object? raw, String path) {
    if (raw is List && raw.length == 4 && raw.every((e) => e is num)) {
      return raw.map((e) => (e as num).toDouble()).toList();
    }
    throw DtcgResolveException(
      'cubicBezier token "$path" must be an array of 4 numbers, got "$raw"',
    );
  }

  static List<String> _parseFontFamily(Object? raw, String path) {
    if (raw is String) return [raw];
    if (raw is List && raw.every((e) => e is String)) {
      return raw.cast<String>();
    }
    throw DtcgResolveException(
      'fontFamily token "$path" must be a string or string array, got "$raw"',
    );
  }

  Map<String, DtcgValue> _parseTypography(Object? raw, String path) {
    if (raw is! Map<String, dynamic>) {
      throw DtcgResolveException(
        'typography token "$path" must be an object, got "$raw"',
      );
    }
    final members = <String, DtcgValue>{};
    raw.forEach((key, value) {
      // Tokens Studio typography members use both DTCG and legacy names.
      final memberType = switch (key) {
        'fontSize' || 'fontSizes' => DtcgType.dimension,
        'fontWeight' || 'fontWeights' => DtcgType.fontWeight,
        'lineHeight' ||
        'lineHeights' ||
        'letterSpacing' ||
        'paragraphSpacing' ||
        'paragraphIndent' =>
          DtcgType.number,
        'fontFamily' || 'fontFamilies' => DtcgType.fontFamily,
        'textCase' || 'textDecoration' => DtcgType.text,
        _ => throw DtcgResolveException(
            'typography token "$path" has unsupported member "$key"',
          ),
      };
      members[key] = _resolveCompositeMember(value, memberType, '$path.$key');
    });
    return Map.unmodifiable(members);
  }
}

class DtcgResolveException implements Exception {
  DtcgResolveException(this.message);
  final String message;

  @override
  String toString() => 'DtcgResolveException: $message';
}
