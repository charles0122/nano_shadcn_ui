import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_ui/nano_ui.dart';

import 'token_fixture.dart';

Widget wrap(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: NanoTheme(data: fixtureTheme(), child: child),
);

void main() {
  group('nanoThemeFromTokens', () {
    test('maps token paths onto theme roles', () {
      final theme = fixtureTheme();
      expect(theme.brightness, Brightness.light);
      expect(theme.colors.accent, const Color(0xFF6750A4));
      // size.control.height.* all resolve to 8 in the fixture.
      expect(theme.size.controlHeightDefault, 8.0);
      // Percent line height 150 → TextStyle height 1.5.
      expect(theme.type.bodyDefault.height, 1.5);
      expect(theme.type.bodyDefault.fontSize, 16.0);
      // Shadow composite → BoxShadow.
      expect(theme.elevation.raised.single.blurRadius, 8.0);
    });

    test('different accent token → different theme (brand switch)', () {
      final halloween = fixtureTheme(accent: 0xFF9B4A15);
      expect(halloween.colors.accent, const Color(0xFF9B4A15));
      expect(halloween, isNot(fixtureTheme()));
    });
  });

  testWidgets('NanoTheme.of returns the provided data', (tester) async {
    final theme = fixtureTheme();
    late NanoThemeData observed;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: NanoTheme(
          data: theme,
          child: Builder(
            builder: (context) {
              observed = NanoTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(observed.brightness, Brightness.light);
    expect(identical(observed, theme), isTrue);
  });

  testWidgets(
    'aspect dependency: colors change rebuild, shapes change does not',
    (tester) async {
      var colorBuilds = 0;
      // The dependent widget must be the SAME instance across pumps, so any
      // rebuild below can only come from the InheritedModel notification.
      final colorsDependent = Builder(
        builder: (context) {
          NanoTheme.of(context, aspect: NanoThemeAspect.colors);
          colorBuilds++;
          return const SizedBox.shrink();
        },
      );
      Widget shell(NanoThemeData data) => Directionality(
        textDirection: TextDirection.ltr,
        child: NanoTheme(data: data, child: colorsDependent),
      );

      final base = fixtureTheme();
      await tester.pumpWidget(shell(base));
      final afterFirst = colorBuilds;
      expect(afterFirst, 1);

      // Same colors instance, different shapes → no rebuild.
      final reshaped = NanoThemeData(
        brightness: base.brightness,
        colors: base.colors,
        type: base.type,
        spacing: base.spacing,
        radius: const NanoRadiusScale(
          controlDefault: 99,
          controlButton: 99,
          controlInput: 99,
          surfaceCard: 99,
          surfaceDialog: 99,
          surfacePopover: 99,
          pill: 99,
          avatar: 99,
          none: 0,
        ),
        size: base.size,
        borders: base.borders,
        elevation: base.elevation,
        opacity: base.opacity,
        motion: base.motion,
      );
      await tester.pumpWidget(shell(reshaped));
      expect(colorBuilds, afterFirst);

      // New colors instance → rebuild.
      await tester.pumpWidget(shell(fixtureTheme(accent: 0xFF9B4A15)));
      expect(colorBuilds, afterFirst + 1);
    },
  );

  test('lerp endpoints are exact and midpoints interpolate', () {
    final a = fixtureTheme();
    final b = fixtureTheme(accent: 0xFF9B4A15);

    // Endpoints: lerp(a, b, 0) == a, lerp(a, b, 1) == b.
    expect(NanoThemeData.lerp(a, b, 0), a);
    expect(NanoThemeData.lerp(a, b, 1), b);

    // Color midpoint: per-channel lerp of #6750A4 ↔ #9B4A15.
    final half = NanoThemeData.lerp(a, b, 0.5);
    expect(half.colors.accent.r, closeTo(129 / 255, 0.01)); // (0x67 + 0x9B) / 2
    expect(half.colors.accent.g, closeTo(77 / 255, 0.01)); // (0x50 + 0x4A) / 2
    expect(half.colors.accent.b, closeTo(92.5 / 255, 0.01));

    // Doubles: stackDefault 8 (fixture) ↔ 16 → 12.
    const spacingB = NanoSpacingScale(
      insetControl: 16,
      insetCard: 16,
      insetDialog: 16,
      insetDefault: 16,
      stackDefault: 16,
      stackLabelContent: 16,
      stackSections: 16,
      inlineActions: 16,
      inlineIconLabel: 16,
      gutterPage: 16,
      gutterGrid: 16,
    );
    expect(a.spacing.lerp(spacingB, 0.5).stackDefault, 12.0);

    // Text style: fontSize 16 ↔ 16 stays 16; percent height 1.5 preserved.
    expect(half.type.bodyDefault.fontSize, 16.0);
    expect(half.type.bodyDefault.height, 1.5);

    // Shadow composite: blur 8 ↔ 8 → 8.
    expect(half.elevation.raised.single.blurRadius, 8.0);

    // Brightness is discrete: switches at t = 0.5.
    final dark = fixtureTheme();
    final darkB = NanoThemeData(
      brightness: Brightness.dark,
      colors: dark.colors,
      type: dark.type,
      spacing: dark.spacing,
      radius: dark.radius,
      size: dark.size,
      borders: dark.borders,
      elevation: dark.elevation,
      opacity: dark.opacity,
      motion: dark.motion,
    );
    expect(NanoThemeData.lerp(a, darkB, 0.49).brightness, Brightness.light);
    expect(NanoThemeData.lerp(a, darkB, 0.51).brightness, Brightness.dark);
  });

  testWidgets('NanoAnimatedTheme morphs between themes over motion duration', (
    tester,
  ) async {
    final themeA = fixtureTheme(accent: 0xFF6750A4);
    final themeB = fixtureTheme(accent: 0xFF9B4A15);

    Widget shell(NanoThemeData data) => Directionality(
      textDirection: TextDirection.ltr,
      child: NanoAnimatedTheme(
        data: data,
        child: Builder(
          builder: (context) {
            final colors = NanoTheme.of(
              context,
              aspect: NanoThemeAspect.colors,
            ).colors;
            return ColoredBox(
              color: colors.accent,
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );

    await tester.pumpWidget(shell(themeA));
    final accentBox = find.byType(ColoredBox);

    // Theme switch: at t=0 still the old accent.
    await tester.pumpWidget(shell(themeB));
    expect(tester.widget<ColoredBox>(accentBox).color, themeA.colors.accent);

    // Half-way through the 320ms default duration → strictly between.
    await tester.pump(const Duration(milliseconds: 160));
    final mid = tester.widget<ColoredBox>(accentBox).color;
    expect(mid, isNot(themeA.colors.accent));
    expect(mid, isNot(themeB.colors.accent));

    // Settled → exactly the new theme.
    await tester.pumpAndSettle();
    expect(tester.widget<ColoredBox>(accentBox).color, themeB.colors.accent);
  });
}
