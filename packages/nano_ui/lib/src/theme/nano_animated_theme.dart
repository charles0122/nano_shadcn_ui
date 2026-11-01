import 'package:flutter/widgets.dart';

import 'nano_theme.dart';
import 'nano_theme_data.dart';

/// Implicitly animates [NanoThemeData] changes: on every data switch all
/// token values are interpolated frame by frame (colors, text styles,
/// spacing, radii, shadows…), so theme transitions morph instead of snap.
///
/// Duration and curve default to the target theme's own motion tokens
/// (`motion.durationSlow` + `motion.curveStandard`); pass [duration] /
/// [curve] to override. Interrupting a running transition starts from the
/// currently displayed values, so rapid chip-tapping stays smooth.
class NanoAnimatedTheme extends StatefulWidget {
  const NanoAnimatedTheme({
    super.key,
    required this.data,
    this.duration,
    this.curve,
    required this.child,
  });

  final NanoThemeData data;
  final Duration? duration;
  final Curve? curve;
  final Widget child;

  @override
  State<NanoAnimatedTheme> createState() => _NanoAnimatedThemeState();
}

class _NanoAnimatedThemeState extends State<NanoAnimatedTheme>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration(),
  );

  /// What the tree is showing right now (the interpolated value mid-flight).
  late NanoThemeData _display = widget.data;
  NanoThemeData? _from;
  NanoThemeData? _to;

  Duration _duration() => widget.duration ?? widget.data.motion.durationSlow;

  @override
  void didUpdateWidget(covariant NanoAnimatedTheme oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data && widget.data != _display) {
      _from = _display;
      _to = widget.data;
      _controller
        ..duration = _duration()
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_from != null) {
          final curve = widget.curve ?? widget.data.motion.curveStandard;
          final t = curve.transform(_controller.value);
          _display = NanoThemeData.lerp(_from!, _to!, t);
        }
        return NanoTheme(data: _display, child: child!);
      },
      child: widget.child,
    );
  }
}
