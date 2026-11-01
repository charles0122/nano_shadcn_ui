import 'dart:ui' show Brightness;

import 'package:flutter/animation.dart' show Cubic;
import 'package:flutter/painting.dart';

import 'nano_theme_data.dart';

/// Builds a [NanoThemeData] from a resolved token set — the
/// `dist/tokens.combo.*.json` emitted by `nano_tokens:generate --source`.
///
/// This is the runtime half of the token pipeline: the same JSON that agents
/// consume drives the widget theme, so theme switching needs no rebuild.
/// Paths follow the token source exactly (`color.action.primary.background`).
NanoThemeData nanoThemeFromTokens(
  Map<String, Object?> tokens, {
  required Brightness brightness,
}) {
  Color color(String path) => Color(_argb(tokens, path));

  NanoStatusColors status(String name) => NanoStatusColors(
    foreground: color('color.status.$name.foreground'),
    background: color('color.status.$name.background'),
    border: color('color.status.$name.border'),
  );

  final colors = NanoColors(
    canvas: color('color.canvas'),
    surface: color('color.surface'),
    surfaceSubtle: color('color.background.surface.subtle'),
    textPrimary: color('color.foreground.text.primary'),
    textSecondary: color('color.foreground.text.secondary'),
    textDisabled: color('color.foreground.text.disabled'),
    iconPrimary: color('color.foreground.icon.primary'),
    iconSecondary: color('color.foreground.icon.secondary'),
    accent: color('color.accent'),
    onAccent: color('color.onAccent'),
    actionPrimaryBackground: color('color.action.primary.background.default'),
    actionPrimaryForeground: color('color.action.primary.foreground.default'),
    actionDisabledBackground: color('color.action.disabled.background'),
    actionDisabledForeground: color('color.action.disabled.foreground'),
    link: color('color.foreground.link.default'),
    accentSecondary: color('color.foreground.accent.secondary'),
    border: color('color.border.default'),
    borderStrong: color('color.border.strong'),
    borderFocus: color('color.border.focus'),
    scrim: color('color.overlay.scrim'),
    shadow: color('color.effect.shadow.default'),
    danger: status('danger'),
    success: status('success'),
    warning: status('warning'),
    info: status('info'),
  );

  final type = NanoTypeScale(
    displayHero: _style(tokens, 'DTCG.Type.Display.Hero'),
    displayMetric: _style(tokens, 'DTCG.Type.Display.Metric'),
    displayCompact: _style(tokens, 'DTCG.Type.Display.Compact'),
    headingH1: _style(tokens, 'DTCG.Type.Heading.H1'),
    headingH2: _style(tokens, 'DTCG.Type.Heading.H2'),
    headingH3: _style(tokens, 'DTCG.Type.Heading.H3'),
    headingH4: _style(tokens, 'DTCG.Type.Heading.H4'),
    headingH5: _style(tokens, 'DTCG.Type.Heading.H5'),
    headingH6: _style(tokens, 'DTCG.Type.Heading.H6'),
    bodyDefault: _style(tokens, 'DTCG.Type.Body.Default'),
    bodyReading: _style(tokens, 'DTCG.Type.Body.Reading'),
    bodySupporting: _style(tokens, 'DTCG.Type.Body.Supporting'),
    labelAction: _style(tokens, 'DTCG.Type.Label.Action'),
    labelMetadata: _style(tokens, 'DTCG.Type.Label.Metadata'),
    labelNavigation: _style(tokens, 'DTCG.Type.Label.Navigation'),
  );

  final spacing = NanoSpacingScale(
    insetControl: _num(tokens, 'spacing.inset.control'),
    insetCard: _num(tokens, 'spacing.inset.card'),
    insetDialog: _num(tokens, 'spacing.inset.dialog'),
    insetDefault: _num(tokens, 'spacing.inset.default'),
    stackDefault: _num(tokens, 'spacing.stack.default'),
    stackLabelContent: _num(tokens, 'spacing.stack.label-content'),
    stackSections: _num(tokens, 'spacing.stack.sections'),
    inlineActions: _num(tokens, 'spacing.inline.actions'),
    inlineIconLabel: _num(tokens, 'spacing.inline.icon-label'),
    gutterPage: _num(tokens, 'spacing.gutter.page'),
    gutterGrid: _num(tokens, 'spacing.gutter.grid'),
  );

  final radius = NanoRadiusScale(
    controlDefault: _num(tokens, 'radii.control.default'),
    controlButton: _num(tokens, 'radii.control.button'),
    controlInput: _num(tokens, 'radii.control.input'),
    surfaceCard: _num(tokens, 'radii.surface.card'),
    surfaceDialog: _num(tokens, 'radii.surface.dialog'),
    surfacePopover: _num(tokens, 'radii.surface.popover'),
    pill: _num(tokens, 'radii.shape.pill'),
    avatar: _num(tokens, 'radii.shape.avatar'),
    none: _num(tokens, 'radii.shape.none'),
  );

  final size = NanoSizeScale(
    controlHeightCompact: _num(tokens, 'size.control.height.compact'),
    controlHeightDefault: _num(tokens, 'size.control.height.default'),
    controlHeightLarge: _num(tokens, 'size.control.height.large'),
    avatarCompact: _num(tokens, 'size.avatar.compact'),
    avatarDefault: _num(tokens, 'size.avatar.default'),
    avatarLarge: _num(tokens, 'size.avatar.large'),
    iconDefault: _num(tokens, 'size.icon.default'),
    iconInline: _num(tokens, 'size.icon.inline'),
    iconStatus: _num(tokens, 'size.icon.status'),
    iconAction: _num(tokens, 'size.icon.action'),
    iconDecorative: _num(tokens, 'size.icon.decorative'),
    iconNavigation: _num(tokens, 'size.icon.navigation'),
    indicatorDot: _num(tokens, 'size.indicator.dot'),
    targetTouchMinimum: _num(tokens, 'size.target.touch.minimum'),
    targetPointerMinimum: _num(tokens, 'size.target.pointer.minimum'),
  );

  final borders = NanoBorders(
    controlWidth: _num(tokens, 'border.width.control.default'),
    controlFocusWidth: _num(tokens, 'border.width.control.focus'),
    dividerWidth: _num(tokens, 'border.width.divider.default'),
    surfaceCardWidth: _num(tokens, 'border.width.surface.card'),
  );

  final elevation = NanoElevationScale(
    raised: [_shadow(tokens, 'Elevation.shadow.raised')],
    floating: [_shadow(tokens, 'Elevation.shadow.floating')],
    overlay: [_shadow(tokens, 'Elevation.shadow.overlay')],
  );

  final opacity = NanoOpacityScale(
    stateDefault: _num(tokens, 'opacity.state.default', 1),
    stateDisabled: _num(tokens, 'opacity.state.disabled', 0.4),
    stateDragging: _num(tokens, 'opacity.state.dragging', 0.5),
    stateLoading: _num(tokens, 'opacity.state.loading', 0.5),
    stateHidden: _num(tokens, 'opacity.state.hidden', 0),
  );

  // No motion dimension in the current export — documented defaults.
  const motion = NanoMotionScale(
    durationFast: Duration(milliseconds: 120),
    durationBase: Duration(milliseconds: 200),
    durationSlow: Duration(milliseconds: 320),
    curveStandard: Cubic(0.2, 0, 0, 1),
    curveExit: Cubic(0.3, 0, 1, 1),
  );

  return NanoThemeData(
    brightness: brightness,
    colors: colors,
    type: type,
    spacing: spacing,
    radius: radius,
    size: size,
    borders: borders,
    elevation: elevation,
    opacity: opacity,
    motion: motion,
  );
}

