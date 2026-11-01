import 'package:flutter/widgets.dart';

import '../theme/nano_theme.dart';

/// Lucide-style stroke icon set for nano_ui — the icon vocabulary shadcn/ui
/// components are drawn with.
///
/// Icons are defined on the lucide 24×24 grid with 2px round strokes; the
/// painter scales the grid to the requested size. Icons inherit color like
/// text (lucide's `currentColor` model): pass [NanoIcon.color] to override,
/// otherwise the ambient `DefaultTextStyle` color (or [NanoIconTheme]) wins.
class NanoIconData {
  const NanoIconData(this.paths);

  /// SVG path data strings on the 24×24 grid. Zero-length `h.01`-style
  /// segments render as round dots (how lucide draws dots).
  final List<String> paths;
}

/// Stroke icon painter. Path data is parsed once and cached per string.
class NanoIconPainter extends CustomPainter {
  NanoIconPainter({
    required this.icon,
    required this.color,
    required this.strokeWidth,
  });

  final NanoIconData icon;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = color;
    for (final data in icon.paths) {
      final path = _svgPath(data);
      final bounds = path.getBounds();
      if (bounds.width < 0.02 && bounds.height < 0.02) {
        // Degenerate segments are lucide dots — draw them filled.
        if (bounds != Rect.zero) {
          canvas.drawCircle(bounds.topLeft, stroke.strokeWidth / 2, fill);
        }
        continue;
      }
      canvas.save();
      canvas.scale(scale);
      canvas.drawPath(path, stroke);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(NanoIconPainter old) =>
      old.icon != icon || old.color != color || old.strokeWidth != strokeWidth;
}

/// A lucide-style stroke icon.
///
/// ```dart
/// NanoIcon(NanoIcons.chevronDown, size: 16)
/// ```
class NanoIcon extends StatelessWidget {
  const NanoIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.strokeWidth,
  });

  final NanoIconData icon;

  /// Rendered edge length; defaults to the theme's `size.icon.default`.
  final double? size;
  final Color? color;

  /// Lucide grid stroke weight (2 = the default lucide look).
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context, aspect: NanoThemeAspect.shapes);
    final effectiveSize = size ?? theme.size.iconDefault;
    final Color effectiveColor;
    if (color != null) {
      effectiveColor = color!;
    } else {
      final inherited = context
          .getInheritedWidgetOfExactType<InheritedNanoIconTheme>();
      final style = context
          .getInheritedWidgetOfExactType<DefaultTextStyle>()
          ?.style;
      effectiveColor =
          inherited?.color ?? style?.color ?? const Color(0xFF000000);
    }
    return SizedBox.square(
      dimension: effectiveSize,
      child: CustomPaint(
        painter: NanoIconPainter(
          icon: icon,
          color: effectiveColor,
          strokeWidth: strokeWidth ?? 2,
        ),
      ),
    );
  }
}

/// Optional scoped default for icon color (e.g. a muted icon column).
class NanoIconTheme extends StatelessWidget {
  const NanoIconTheme({super.key, required this.color, required this.child});

  final Color color;
  final Widget child;

  static Color? maybeColorOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<InheritedNanoIconTheme>()
      ?.color;

  @override
  Widget build(BuildContext context) =>
      InheritedNanoIconTheme(color: color, child: child);
}

class InheritedNanoIconTheme extends InheritedWidget {
  const InheritedNanoIconTheme({
    super.key,
    required this.color,
    required super.child,
  });

  final Color color;

  @override
  bool updateShouldNotify(InheritedNanoIconTheme oldWidget) =>
      oldWidget.color != color;
}

// ---------------------------------------------------------------------------
// SVG path parsing (subset: M L H V C S Q T A Z — all lucide data is written
// with explicit command letters, so no implicit-repetition handling needed).
// ---------------------------------------------------------------------------

final Map<String, Path> _pathCache = {};

Path _svgPath(String data) =>
    _pathCache.putIfAbsent(data, () => _SvgPathParser(data).parse());

class _SvgPathParser {
  _SvgPathParser(this._data);
  final String _data;
  int _pos = 0;
  final Path _path = Path();
  double _cx = 0, _cy = 0; // current point
  double _sx = 0, _sy = 0; // subpath start
  double _px = 0, _py = 0; // previous control point (for S/T smoothing)

