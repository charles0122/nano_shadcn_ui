import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Scroll container with a token-styled scrollbar — shadcn `Scroll Area`
/// (Radix ScrollArea): an always-thin overlay thumb in the border color,
/// draggable and hidden when content fits.
class NanoScrollArea extends StatelessWidget {
  const NanoScrollArea({
    super.key,
    required this.child,
    this.height,
    this.axis = Axis.vertical,
  });

  final Widget child;
  final double? height;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ScrollConfiguration(
        behavior: const _NoScrollbarBehavior(),
        child: _ScrollAreaBody(axis: axis, child: child),
      ),
    );
  }
}

class _NoScrollbarBehavior extends ScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}

class _ScrollAreaBody extends StatefulWidget {
  const _ScrollAreaBody({required this.axis, required this.child});

  final Axis axis;
  final Widget child;

  @override
  State<_ScrollAreaBody> createState() => _ScrollAreaBodyState();
}

class _ScrollAreaBodyState extends State<_ScrollAreaBody> {
  final ScrollController _controller = ScrollController();
  bool _hovering = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final themeData = theme;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final canScroll =
              _controller.hasClients &&
              (_controller.position.maxScrollExtent > 0);
          return Stack(
            children: [
              SingleChildScrollView(
                controller: _controller,
                scrollDirection: widget.axis,
                child: widget.child,
              ),
              if (canScroll &&
                  (_hovering || _controller.position.isScrollingNotifier.value))
                Positioned(
                  right: 2,
                  top: 2,
                  bottom: 2,
                  child: _ScrollbarThumb(
                    controller: _controller,
                    theme: themeData,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ScrollbarThumb extends StatefulWidget {
  const _ScrollbarThumb({required this.controller, required this.theme});

  final ScrollController controller;
  final NanoThemeData theme;

  @override
  State<_ScrollbarThumb> createState() => _ScrollbarThumbState();
}

class _ScrollbarThumbState extends State<_ScrollbarThumb> {
  double _dragStartOffset = 0;
  double _dragStartPixels = 0;

  double get _viewport => widget.controller.position.viewportDimension;
  double get _max => widget.controller.position.maxScrollExtent;

  @override
  Widget build(BuildContext context) {
    if (_max <= 0) return const SizedBox.shrink();
    final theme = widget.theme;
    final thumbFraction = (_viewport / (_viewport + _max)).clamp(0.15, 1.0);
    final progress = (widget.controller.offset / _max).clamp(0.0, 1.0);
    final thumbHeight = _viewport * thumbFraction;
    final top = (_viewport - thumbHeight) * progress;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: (d) {
        _dragStartOffset = widget.controller.offset;
        _dragStartPixels = d.globalPosition.dy;
      },
      onVerticalDragUpdate: (d) {
        final travel = _viewport - thumbHeight;
        if (travel <= 0) return;
        widget.controller.jumpTo(
          (_dragStartOffset +
                  (d.globalPosition.dy - _dragStartPixels) / travel * _max)
              .clamp(0.0, _max),
        );
      },
      child: Align(
        alignment: Alignment(0, top <= 0 ? -1 : 0),
        child: Padding(
          padding: EdgeInsets.only(top: top),
          child: Container(
            width: theme.borders.controlFocusWidth + 4,
            height: thumbHeight,
            decoration: BoxDecoration(
              color: theme.colors.borderStrong.withAlpha(160),
              borderRadius: BorderRadius.circular(theme.radius.pill),
            ),
          ),
        ),
      ),
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoScrollAreaSpec = NanoComponentSpec(
  name: 'NanoScrollArea',
  description: 'Scroll container with a themed overlay scrollbar.',
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