// --- resolved-token JSON readers -------------------------------------------

Never _missing(String path, Object? actual) => throw ArgumentError(
  'Token "$path" missing or malformed in resolved set: $actual',
);

int _argb(Map<String, Object?> tokens, String path) {
  final token = tokens[path];
  if (token is Map && token['argb'] is int) return token['argb'] as int;
  _missing(path, token);
}

double _num(Map<String, Object?> tokens, String path, [double? fallback]) {
  final token = tokens[path];
  if (token == null && fallback != null) return fallback;
  if (token is Map && token['value'] is num) {
    return (token['value'] as num).toDouble();
  }
  _missing(path, token);
}

/// Reads a typography composite (`DTCG.Type.*`) into a [TextStyle].
///
/// Line heights arrive as percentages (150.0 → height 1.5); ratios pass
/// through. Font families arrive as text (string or single-element list).
TextStyle _style(Map<String, Object?> tokens, String path) {
  final token = tokens[path];
  if (token is! Map || token['members'] is! Map) {
    _missing(path, token);
  }
  final members = token['members'] as Map;

  Object? member(String key) {
    final m = members[key];
    if (m is Map && m.containsKey('value')) return m['value'];
    _missing('$path.$key', m);
  }

  final family = member('fontFamily');
  final fontFamily = switch (family) {
    String s => s,
    List<Object?> list when list.isNotEmpty => list.first.toString(),
    _ => null,
  };
  final fontSize = (member('fontSize') as num).toDouble();
  final weight = ((member('fontWeight') as num).toDouble()).round();
  final lineHeight = (member('lineHeight') as num).toDouble();
  final letterSpacing = (member('letterSpacing') as num?)?.toDouble() ?? 0.0;

  return TextStyle(
    fontFamily: (fontFamily?.isEmpty ?? true) ? null : fontFamily,
    fontSize: fontSize,
    fontWeight: FontWeight.values.firstWhere(
      (w) => w.value == weight,
      orElse: () => FontWeight.w400,
    ),
    height: lineHeight > 10 ? lineHeight / 100 : lineHeight,
    letterSpacing: letterSpacing == 0 ? null : letterSpacing,
  );
}

BoxShadow _shadow(Map<String, Object?> tokens, String path) {
  final token = tokens[path];
  if (token is! Map) _missing(path, token);
  final hex = (token['color'] as String?)?.replaceFirst('#', '');
  final color = hex == null
      ? const Color(0x1F000000)
      : Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
  double dim(String key) => switch (token[key]) {
    num n => n.toDouble(),
    String s => double.tryParse(s) ?? 0,
    _ => 0,
  };
  return BoxShadow(
    color: color,
    offset: Offset(dim('offsetX'), dim('offsetY')),
    blurRadius: dim('blur'),
    spreadRadius: dim('spread'),
  );
}