  Path parse() {
    _skipSpace();
    while (_pos < _data.length) {
      final cmd = _data[_pos];
      _pos++;
      switch (cmd) {
        case 'M' || 'm':
          final rel = cmd == 'm';
          final x = _number(), y = _number();
          if (x == null || y == null) return _path;
          _cx = rel ? _cx + x : x;
          _cy = rel ? _cy + y : y;
          _path.moveTo(_cx, _cy);
          _sx = _cx;
          _sy = _cy;
        case 'L' || 'l':
          final rel = cmd == 'l';
          final x = _number(), y = _number();
          if (x == null || y == null) return _path;
          _cx = rel ? _cx + x : x;
          _cy = rel ? _cy + y : y;
          _path.lineTo(_cx, _cy);
        case 'H' || 'h':
          final rel = cmd == 'h';
          final x = _number();
          if (x == null) return _path;
          _cx = rel ? _cx + x : x;
          _path.lineTo(_cx, _cy);
        case 'V' || 'v':
          final rel = cmd == 'v';
          final y = _number();
          if (y == null) return _path;
          _cy = rel ? _cy + y : y;
          _path.lineTo(_cx, _cy);
        case 'C' || 'c':
          final rel = cmd == 'c';
          final x1 = _number(), y1 = _number();
          final x2 = _number(), y2 = _number();
          final x = _number(), y = _number();
          if (x1 == null ||
              y1 == null ||
              x2 == null ||
              y2 == null ||
              x == null ||
              y == null) {
            return _path;
          }
          final ax1 = rel ? _cx + x1 : x1;
          final ay1 = rel ? _cy + y1 : y1;
          final ax2 = rel ? _cx + x2 : x2;
          final ay2 = rel ? _cy + y2 : y2;
          _cx = rel ? _cx + x : x;
          _cy = rel ? _cy + y : y;
          _path.cubicTo(ax1, ay1, ax2, ay2, _cx, _cy);
          _px = ax2;
          _py = ay2;
        case 'S' || 's':
          final rel = cmd == 's';
          final x2 = _number(), y2 = _number();
          final x = _number(), y = _number();
          if (x2 == null || y2 == null || x == null || y == null) return _path;
          final sx = 2 * _cx - _px;
          final sy = 2 * _cy - _py;
          final ax2 = rel ? _cx + x2 : x2;
          final ay2 = rel ? _cy + y2 : y2;
          _cx = rel ? _cx + x : x;
          _cy = rel ? _cy + y : y;
          _path.cubicTo(sx, sy, ax2, ay2, _cx, _cy);
          _px = ax2;
          _py = ay2;
        case 'Q' || 'q':
          final rel = cmd == 'q';
          final x1 = _number(), y1 = _number();
          final x = _number(), y = _number();
          if (x1 == null || y1 == null || x == null || y == null) return _path;
          final ax1 = rel ? _cx + x1 : x1;
          final ay1 = rel ? _cy + y1 : y1;
          _cx = rel ? _cx + x : x;
          _cy = rel ? _cy + y : y;
          _path.quadraticBezierTo(ax1, ay1, _cx, _cy);
          _px = ax1;
          _py = ay1;
        case 'T' || 't':
          final rel = cmd == 't';
          final x = _number(), y = _number();
          if (x == null || y == null) return _path;
          final sx = 2 * _cx - _px;
          final sy = 2 * _cy - _py;
          _cx = rel ? _cx + x : x;
          _cy = rel ? _cy + y : y;
          _path.quadraticBezierTo(sx, sy, _cx, _cy);
          _px = sx;
          _py = sy;
        case 'A' || 'a':
          final rel = cmd == 'a';
          final rx = _number(), ry = _number();
          final rot = _number();
          final large = _number(), sweep = _number();
          final x = _number(), y = _number();
          if (rx == null ||
              ry == null ||
              rot == null ||
              large == null ||
              sweep == null ||
              x == null ||
              y == null) {
            return _path;
          }
          final ex = rel ? _cx + x : x;
          final ey = rel ? _cy + y : y;
          if (rx == 0 || ry == 0 || (_cx == ex && _cy == ey)) {
            _path.lineTo(ex, ey);
          } else {
            _path.arcToPoint(
              Offset(ex, ey),
              radius: Radius.elliptical(rx, ry),
              rotation: rot,
              largeArc: large != 0,
              clockwise: sweep != 0,
            );
          }
          _cx = ex;
          _cy = ey;
        case 'Z' || 'z':
          _path.close();
          _cx = _sx;
          _cy = _sy;
        default:
          return _path; // unknown command — stop parsing this path
      }
      _px = _cx;
      _py = _cy;
      _skipSpace();
    }
    return _path;
  }

