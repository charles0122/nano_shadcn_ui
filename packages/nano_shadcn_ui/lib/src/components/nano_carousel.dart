import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Horizontal slide carousel — shadcn `Carousel` (embla): peeking slides,
/// edge arrows and a dot indicator.
class NanoCarousel extends StatefulWidget {
  const NanoCarousel({
    super.key,
    required this.children,
    this.viewportFraction = 0.9,
    this.showArrows = true,
    this.showDots = true,
    this.height = 240,
  });

  final List<Widget> children;

  /// Fraction of the viewport one slide occupies (< 1 gives the peek).
  final double viewportFraction;
  final bool showArrows;
  final bool showDots;
  final double height;

  @override
  State<NanoCarousel> createState() => _NanoCarouselState();
}

class _NanoCarouselState extends State<NanoCarousel> {
  late final PageController _controller = PageController(
    viewportFraction: widget.viewportFraction,
  );
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final target = (_page + delta).clamp(0, widget.children.length - 1);
    _controller.animateToPage(
      target,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    Widget arrow(NanoIconData icon, int delta, bool enabled) => NanoInteractive(
      onTap: enabled ? () => _go(delta) : null,
      enabled: enabled,
      builder: (context, states) {
        final hovered = states.contains(WidgetState.hovered);
        return Container(
          width: theme.size.avatarCompact,
          height: theme.size.avatarCompact,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colors.surface,
            border: Border.all(
              color: theme.colors.border,
              width: theme.borders.controlWidth,
            ),
            boxShadow: theme.elevation.raised,
          ),
          child: Center(
            child: NanoIcon(
              icon,
              size: theme.size.iconInline,
              color: enabled
                  ? (hovered
                        ? theme.colors.textPrimary
                        : theme.colors.textSecondary)
                  : theme.colors.textDisabled,
            ),
          ),
        );
      },
    );

    return SizedBox(
      height:
          widget.height +
          (widget.showDots ? theme.size.controlHeightCompact : 0),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView(
                  controller: _controller,
                  onPageChanged: (page) => setState(() => _page = page),
                  children: [
                    for (final child in widget.children)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: theme.spacing.stackDefault / 2,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            theme.radius.surfaceCard,
                          ),
                          child: child,
                        ),
                      ),
                  ],
                ),
                if (widget.showArrows && widget.children.length > 1) ...[
                  Positioned(
                    left: theme.spacing.stackDefault,
                    child: arrow(NanoIcons.chevronLeft, -1, _page > 0),
                  ),
                  Positioned(
                    right: theme.spacing.stackDefault,
                    child: arrow(
                      NanoIcons.chevronRight,
                      1,
                      _page < widget.children.length - 1,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (widget.showDots && widget.children.length > 1)
            Padding(
              padding: EdgeInsets.only(top: theme.spacing.stackDefault / 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < widget.children.length; i++)
                    GestureDetector(
                      onTap: () => _controller.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      ),
                      child: Container(
                        width: theme.size.indicatorDot,
                        height: theme.size.indicatorDot,
                        margin: EdgeInsets.symmetric(
                          horizontal: theme.spacing.stackDefault / 4,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _page
                              ? theme.colors.textPrimary
                              : theme.colors.border,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoCarouselSpec = NanoComponentSpec(
  name: 'NanoCarousel',
  description: 'Paged horizontal carousel with arrows and dots.',
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
