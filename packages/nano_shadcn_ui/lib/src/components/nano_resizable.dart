import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Draggable split panes — shadcn `Resizable` (react-resizable-panels):
/// two panels with a grip handle; drag adjusts the ratio, clamped to
/// [minRatio]/[maxRatio].
class NanoResizable extends StatefulWidget {
  const NanoResizable({
    super.key,
    required this.first,
    required this.second,
    this.initialRatio = 0.5,
    this.minRatio = 0.15,
    this.maxRatio = 0.85,
    this.direction = Axis.horizontal,
    this.height,
  });

  final Widget first;
  final Widget second;
  final double initialRatio;
  final double minRatio;
  final double maxRatio;
  final Axis direction;
  final double? height;

  @override
  State<NanoResizable> createState() => _NanoResizableState();
}

class _NanoResizableState extends State<NanoResizable> {
  late double _ratio = widget.initialRatio;
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final horizontal = widget.direction == Axis.horizontal;

    Widget pane(Widget child, double flex) => Expanded(
      flex: (flex * 1000).round(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(theme.radius.controlInput),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colors.surfaceSubtle,
            borderRadius: BorderRadius.circular(theme.radius.controlInput),
            border: Border.all(
              color: theme.colors.border,
              width: theme.borders.controlWidth,
            ),
          ),
          child: child,
        ),
      ),
    );

    Widget handle() => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: horizontal
          ? (d) => setState(
              () => _ratio =
                  (_ratio +
                          d.delta.dx /
                              (horizontal
                                  ? (context.size?.width ?? 1)
                                  : (context.size?.height ?? 1)))
                      .clamp(widget.minRatio, widget.maxRatio),
            )
          : null,
      onVerticalDragUpdate: horizontal
          ? null
          : (d) => setState(
              () => _ratio = (_ratio + d.delta.dy / (context.size?.height ?? 1))
                  .clamp(widget.minRatio, widget.maxRatio),
            ),
      onHorizontalDragStart: horizontal
          ? (_) => setState(() => _dragging = true)
          : null,
      onHorizontalDragEnd: horizontal
          ? (_) => setState(() => _dragging = false)
          : null,
      onVerticalDragStart: horizontal
          ? null
          : (_) => setState(() => _dragging = true),
      onVerticalDragEnd: horizontal
          ? null
          : (_) => setState(() => _dragging = false),
      child: MouseRegion(
        cursor: horizontal
            ? SystemMouseCursors.resizeColumn
            : SystemMouseCursors.resizeRow,
        // Half the touch-minimum as the hit area; the visual is a plain
        // centered divider bar — a grip glyph overflowing the strip read
        // like stray text.
        child: SizedBox(
          width: horizontal
              ? theme.size.targetPointerMinimum / 2
              : double.infinity,
          height: horizontal
              ? double.infinity
              : theme.size.targetPointerMinimum / 2,
          child: Center(
            child: AnimatedContainer(
              duration: theme.motion.durationFast,
              width: horizontal
                  ? theme.borders.controlFocusWidth + 2
                  : theme.size.iconInline,
              height: horizontal
                  ? theme.size.iconInline
                  : theme.borders.controlFocusWidth + 2,
              decoration: BoxDecoration(
                color: _dragging
                    ? theme.colors.borderStrong
                    : theme.colors.border,
                borderRadius: BorderRadius.circular(theme.radius.pill),
              ),
            ),
          ),
        ),
      ),
    );

    return SizedBox(
      height: widget.height,
      child: Row(
        children: [
          pane(widget.first, _ratio),
          handle(),
          pane(widget.second, 1 - _ratio),
        ],
      ),
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoResizableSpec = NanoComponentSpec(
  name: 'NanoResizable',
  description: 'Two resizable panes with a drag handle.',
  propsSchema: {},
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  return const SizedBox.shrink();
}
