import 'dart:convert';

import 'dtcg_token.dart';

/// Parses W3C DTCG token files into a [DtcgGroup] forest.
class DtcgParser {
  DtcgParser._();

  /// Parses one DTCG JSON [source]. [fileName] is only used in error messages.
  static DtcgGroup parse(String source, {String fileName = 'tokens.json'}) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (e) {
      throw DtcgFormatException('$fileName: invalid JSON — ${e.message}');
    }
    if (decoded is! Map<String, dynamic>) {
      throw DtcgFormatException('$fileName: top level must be a JSON object');
    }
    return parseMap(decoded, name: fileName, path: '');
  }

  /// Parses an already-decoded map. Useful for tests and embedded token sets.
  static DtcgGroup parseMap(
    Map<String, dynamic> map, {
    required String name,
    required String path,
    DtcgType? inheritedType,
  }) {
    DtcgType? type = inheritedType;
    String? description;
    if (map case {'\$type': final Object? rawType}) {
      if (rawType is! String) {
        throw DtcgFormatException('$path: \$type must be a string');
      }
      type = DtcgType.fromSpec(rawType) ??
          (throw DtcgFormatException(
              '$path: unknown \$type "$rawType"'));
    }
    if (map case {'\$description': final Object? d}) {
      if (d is! String) {
        throw DtcgFormatException('$path: \$description must be a string');
      }
      description = d;
    }

    final children = <DtcgNode>[];
    map.forEach((key, value) {
      if (key.startsWith('\$')) return;
      final childPath = path.isEmpty ? key : '$path.$key';
      if (value is Map<String, dynamic>) {
        if (value.containsKey('\$value')) {
          children.add(_parseToken(key, childPath, value, type));
        } else {
          children.add(
            parseMap(value, name: key, path: childPath, inheritedType: type),
          );
        }
        return;
      }
      throw DtcgFormatException(
          '$childPath: expected a token or group object, got ${value.runtimeType}');
    });

    return DtcgGroup(
      name,
      path,
      children: children,
      description: description,
      type: type,
    );
  }

  static DtcgToken _parseToken(
    String name,
    String path,
    Map<String, dynamic> map,
    DtcgType? inheritedType,
  ) {
    final rawType = map['\$type'];
    DtcgType? type = inheritedType;
    if (rawType != null) {
      if (rawType is! String) {
        throw DtcgFormatException('$path: \$type must be a string');
      }
      type = DtcgType.fromSpec(rawType) ??
          (throw DtcgFormatException('$path: unknown \$type "$rawType"'));
    }
    final extensions = map['\$extensions'];
    return DtcgToken(
      name,
      path,
      rawValue: map['\$value'],
      declaredType: type,
      description: map['\$description'] as String?,
      extensions:
          extensions is Map<String, dynamic> ? Map.of(extensions) : const {},
    );
  }
}

class DtcgFormatException implements Exception {
  DtcgFormatException(this.message);
  final String message;

  @override
  String toString() => 'DtcgFormatException: $message';
}
