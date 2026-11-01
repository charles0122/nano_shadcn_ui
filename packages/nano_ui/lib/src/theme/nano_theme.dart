import 'package:flutter/widgets.dart';

import 'nano_theme_data.dart';

/// Categories a widget can depend on, so theme switches only rebuild what
/// actually changed for that widget.
enum NanoThemeAspect {
  colors,
  typography,
  spacing,
  shapes,
  elevation,
  motion,
  opacity,
}

/// Inherited theme model for the nano design system.
///
/// ```dart
/// final theme = NanoTheme.of(context);                       // full data
/// final colors = NanoTheme.of(context, aspect: NanoThemeAspect.colors).colors;
/// ```
class NanoTheme extends InheritedModel<NanoThemeAspect> {
  const NanoTheme({super.key, required this.data, required super.child});

  final NanoThemeData data;

  static NanoThemeData of(BuildContext context, {NanoThemeAspect? aspect}) {
    final theme = InheritedModel.inheritFrom<NanoTheme>(
      context,
      aspect: aspect,
    );
    if (theme == null) {
      throw FlutterError(
        'No NanoTheme found in context. Wrap your app (or subtree) in a '
        'NanoTheme widget, e.g. NanoTheme(data: myTheme, child: …).',
      );
    }
    return theme.data;
  }

  @override
  bool updateShouldNotify(NanoTheme oldWidget) => data != oldWidget.data;

  @override
  bool updateShouldNotifyDependent(
    NanoTheme oldWidget,
    Set<NanoThemeAspect> dependencies,
  ) {
    bool shapesChanged(NanoThemeData a, NanoThemeData b) =>
        a.radius != b.radius || a.size != b.size || a.borders != b.borders;
    for (final aspect in dependencies) {
      final changed = switch (aspect) {
        NanoThemeAspect.colors => data.colors != oldWidget.data.colors,
        NanoThemeAspect.typography => data.type != oldWidget.data.type,
        NanoThemeAspect.spacing => data.spacing != oldWidget.data.spacing,
        NanoThemeAspect.shapes => shapesChanged(data, oldWidget.data),
        NanoThemeAspect.elevation => data.elevation != oldWidget.data.elevation,
        NanoThemeAspect.motion => data.motion != oldWidget.data.motion,
        NanoThemeAspect.opacity => data.opacity != oldWidget.data.opacity,
      };
      if (changed) return true;
    }
    return false;
  }
}
