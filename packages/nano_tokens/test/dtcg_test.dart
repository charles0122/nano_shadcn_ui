import 'package:nano_tokens/nano_tokens.dart';
import 'package:test/test.dart';

void main() {
  group('DtcgParser', () {
    test('parses tokens, groups and dollar-properties', () {
      final root = DtcgParser.parse('''
{
  "\$description": "root doc",
  "color": {
    "accent": { "\$type": "color", "\$value": "#5B5BD6", "\$description": "brand" }
  },
  "size": { "\$type": "dimension", "md": { "\$value": 12 } }
}
''');
      final tokens = <String, DtcgToken>{};
      root.visit((t) => tokens[t.path] = t);
      expect(tokens.keys, containsAll(['color.accent', 'size.md']));
      expect(tokens['color.accent']!.declaredType, DtcgType.color);
      expect(tokens['color.accent']!.description, 'brand');
      // Group-level $type is inherited.
      expect(tokens['size.md']!.declaredType, DtcgType.dimension);
    });

    test('rejects non-object nodes and unknown types', () {
      expect(
        () => DtcgParser.parse('{"a": 1}'),
        throwsA(isA<DtcgFormatException>()),
      );
      expect(
        () => DtcgParser.parse(
            '{"a": {"\$type": "wat", "\$value": 1}}'),
        throwsA(isA<DtcgFormatException>()),
      );
    });
  });

  group('DtcgResolver', () {
    DtcgResolver resolverOf(Map<String, Object?> json) => DtcgResolver([
          DtcgParser.parseMap(json, name: 'test', path: ''),
        ]);

    test('resolves references across groups and expands #RGB', () {
      final r = resolverOf({
        'gray': {'0': {'\$type': 'color', '\$value': '#fff'}},
        'bg': {'canvas': {'\$value': '{gray.0}'}},
      });
      final value = r.resolve('bg.canvas') as DtcgColorValue;
      expect(value.argb, 0xFFFFFFFF);
    });

    test('supports #RRGGBBAA and px dimensions', () {
      final r = resolverOf({
        'c': {'a': {'\$type': 'color', '\$value': '#FF000080'}},
        'd': {'w': {'\$type': 'dimension', '\$value': '16px'}},
      });
      expect((r.resolve('c.a') as DtcgColorValue).argb, 0xFF000080);
      expect((r.resolve('d.w') as DtcgDimensionValue).value, 16.0);
    });

    test('resolves typography composites with member references', () {
      final r = resolverOf({
        'font-size': {'lg': {'\$type': 'dimension', '\$value': 16}},
        'font-weight': {'bold': {'\$type': 'fontWeight', '\$value': 700}},
        'type': {
          'heading': {
            '\$type': 'typography',
            '\$value': {'fontSize': '{font-size.lg}', 'fontWeight': '{font-weight.bold}'},
          },
        },
      });
      final t = r.resolve('type.heading') as DtcgTypographyValue;
      expect((t.members['fontSize'] as DtcgDimensionValue).value, 16.0);
      expect((t.members['fontWeight'] as DtcgFontWeightValue).value, 700);
    });

    test('unknown reference reports the offending path', () {
      final r = resolverOf({
        'bg': {'canvas': {'\$type': 'color', '\$value': '{palette.missing}'}},
      });
      expect(
        () => r.resolve('bg.canvas'),
        throwsA(
          isA<DtcgResolveException>().having(
            (e) => e.message,
            'message',
            contains('palette.missing'),
          ),
        ),
      );
    });

    test('detects circular references', () {
      final r = resolverOf({
        'a': {'x': {'\$type': 'color', '\$value': '{a2.y}'}},
        'a2': {'y': {'\$type': 'color', '\$value': '{a.x}'}},
      });
      expect(
        () => r.resolve('a.x'),
        throwsA(isA<DtcgResolveException>().having(
          (e) => e.message,
          'message',
          contains('Circular'),
        )),
      );
    });

    test('enforces declared type on aliases', () {
      final r = resolverOf({
        'n': {'one': {'\$type': 'number', '\$value': 1}},
        'c': {'bad': {'\$type': 'color', '\$value': '{n.one}'}},
      });
      expect(
        () => r.resolve('c.bad'),
        throwsA(isA<DtcgResolveException>().having(
          (e) => e.message,
          'message',
          contains('Type mismatch'),
        )),
      );
    });

    test('requires a type for literals', () {
      final r = resolverOf({
        'mystery': {'value': {'\$value': '#fff'}},
      });
      expect(() => r.resolve('mystery.value'),
          throwsA(isA<DtcgResolveException>()));
    });

    test('parses text tokens and percent numbers', () {
      final r = resolverOf({
        's': {'label': {'\$type': 'text', '\$value': 'hello'}},
        'lh': {'body': {'\$type': 'number', '\$value': '150%'}},
      });
      expect((r.resolve('s.label') as DtcgStringValue).value, 'hello');
      expect((r.resolve('lh.body') as DtcgNumberValue).value, 1.5);
    });

    test('accepts stringish and numeric cross-type aliases', () {
      final r = resolverOf({
        'platform': {
          'font-family': {
            'latin': {'\$type': 'text', '\$value': 'SF Pro'},
          },
        },
        'brand': {
          'font-family': {
            'latin': {'\$type': 'fontFamilies', '\$value': '{platform.font-family.latin}'},
          },
        },
        'scale': {
          'gap': {'\$type': 'dimension', '\$value': 8},
          'pad': {'\$type': 'number', '\$value': '{scale.gap}'},
        },
      });
      expect(
          (r.resolve('brand.font-family.latin') as DtcgStringValue).value,
          'SF Pro');
      // Aliases return the target's value — the dimension 8 flows through
      // the number-declared alias.
      expect((r.resolve('scale.pad') as DtcgDimensionValue).value, 8.0);
    });

    test('still rejects genuinely incompatible aliases', () {
      final r = resolverOf({
        'c': {'red': {'\$type': 'color', '\$value': '#ff0000'}},
        'n': {'one': {'\$type': 'number', '\$value': '{c.red}'}},
      });
      expect(() => r.resolve('n.one'), throwsA(isA<DtcgResolveException>()));
    });

    test('parses boxShadow composites with string members and refs', () {
      final r = resolverOf({
        'shadow': {
          'y': {'\$type': 'number', '\$value': 2},
        },
        'elevation': {
          'raised': {
            '\$type': 'boxShadow',
            '\$value': {
              'color': '#0000001f',
              'type': 'dropShadow',
              'x': '0',
              'y': '{shadow.y}',
              'blur': '8',
              'spread': '0',
            },
          },
        },
      });
      final shadow = r.resolve('elevation.raised') as DtcgShadowValue;
      expect(shadow.color, 0x0000001f);
      expect(shadow.offsetX, 0.0);
      expect(shadow.offsetY, 2.0);
      expect(shadow.blur, 8.0);
      expect(shadow.inset, isFalse);
    });

    test('normalizes legacy Tokens Studio type names and named weights', () {
      final r = resolverOf({
        'fontSizes': {'lg': {'\$type': 'fontSizes', '\$value': 16}},
        'fontWeights': {'hero': {'\$type': 'fontWeights', '\$value': 'Bold'}},
      });
      expect((r.resolve('fontSizes.lg') as DtcgDimensionValue).value, 16.0);
      expect((r.resolve('fontWeights.hero') as DtcgFontWeightValue).value, 700);
    });
  });
}
