/// Data model for the W3C DTCG (Design Tokens Community Group) format subset
/// used by the nano pipeline.
library;

/// Token types defined by the DTCG format spec, extended with the names that
/// Figma / Tokens Studio actually emit (`text`, `boxShadow`, and the legacy
/// camelCase scalars), normalized to canonical types.
enum DtcgType {
  color('color'),
  dimension('dimension'),
  fontFamily('fontFamily'),
  fontWeight('fontWeight'),
  duration('duration'),
  cubicBezier('cubicBezier'),
  number('number'),
  typography('typography'),
  boxShadow('boxShadow'),
  text('text'),
  other('other');

  const DtcgType(this.specName);

  /// Name as it appears in a token file's `$type` property.
  final String specName;

  static final Map<String, DtcgType> _specNames = {
    // DTCG spec names.
    for (final t in DtcgType.values) t.specName: t,
    // Tokens Studio legacy names → canonical types.
    'fontFamilies': fontFamily,
    'fontWeights': fontWeight,
    'fontSizes': dimension,
    'lineHeights': number,
    'lineHeight': number,
    'letterSpacing': number,
    'paragraphSpacing': number,
    'textCase': text,
    'textDecoration': text,
  };

  static DtcgType? fromSpec(String name) => _specNames[name];
}

/// A node in a token file: either a [DtcgGroup] or a [DtcgToken].
sealed class DtcgNode {
  const DtcgNode(this.name, this.path);

  /// Node name as written in the file.
  final String name;

  /// Dot-joined path from the file root, e.g. `color.bg.canvas`.
  final String path;
}

class DtcgGroup extends DtcgNode {
  DtcgGroup(
    super.name,
    super.path, {
    required this.children,
    this.description,
    this.type,
  });

  final List<DtcgNode> children;
  final String? description;

  /// Group-level `$type`, inherited by child tokens that don't declare one.
  final DtcgType? type;

  void visit(void Function(DtcgToken token) onToken) {
    for (final child in children) {
      switch (child) {
        case final DtcgToken t:
          onToken(t);
        case final DtcgGroup g:
          g.visit(onToken);
      }
    }
  }
}

class DtcgToken extends DtcgNode {
  DtcgToken(
    super.name,
    super.path, {
    required this.rawValue,
    this.declaredType,
    this.description,
    this.extensions = const {},
  });

  /// The `$value` as written — a literal, a `{reference}` string, a list or a
  /// composite map (for `typography`).
  final Object? rawValue;
  final DtcgType? declaredType;
  final String? description;
  final Map<String, Object?> extensions;
}

/// A fully resolved token value.
sealed class DtcgValue {
  const DtcgValue();
}

class DtcgColorValue extends DtcgValue {
  const DtcgColorValue(this.argb);
  final int argb;
}

class DtcgDimensionValue extends DtcgValue {
  const DtcgDimensionValue(this.value);
  final double value;
}

class DtcgNumberValue extends DtcgValue {
  const DtcgNumberValue(this.value);
  final double value;
}

class DtcgFontWeightValue extends DtcgValue {
  const DtcgFontWeightValue(this.value);
  final int value;
}

/// Milliseconds.
class DtcgDurationValue extends DtcgValue {
  const DtcgDurationValue(this.ms);
  final int ms;
}

class DtcgCubicBezierValue extends DtcgValue {
  const DtcgCubicBezierValue(this.points);
  final List<double> points;
}

class DtcgFontFamilyValue extends DtcgValue {
  const DtcgFontFamilyValue(this.families);
  final List<String> families;
}

class DtcgTypographyValue extends DtcgValue {
  const DtcgTypographyValue(this.members);
  final Map<String, DtcgValue> members;
}

/// Generic string value — Figma exports strings as `$type: "text"`.
class DtcgStringValue extends DtcgValue {
  const DtcgStringValue(this.value);
  final String value;
}

/// Resolved shadow composite (`boxShadow`).
class DtcgShadowValue extends DtcgValue {
  const DtcgShadowValue({
    required this.color,
    required this.offsetX,
    required this.offsetY,
    required this.blur,
    required this.spread,
    required this.inset,
  });

  final int color;
  final double offsetX;
  final double offsetY;
  final double blur;
  final double spread;
  final bool inset;
}

/// Passthrough for `$type: other`.
class DtcgRawValue extends DtcgValue {
  const DtcgRawValue(this.value);
  final Object? value;
}

/// Returns the [DtcgType] a resolved value belongs to.
DtcgType typeOf(DtcgValue value) => switch (value) {
      DtcgColorValue() => DtcgType.color,
      DtcgDimensionValue() => DtcgType.dimension,
      DtcgNumberValue() => DtcgType.number,
      DtcgFontWeightValue() => DtcgType.fontWeight,
      DtcgDurationValue() => DtcgType.duration,
      DtcgCubicBezierValue() => DtcgType.cubicBezier,
      DtcgFontFamilyValue() => DtcgType.fontFamily,
      DtcgTypographyValue() => DtcgType.typography,
      DtcgShadowValue() => DtcgType.boxShadow,
      DtcgStringValue() => DtcgType.text,
      DtcgRawValue() => DtcgType.other,
    };
