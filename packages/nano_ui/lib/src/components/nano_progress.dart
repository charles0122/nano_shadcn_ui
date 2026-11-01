import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../foundation/nano_icons.dart';
import '../registry/nano_registry.dart';
import '../theme/nano_theme.dart';

/// Spinning loader arc — shadcn `Spinner` (lucide loader-circle), sized by
/// `size.icon.*` tokens and colored like an icon.
class NanoSpinner extends StatefulWidget {
  const NanoSpinner({super.key, this.size, this.color});

  final double? size;
  final Color? color;

  @override
  State<NanoSpinner> createState() => _NanoSpinnerState();
}

class _NanoSpinnerState extends State<NanoSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final size = widget.size ?? theme.size.iconDefault;
    final color =
        widget.color ??
        NanoIconTheme.maybeColorOf(context) ??
        theme.colors.textSecondary;
    return RotationTransition(
      turns: _controller,
      child: NanoIcon(NanoIcons.loaderCircle, size: size, color: color),
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoSpinnerSpec = NanoComponentSpec(
  name: 'NanoSpinner',
  description: 'Spinning loading indicator.',
  propsSchema: {
    'size': {'type': 'number'},
  },
  builder: _buildSpinnerFromNode,
);

Widget _buildSpinnerFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  return NanoSpinner(size: (node.props['size'] as num?)?.toDouble());
}

/// A small filled dot used by status rows and step markers.
class NanoDot extends StatelessWidget {
  const NanoDot({super.key, this.color, this.size});

  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Container(
      width: size ?? theme.size.indicatorDot,
      height: size ?? theme.size.indicatorDot,
      decoration: BoxDecoration(
        color: color ?? theme.colors.textSecondary,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Simple progress bar track+fill pair shared by [NanoProgress] variants.
class NanoProgressTrack extends StatelessWidget {
  const NanoProgressTrack({
    super.key,
    required this.value,
    this.height,
    this.fillColor,
    this.trackColor,
  });

  /// 0..1; null renders an indeterminate sliding bar.
  final double? value;
  final double? height;
  final Color? fillColor;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final track = trackColor ?? theme.colors.surfaceSubtle;
    final fill = fillColor ?? theme.colors.actionPrimaryBackground;
    final h = height ?? theme.size.indicatorDot;

    final bar = Container(
      height: h,
      decoration: BoxDecoration(
        color: track,
        borderRadius: BorderRadius.circular(theme.radius.pill),
      ),
      clipBehavior: Clip.antiAlias,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: value == null
            ? _IndeterminateBar(color: fill)
            : AnimatedFractionallySizedBox(
                duration: theme.motion.durationBase,
                curve: theme.motion.curveStandard,
                widthFactor: value!.clamp(0.0, 1.0),
                heightFactor: 1,
                alignment: AlignmentDirectional.centerStart,
                child: ColoredBox(color: fill),
              ),
      ),
    );
    return Semantics(
      value: value == null ? null : '${(value! * 100).round()}%',
      child: bar,
    );
  }
}

class _IndeterminateBar extends StatefulWidget {
  const _IndeterminateBar({required this.color});

  final Color color;

  @override
  State<_IndeterminateBar> createState() => _IndeterminateBarState();
}

class _IndeterminateBarState extends State<_IndeterminateBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        return LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth * 0.4;
            final x = (constraints.maxWidth + w) * (t * 2 - 0.5) - w;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: math.min(math.max(x, -w), constraints.maxWidth),
                  width: w,
                  top: 0,
                  bottom: 0,
                  child: ColoredBox(color: widget.color),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Determinate progress bar — shadcn `Progress`: `indicator.dot`-height
/// track in the muted surface with a primary fill.
class NanoProgress extends StatelessWidget {
  const NanoProgress({super.key, required this.value});

  /// 0..1.
  final double value;

  @override
  Widget build(BuildContext context) => NanoProgressTrack(value: value);
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoProgressSpec = NanoComponentSpec(
  name: 'NanoProgress',
  description: 'Determinate progress bar (value 0..1).',
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
  return NanoProgress(
    value: ((node.props['value'] as num?)?.toDouble() ?? 0).clamp(0.0, 1.0),
  );
}
