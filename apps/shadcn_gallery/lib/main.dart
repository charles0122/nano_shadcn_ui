import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:nano_shadcn_ui/nano_shadcn_ui.dart';

import 'shell.dart';

void main() => runApp(const ShadcnGalleryApp());

/// Theme dimensions mirroring the shadcn/ui customizer: base color,
/// light/dark mode, and corner radius — each a DTCG theme group resolved by
/// the token pipeline into one combo file per combination.
class ThemeSelection {
  const ThemeSelection({String? brand, String? mode, String? radius})
    : brand = brand ?? 'Zinc',
      mode = mode ?? 'Light',
      radius = radius ?? 'R050';

  final String brand;
  final String mode;
  final String radius;

  ThemeSelection copyWith({String? brand, String? mode, String? radius}) =>
      ThemeSelection(
        brand: brand ?? this.brand,
        mode: mode ?? this.mode,
        radius: radius ?? this.radius,
      );

  String get comboName => '$brand+$mode+$radius';

  Brightness get brightness =>
      mode == 'Dark' ? Brightness.dark : Brightness.light;
}

class ShadcnGalleryApp extends StatefulWidget {
  const ShadcnGalleryApp({super.key});

  @override
  State<ShadcnGalleryApp> createState() => _ShadcnGalleryAppState();
}

class _ShadcnGalleryAppState extends State<ShadcnGalleryApp> {
  Map<String, Object?>? _manifest;
  final Map<String, Map<String, Object?>> _comboCache = {};
  final Map<String, Future<void>> _pending = {};
  Object? _loadError;
  late ThemeSelection _selection = _selectionFromUri();
  NanoThemeData? _theme;

  /// Deep link: `?brand=Violet&mode=Dark&radius=R075` — the customizer
  /// state survives reloads and can be linked directly.
  static ThemeSelection _selectionFromUri() {
    final query = Uri.base.queryParameters;
    return ThemeSelection(
      brand: query['brand'],
      mode: query['mode'],
      radius: query['radius'],
    );
  }

  @override
  void initState() {
    super.initState();
    _select(_selection);
  }

  Future<void> _select(ThemeSelection selection) async {
    try {
      if (_manifest == null) {
        _manifest = jsonDecode(
          await rootBundle.loadString('assets/tokens/themes.manifest.json'),
        ) as Map<String, Object?>;
      }
      final name = selection.comboName;
      if (!_comboCache.containsKey(name)) {
        final load = _pending.putIfAbsent(name, () async {
          final raw = await rootBundle.loadString(
            'assets/tokens/tokens.combo.${name.replaceAll('+', '-')}.json',
          );
          _comboCache[name] = jsonDecode(raw) as Map<String, Object?>;
        });
        await load;
        _pending.remove(name);
      }
      setState(() {
        _selection = selection;
        _theme = nanoThemeFromTokens(
          _comboCache[name]!,
          brightness: selection.brightness,
        );
      });
    } catch (e) {
      setState(() => _loadError = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final manifest = _manifest;
    if (_loadError != null) {
      return WidgetsApp(
        color: const Color(0xFF18181B),
        builder: (context, _) => Center(
          child: Text(
            'Token assets failed to load:\n$_loadError',
            style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 14),
          ),
        ),
      );
    }
    final theme = _theme;
    if (theme == null || manifest == null) {
      return WidgetsApp(
        color: const Color(0xFF18181B),
        builder: (context, _) => const Center(child: Text('Loading tokens…')),
      );
    }
    return NanoAnimatedTheme(
      data: theme,
      child: WidgetsApp(
        title: 'shadcn/ui × nano_ui',
        color: const Color(0xFF18181B),
        home: GalleryShell(
          selection: _selection,
          manifest: manifest,
          onSelectionChanged: _select,
        ),
        pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
        // `child` is the Navigator — wrapping it here keeps the root Overlay
        // alive for every popover / dialog / menu / toast.
        builder: (context, child) => DefaultTextStyle(
          style: theme.type.bodyDefault.copyWith(
            color: theme.colors.textPrimary,
          ),
          child: NanoToaster(child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}
