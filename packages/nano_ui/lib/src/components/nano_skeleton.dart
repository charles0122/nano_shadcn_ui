import 'package:flutter/widgets.dart';

import '../registry/nano_registry.dart';
import '../theme/nano_theme.dart';

/// Loading placeholder — shadcn `Skeleton`: a rounded block of
/// `text.primary @ 10%` pulsing between 50% and 100% opacity.
class NanoSkeleton extends StatelessWidget {
  const NanoSkeleton({
    super.key,
    this.width,
    this.height,
    this.radius,
    this.child,
  });

  final double? width;
  final double? height;

  /// Defaults to the card radius.
  final double? radius;

  /// When given, wraps the child's shape instead of a plain box.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final base = theme.colors.textPrimary.withAlpha(26);
    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(radius ?? theme.radius.surfaceCard),
      ),
    );
    return _Pulse(
      child: child == null
          ? box
          : Stack(
              alignment: Alignment.center,
              fit: StackFit.passthrough,
              children: [box, child!],
            ),
    );
  }
}

class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});

  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(
        begin: 0.45,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoSkeletonSpec = NanoComponentSpec(
  name: 'NanoSkeleton',
  description: 'Pulsing loading placeholder box.',
  propsSchema: {
    'width': {'type': 'number'},
    'height': {'type': 'number'},
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  final theme = NanoTheme.of(context);
  return NanoSkeleton(
    width: (node.props['width'] as num?)?.toDouble() ?? 120,
    height:
        (node.props['height'] as num?)?.toDouble() ??
        theme.size.controlHeightDefault,
  );
}