  double? _number() {
    if (_pos < _data.length && _data[_pos] == ',') _pos++;
    _skipSpace();
    final start = _pos;
    if (_pos < _data.length && (_data[_pos] == '-' || _data[_pos] == '+'))
      _pos++;
    var seenDigit = false, seenDot = false;
    while (_pos < _data.length) {
      final c = _data[_pos];
      if (c.codeUnitAt(0) >= 0x30 && c.codeUnitAt(0) <= 0x39) {
        seenDigit = true;
      } else if (c == '.' && !seenDot) {
        seenDot = true;
      } else if ((c == 'e' || c == 'E') && seenDigit) {
        _pos++;
        if (_pos < _data.length && (_data[_pos] == '-' || _data[_pos] == '+')) {
          _pos++;
        }
        seenDot = true;
      } else {
        break;
      }
      _pos++;
    }
    if (!seenDigit) {
      _pos = start;
      return null;
    }
    return double.tryParse(_data.substring(start, _pos));
  }

  void _skipSpace() {
    while (_pos < _data.length &&
        (_data[_pos] == ' ' || _data[_pos] == '\n' || _data[_pos] == '\t')) {
      _pos++;
    }
  }
}

/// The lucide icons nano_ui components use. Paths are verbatim lucide
/// (ISC-licensed) path data on the 24×24 grid, rewritten with explicit
/// command letters for the minimal parser above.
abstract final class NanoIcons {
  static const chevronDown = NanoIconData([r'M6 9l6 6 6-6']);
  static const chevronUp = NanoIconData([r'M18 15l-6-6-6 6']);
  static const chevronLeft = NanoIconData([r'M15 18l-6-6 6-6']);
  static const chevronRight = NanoIconData([r'M9 18l6-6-6-6']);
  static const chevronsUpDown = NanoIconData([
    r'M7 15L12 20L17 15',
    r'M7 9L12 4L17 9',
  ]);
  static const chevronsLeftRight = NanoIconData([
    r'M9 7L4 12L9 17',
    r'M15 7L20 12L15 17',
  ]);
  static const chevronsLeft = NanoIconData([
    r'M11 17L6 12L11 7',
    r'M18 17L13 12L18 7',
  ]);
  static const chevronsRight = NanoIconData([
    r'M6 17L11 12L6 7',
    r'M13 17L18 12L13 7',
  ]);
  static const check = NanoIconData([r'M20 6L9 17l-5-5']);
  static const x = NanoIconData([r'M18 6L6 18', r'M6 6L18 18']);
  static const plus = NanoIconData([r'M5 12h14', r'M12 5v14']);
  static const minus = NanoIconData([r'M5 12h14']);
  static const search = NanoIconData([
    r'M11 3A8 8 0 1 0 11 19A8 8 0 1 0 11 3',
    r'M21 21l-4.3-4.3',
  ]);
  static const circle = NanoIconData([
    r'M12 2A10 10 0 1 0 12 22A10 10 0 1 0 12 2',
  ]);
  static const circleDot = NanoIconData([
    r'M12 2A10 10 0 1 0 12 22A10 10 0 1 0 12 2',
    r'M12 12h.01',
  ]);
  static const circleAlert = NanoIconData([
    r'M12 2A10 10 0 1 0 12 22A10 10 0 1 0 12 2',
    r'M12 8v4',
    r'M12 16h.01',
  ]);
  static const circleCheck = NanoIconData([
    r'M21.801 10A10 10 0 1 1 17 3.335',
    r'M9 11l3 3L22 4',
  ]);
  static const circleX = NanoIconData([
    r'M12 2A10 10 0 1 0 12 22A10 10 0 1 0 12 2',
    r'M15 9l-6 6',
    r'M9 9l6 6',
  ]);
  static const circleMinus = NanoIconData([
    r'M12 2A10 10 0 1 0 12 22A10 10 0 1 0 12 2',
    r'M8 12h8',
  ]);
  static const circleHelp = NanoIconData([
    r'M12 2A10 10 0 1 0 12 22A10 10 0 1 0 12 2',
    r'M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3',
    r'M12 17h.01',
  ]);
  static const info = NanoIconData([
    r'M12 2A10 10 0 1 0 12 22A10 10 0 1 0 12 2',
    r'M12 16v-4',
    r'M12 8h.01',
  ]);
  static const ellipsis = NanoIconData([
    r'M5 12h.01',
    r'M12 12h.01',
    r'M19 12h.01',
  ]);
  static const ellipsisVertical = NanoIconData([
    r'M12 5h.01',
    r'M12 12h.01',
    r'M12 19h.01',
  ]);
  static const arrowRight = NanoIconData([r'M5 12h14', r'M12 5L19 12L12 19']);
  static const arrowLeft = NanoIconData([r'M19 12H5', r'M12 19L5 12L12 5']);
  static const arrowUp = NanoIconData([r'M12 19V5', r'M5 12L12 5L19 12']);
  static const arrowDown = NanoIconData([r'M12 5v14', r'M19 12L12 19L5 12']);
  static const arrowUpRight = NanoIconData([r'M7 7h10v10', r'M7 17L17 7']);
  static const star = NanoIconData([
    r'M11.525 2.295a.53.53 0 0 1 .95 0l2.31 4.679a2.123 2.123 0 0 0 1.595 1.16l5.166.756a.53.53 0 0 1 .294.904l-3.736 3.638a2.123 2.123 0 0 0-.611 1.878l.882 5.14a.53.53 0 0 1-.771.56l-4.618-2.428a2.122 2.122 0 0 0-1.973 0L6.396 21.01a.53.53 0 0 1-.77-.56l.881-5.139a2.122 2.122 0 0 0-.611-1.879L2.16 9.795a.53.53 0 0 1 .294-.906l5.165-.755a2.122 2.122 0 0 0 1.597-1.16z',
  ]);
  static const trash = NanoIconData([
    r'M3 6h18',
    r'M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6',
    r'M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2',
    r'M10 11v6',
    r'M14 11v6',
  ]);
  static const copy = NanoIconData([
    r'M10 8H6a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-4',
    r'M12 2h6a2 2 0 0 1 2 2v6a2 2 0 0 1-2 2h-6a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2',
  ]);
  static const mail = NanoIconData([
    r'M4 4h16a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2',
    r'M22 7l-8.97 5.7a1.94 1.94 0 0 1-2.06 0L2 7',
  ]);
  static const user = NanoIconData([
    r'M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2',
    r'M12 3A4 4 0 1 0 12 11A4 4 0 1 0 12 3',
  ]);
  static const bell = NanoIconData([
    r'M10.268 21a2 2 0 0 0 3.464 0',
    r'M3.262 15.326A1 1 0 0 0 4 17h16a1 1 0 0 0 .74-1.673C19.41 13.956 18 12.499 18 8A6 6 0 0 0 6 8c0 4.499-1.411 5.956-2.738 7.326',
  ]);
  static const house = NanoIconData([
    r'M15 21v-8a1 1 0 0 0-1-1h-4a1 1 0 0 0-1 1v8',
    r'M3 10a2 2 0 0 1 .709-1.528l7-5.999a2 2 0 0 1 2.582 0l7 5.999A2 2 0 0 1 21 10v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z',
  ]);
  static const panelLeft = NanoIconData([
    r'M4 3h16a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2',
    r'M9 3v18',
  ]);
  static const sun = NanoIconData([
    r'M12 8A4 4 0 1 0 12 16A4 4 0 1 0 12 8',
    r'M12 2v2',
    r'M12 20v2',
    r'M4.93 4.93l1.41 1.41',
    r'M17.66 17.66l1.41 1.41',
    r'M2 12h2',
    r'M20 12h2',
    r'M6.34 17.66l-1.41 1.41',
    r'M19.07 4.93l-1.41 1.41',
  ]);
  static const moon = NanoIconData([r'M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z']);
  static const monitor = NanoIconData([
    r'M4 3h16a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2',
    r'M8 21h8',
    r'M12 17v4',
  ]);
  static const loaderCircle = NanoIconData([r'M21 12a9 9 0 1 1-6.219-8.56']);
  static const clock = NanoIconData([
    r'M12 2A10 10 0 1 0 12 22A10 10 0 1 0 12 2',
    r'M12 6v6l4 2',
  ]);
  static const smile = NanoIconData([
    r'M12 2A10 10 0 1 0 12 22A10 10 0 1 0 12 2',
    r'M8 14s1.5 2 4 2s4-2 4-2',
    r'M9 9h.01',
    r'M15 9h.01',
  ]);
  static const keyboard = NanoIconData([
    r'M4 6h16a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2',
    r'M6 10h.01',
    r'M10 10h.01',
    r'M14 10h.01',
    r'M18 10h.01',
    r'M7 14h10',
  ]);
  static const logOut = NanoIconData([
    r'M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4',
    r'M16 17l5-5-5-5',
    r'M21 12H9',
  ]);
  static const creditCard = NanoIconData([
    r'M4 5h16a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V7a2 2 0 0 1 2-2',
    r'M2 10h20',
  ]);
  static const shoppingBag = NanoIconData([
    r'M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4Z',
    r'M3 6h18',
    r'M16 10a4 4 0 0 1-8 0',
  ]);
  static const tag = NanoIconData([
    r'M12.586 2.586A2 2 0 0 0 11.172 2H4a2 2 0 0 0-2 2v7.172a2 2 0 0 0 .586 1.414l8.704 8.704a2.426 2.426 0 0 0 3.42 0l6.58-6.58a2.426 2.426 0 0 0 0-3.42z',
    r'M7.5 7.5h.01',
  ]);
  static const externalLink = NanoIconData([
    r'M15 3h6v6',
    r'M10 14L21 3',
    r'M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6',
  ]);
  static const refreshCw = NanoIconData([
    r'M3 12a9 9 0 0 1 9-9a9.75 9.75 0 0 1 6.74 2.74L21 8',
    r'M21 3v5h-5',
    r'M21 12a9 9 0 0 1-9 9a9.75 9.75 0 0 1-6.74-2.74L3 16',
    r'M8 16H3v5',
  ]);
  static const cornerDownLeft = NanoIconData([
    r'M20 4v7a4 4 0 0 1-4 4H4',
    r'M9 10L4 15L9 20',
  ]);
  static const zap = NanoIconData([
    r'M4 14a1 1 0 0 1-.78-1.63l9.9-10.2a.5.5 0 0 1 .86.46l-1.92 6.02A1 1 0 0 0 13 10h7a1 1 0 0 1 .78 1.63l-9.9 10.2a.5.5 0 0 1-.86-.46l1.92-6.02A1 1 0 0 0 11 14z',
  ]);
  static const gripVertical = NanoIconData([
    r'M9 5h.01',
    r'M9 12h.01',
    r'M9 19h.01',
    r'M15 5h.01',
    r'M15 12h.01',
    r'M15 19h.01',
  ]);
  static const image = NanoIconData([
    r'M4 3h16a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2',
    r'M9 7A2 2 0 1 0 9 11A2 2 0 1 0 9 7',
    r'M21 15l-3.086-3.086a2 2 0 0 0-2.828 0L6 21',
  ]);
  static const inbox = NanoIconData([
    r'M22 12h-6l-2 3h-4l-2-3H2',
    r'M5.45 5.11L2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.45-6.89A2 2 0 0 0 16.76 4H7.24a2 2 0 0 0-1.79 1.11z',
  ]);
  static const folder = NanoIconData([
    r'M20 20a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2Z',
  ]);
  static const calendar = NanoIconData([
    r'M8 2v4',
    r'M16 2v4',
    r'M4 4h16a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2',
    r'M3 10h18',
  ]);
  static const bold = NanoIconData([
    r'M6 12h9a4 4 0 0 1 0 8H7a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1h7a4 4 0 0 1 0 8',
  ]);
  static const italic = NanoIconData([r'M19 4h-9', r'M14 20H5', r'M15 4L9 20']);
  static const underline = NanoIconData([
    r'M6 4v6a6 6 0 0 0 12 0V4',
    r'M4 20h16',
  ]);
  static const sparkle = NanoIconData([
    r'M9.937 15.5A2 2 0 0 0 8.5 14.063l-6.135-1.582a.5.5 0 0 1 0-.962L8.5 9.936A2 2 0 0 0 9.937 8.5l1.582-6.135a.5.5 0 0 1 .963 0L14.063 8.5A2 2 0 0 0 15.5 9.937l6.135 1.581a.5.5 0 0 1 0 .964L15.5 14.063a2 2 0 0 0-1.437 1.437l-1.582 6.135a.5.5 0 0 1-.963 0z',
  ]);
  static const palette = NanoIconData([
    r'M12 22a10 10 0 1 1 10-10c0 1.7-1.3 3-3 3h-2.3a2 2 0 0 0-1.5 3.3c.3.4.5.8.5 1.2a2.5 2.5 0 0 1-2.5 2.5',
    r'M7 13.5h.01',
    r'M9.5 8.5h.01',
    r'M14.5 8.5h.01',
    r'M17 13.5h.01',
  ]);
}
