import 'dart:ui' show Brightness;

import 'package:nano_shadcn_ui/nano_shadcn_ui.dart';

/// Minimal resolved-token fixture covering every path the bridge reads.
/// Mirrors the shape of `dist/tokens.combo.*.json`.
Map<String, Object?> fixtureTokens({int accent = 0xFF6750A4}) {
  final tokens = <String, Object?>{};

  const colorPaths = [
    'color.canvas',
    'color.surface',
    'color.background.surface.subtle',
    'color.foreground.text.primary',
    'color.foreground.text.secondary',
    'color.foreground.text.disabled',
    'color.foreground.icon.primary',
    'color.foreground.icon.secondary',
    'color.accent',
    'color.onAccent',
    'color.action.primary.background.default',
    'color.action.primary.foreground.default',
    'color.action.disabled.background',
    'color.action.disabled.foreground',
    'color.foreground.link.default',
    'color.foreground.accent.secondary',
    'color.border.default',
    'color.border.strong',
    'color.border.focus',
    'color.overlay.scrim',
    'color.effect.shadow.default',
  ];
  for (final path in colorPaths) {
    tokens[path] = {
      'type': 'color',
      'argb': path == 'color.accent' ? accent : 0xFF17212D,
    };
  }
  for (final status in ['danger', 'success', 'warning', 'info']) {
    for (final part in ['foreground', 'background', 'border']) {
      tokens['color.status.$status.$part'] = {
        'type': 'color',
        'argb': 0xFF15803D,
      };
    }
  }

  const typeRoles = [
    'DTCG.Type.Display.Hero',
    'DTCG.Type.Display.Metric',
    'DTCG.Type.Display.Compact',
    'DTCG.Type.Heading.H1',
    'DTCG.Type.Heading.H2',
    'DTCG.Type.Heading.H3',
    'DTCG.Type.Heading.H4',
    'DTCG.Type.Heading.H5',
    'DTCG.Type.Heading.H6',
    'DTCG.Type.Body.Default',
    'DTCG.Type.Body.Reading',
    'DTCG.Type.Body.Supporting',
    'DTCG.Type.Label.Action',
    'DTCG.Type.Label.Metadata',
    'DTCG.Type.Label.Navigation',
  ];
  for (final role in typeRoles) {
    tokens[role] = {
      'type': 'typography',
      'members': {
        'fontFamily': {'type': 'text', 'value': 'Inter'},
        'fontSize': {'type': 'dimension', 'value': 16},
        'fontWeight': {'type': 'number', 'value': 400},
        'lineHeight': {'type': 'number', 'value': 150},
        'letterSpacing': {'type': 'number', 'value': 0},
      },
    };
  }

  const scalarPaths = [
    'spacing.inset.control',
    'spacing.inset.card',
    'spacing.inset.dialog',
    'spacing.inset.default',
    'spacing.stack.default',
    'spacing.stack.label-content',
    'spacing.stack.sections',
    'spacing.inline.actions',
    'spacing.inline.icon-label',
    'spacing.gutter.page',
    'spacing.gutter.grid',
    'radii.control.default',
    'radii.control.button',
    'radii.control.input',
    'radii.surface.card',
    'radii.surface.dialog',
    'radii.surface.popover',
    'radii.shape.pill',
    'radii.shape.avatar',
    'radii.shape.none',
    'size.control.height.compact',
    'size.control.height.default',
    'size.control.height.large',
    'size.avatar.compact',
    'size.avatar.default',
    'size.avatar.large',
    'size.icon.default',
    'size.icon.inline',
    'size.icon.status',
    'size.icon.action',
    'size.icon.decorative',
    'size.icon.navigation',
    'size.indicator.dot',
    'size.target.touch.minimum',
    'size.target.pointer.minimum',
    'border.width.control.default',
    'border.width.control.focus',
    'border.width.divider.default',
    'border.width.surface.card',
    'opacity.state.default',
    'opacity.state.disabled',
    'opacity.state.dragging',
    'opacity.state.loading',
    'opacity.state.hidden',
  ];
  for (final path in scalarPaths) {
    tokens[path] = {'type': 'number', 'value': 8};
  }

  for (final level in ['raised', 'floating', 'overlay']) {
    tokens['Elevation.shadow.$level'] = {
      'type': 'boxShadow',
      'color': '#0000001F',
      'offsetX': 0,
      'offsetY': 2,
      'blur': 8,
      'spread': 0,
    };
  }

  return tokens;
}

NanoThemeData fixtureTheme({int? accent}) => nanoThemeFromTokens(
  fixtureTokens(accent: accent ?? 0xFF6750A4),
  brightness: Brightness.light,
);
