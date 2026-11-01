import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// One data point of a chart series.
class NanoChartPoint {
  const NanoChartPoint(this.label, this.value);

  final String label;
  final double value;
}

/// A named series with its own token-role color.
class NanoChartSeries {
  const NanoChartSeries(this.name, this.points, {this.color});

  final String name;
  final List<NanoChartPoint> points;

  /// Defaults to `color.action.primary.background`; override with any
  /// semantic color for multi-series charts.
  final Color? color;
}

/// Shared chart chrome: hairline grid, axis labels, rounded geometry —
/// the shadcn chart look drawn from tokens.
abstract class NanoChartBase extends StatelessWidget {
  const NanoChartBase({
    super.key,
    required this.series,
    this.height = 240,
    this.maxValue,
  });

  final List<NanoChartSeries> series;
  final double height;
  final double? maxValue;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: CustomPaint(
              painter: _GridPainter(theme: theme),
              child: Padding(
                padding: EdgeInsets.only(top: theme.spacing.stackDefault),
                child: paintPlot(context),
              ),
            ),
          ),
          SizedBox(height: theme.spacing.stackDefault),
          Row(
            children: [
              for (final label in series.first.points)
                Expanded(
                  child: Center(
                    child: NanoText(
                      label.label,
                      role: NanoTextRole.labelMetadata,
                    ),
                  ),
                ),
            ],
          ),
          if (series.length > 1) ...[
            SizedBox(height: theme.spacing.stackDefault / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final s in series) ...[
                  Container(
                    width: theme.size.indicatorDot,
                    height: theme.size.indicatorDot,
                    margin: EdgeInsets.only(
                      right: theme.spacing.inlineIconLabel / 2,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: s.color ?? theme.colors.actionPrimaryBackground,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: theme.spacing.inlineActions,
                    ),
                    child: NanoText(s.name, role: NanoTextRole.labelMetadata),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// The plot area above the axis labels.
  Widget paintPlot(BuildContext context);
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.theme});

  final NanoThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.colors.border
      ..strokeWidth = theme.borders.dividerWidth;
    const lines = 5;
    for (var i = 0; i < lines; i++) {
      final y = size.height * i / (lines - 1);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.theme != theme;
}

/// Rounded bar chart — shadcn `Bar Chart` (recharts default look).
class NanoBarChart extends NanoChartBase {
  const NanoBarChart({
    super.key,
    required super.series,
    super.height,
    super.maxValue,
  });

  @override
  Widget paintPlot(BuildContext context) {
    final theme = NanoTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final max =
            this.maxValue ??
            series.fold<double>(
              0,
              (m, s) => s.points.fold(0, (m2, p) => math.max(m2, p.value)),
            );
        final slot =
            constraints.maxWidth / math.max(1, series.first.points.length);
        final barWidth = math.min(slot * 0.55, theme.size.iconDecorative);
        final painter = _BarPainter(
          series: series,
          max: max <= 0 ? 1 : max,
          slot: slot,
          barWidth: barWidth,
          theme: theme,
        );
        return CustomPaint(size: Size.infinite, painter: painter);
      },
    );
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.series,
    required this.max,
    required this.slot,
    required this.barWidth,
    required this.theme,
  });

  final List<NanoChartSeries> series;
  final double max;
  final double slot;
  final double barWidth;
  final NanoThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(theme.radius.controlDefault / 2);
    for (var si = 0; si < series.length; si++) {
      final s = series[si];
      final paint = Paint()
        ..color = s.color ?? theme.colors.actionPrimaryBackground;
      final count = s.points.length;
      final groupOffset = (slot - barWidth * count) / 2;
      for (var i = 0; i < count; i++) {
        final h = (s.points[i].value / max) * size.height;
        final x = i * slot + groupOffset + si * barWidth;
        final rect = RRect.fromRectAndCorners(
          Rect.fromLTWH(x, size.height - h, barWidth - 2, math.max(h, 2)),
          topLeft: radius,
          topRight: radius,
        );
        canvas.drawRRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.series != series || old.max != max || old.slot != slot;
}

/// Line chart with dot markers — shadcn `Line Chart`.
class NanoLineChart extends NanoChartBase {
  const NanoLineChart({
    super.key,
    required super.series,
    super.height,
    super.maxValue,
  });

  @override
  Widget paintPlot(BuildContext context) {
    final theme = NanoTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final max =
            this.maxValue ??
            series.fold<double>(
              0,
              (m, s) => s.points.fold(0, (m2, p) => math.max(m2, p.value)),
            );
        return CustomPaint(
          size: Size.infinite,
          painter: _LinePainter(
            series: series,
            max: max <= 0 ? 1 : max,
            theme: theme,
          ),
        );
      },
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({required this.series, required this.max, required this.theme});

  final List<NanoChartSeries> series;
  final double max;
  final NanoThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    final dot = theme.size.indicatorDot.toDouble();
    for (final s in series) {
      final color = s.color ?? theme.colors.actionPrimaryBackground;
      final n = s.points.length;
      final path = Path();
      for (var i = 0; i < n; i++) {
        final x = n == 1 ? 0.0 : size.width * i / (n - 1);
        final y = size.height - (s.points[i].value / max) * size.height;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = theme.borders.controlFocusWidth
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
      for (var i = 0; i < n; i++) {
        final x = n == 1 ? 0.0 : size.width * i / (n - 1);
        final y = size.height - (s.points[i].value / max) * size.height;
        canvas.drawCircle(Offset(x, y), dot / 2, Paint()..color = color);
      }
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.series != series || old.max != max;
}

/// Area chart = line chart with a translucent fill — shadcn `Area Chart`.
class NanoAreaChart extends NanoChartBase {
  const NanoAreaChart({
    super.key,
    required super.series,
    super.height,
    super.maxValue,
  });

  @override
  Widget paintPlot(BuildContext context) {
    final theme = NanoTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final max =
            this.maxValue ??
            series.fold<double>(
              0,
              (m, s) => s.points.fold(0, (m2, p) => math.max(m2, p.value)),
            );
        return CustomPaint(
          size: Size.infinite,
          painter: _AreaPainter(
            series: series,
            max: max <= 0 ? 1 : max,
            theme: theme,
          ),
        );
      },
    );
  }
}

class _AreaPainter extends CustomPainter {
  _AreaPainter({required this.series, required this.max, required this.theme});

  final List<NanoChartSeries> series;
  final double max;
  final NanoThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in series) {
      final color = s.color ?? theme.colors.actionPrimaryBackground;
      final n = s.points.length;
      final path = Path();
      for (var i = 0; i < n; i++) {
        final x = n == 1 ? 0.0 : size.width * i / (n - 1);
        final y = size.height - (s.points[i].value / max) * size.height;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      final fill = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(fill, Paint()..color = color.withAlpha(38));
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = theme.borders.controlFocusWidth,
      );
    }
  }

  @override
  bool shouldRepaint(_AreaPainter old) =>
      old.series != series || old.max != max;
}
