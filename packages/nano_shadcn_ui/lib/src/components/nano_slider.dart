import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Drag slider — shadcn `Slider`: `indicator.dot`-height rounded track with a
/// primary filled range and 16px thumbs. Supports single-value and range
/// dragging, plus keyboard arrows when a thumb has focus.
class NanoSlider extends StatefulWidget {
  const NanoSlider({
    super.key,
    required this.values,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.enabled = true,
  });

  /// One value for a single thumb, two for a range slider.
  final List<double> values;
  final ValueChanged<List<double>> onChanged;
  final double min;
  final double max;

  /// Snap points between [min] and [max].
  final int? divisions;
  final bool enabled;

  @override
  State<NanoSlider> createState() => _NanoSliderState();
}

class _NanoSliderState extends State<NanoSlider> {
  int? _activeThumb;

  double _norm(double v) =>
      ((v - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);

  double _denorm(double t) => widget.min + t * (widget.max - widget.min);

  double _snap(double v) {
    if (widget.divisions == null || widget.divisions! < 1) return v;
    final step = (widget.max - widget.min) / widget.divisions!;
    return (widget.min + ((v - widget.min) / step).roundToDouble() * step)
        .clamp(widget.min, widget.max);
  }

  void _update(double t) {
    final raw = _denorm(t.clamp(0.0, 1.0));
    final values = List.of(widget.values);
    final i = (_activeThumb ?? _nearestThumb(t)).clamp(0, values.length - 1);
    values[i] = _snap(raw);
    // Keep range ordered.
    if (values.length == 2) {
      if (i == 0 && values[0] > values[1]) values[0] = values[1];
      if (i == 1 && values[1] < values[0]) values[1] = values[0];
    }
    widget.onChanged(values);
  }

  int _nearestThumb(double t) {
    var best = 0;
    var bestDist = double.infinity;
    for (var i = 0; i < widget.values.length; i++) {
      final d = (_norm(widget.values[i]) - t).abs();
      if (d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final thumb = theme.size.iconInline;
    final hasError = NanoFormFieldScope.maybeOf(context)?.hasError ?? false;
    final fillColor = hasError ? theme.colors.danger.foreground : null;

    return Semantics(
      slider: true,
      value: widget.values.map((v) => v.toStringAsFixed(2)).join(' – '),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth - thumb;
          double normToPx(double t) => thumb / 2 + t * trackWidth;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: widget.enabled
                ? (d) {
                    setState(
                      () => _activeThumb = _nearestThumb(
                        ((d.localPosition.dx - thumb / 2) / trackWidth),
                      ),
                    );
                    _update((d.localPosition.dx - thumb / 2) / trackWidth);
                  }
                : null,
            onPanStart: widget.enabled
                ? (d) => setState(
                    () => _activeThumb = _nearestThumb(
                      (d.localPosition.dx - thumb / 2) / trackWidth,
                    ),
                  )
                : null,
            onPanUpdate: widget.enabled
                ? (d) => _update((d.localPosition.dx - thumb / 2) / trackWidth)
                : null,
            onPanEnd: (_) => setState(() => _activeThumb = null),
            child: SizedBox(
              height: theme.size.targetPointerMinimum / 2,
              child: Center(
                child: SizedBox(
                  height: thumb,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Track + filled range.
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.colors.surfaceSubtle,
                            borderRadius: BorderRadius.circular(
                              theme.radius.pill,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: widget.values.length == 2
                            ? normToPx(_norm(widget.values.first))
                            : 0,
                        child: Container(
                          height: 6,
                          width: widget.values.length == 2
                              ? (normToPx(_norm(widget.values.last)) -
                                    normToPx(_norm(widget.values.first)))
                              : normToPx(_norm(widget.values.last)),
                          decoration: BoxDecoration(
                            color:
                                fillColor ??
                                theme.colors.actionPrimaryBackground,
                            borderRadius: BorderRadius.circular(
                              theme.radius.pill,
                            ),
                          ),
                        ),
                      ),
                      // Thumbs.
                      for (var i = 0; i < widget.values.length; i++)
                        Positioned(
                          left: normToPx(_norm(widget.values[i])) - thumb / 2,
                          child: _Thumb(
                            active: _activeThumb == i,
                            dragging: _activeThumb != null && _activeThumb == i,
                            fillColor: fillColor,
                            enabled: widget.enabled,
                            onDrag: (dx) => _update(
                              ((dx + thumb / 2) - thumb / 2) / trackWidth,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.active,
    required this.dragging,
    required this.fillColor,
    required this.enabled,
    required this.onDrag,
  });

  final bool active;
  final bool dragging;
  final Color? fillColor;
  final bool enabled;
  final ValueChanged<double> onDrag;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final size = theme.size.iconInline;
    return GestureDetector(
      onHorizontalDragUpdate: enabled ? (d) => onDrag(d.delta.dx) : null,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.grab : MouseCursor.defer,
        child: AnimatedContainer(
          duration: theme.motion.durationFast,
          width: size,
          height: size,
          transform: Matrix4.identity()
            ..scaleByDouble(
              dragging ? 1.15 : 1.0,
              dragging ? 1.15 : 1.0,
              dragging ? 1.15 : 1.0,
              1.0,
            ),
          decoration: BoxDecoration(
            color: theme.colors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: fillColor ?? theme.colors.actionPrimaryBackground,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colors.shadow.withAlpha(
                  (active || dragging ? 60 : 40),
                ),
                blurRadius: active || dragging ? 6 : 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoSliderSpec = NanoComponentSpec(
  name: 'NanoSlider',
  description: 'Slider control; values are owned by the host app.',
  propsSchema: {
    'value': {'type': 'number'},
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  return NanoSlider(
    values: [(node.props['value'] as num?)?.toDouble() ?? 0],
    onChanged: (_) {},
  );
}
