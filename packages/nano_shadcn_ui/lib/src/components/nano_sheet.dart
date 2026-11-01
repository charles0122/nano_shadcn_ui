import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Side panel — shadcn `Sheet`: slides in from a screen edge over a scrim;
/// Escape and scrim taps dismiss. Drag the panel to fling it closed with
/// [NanoSheetDraggable] (the drawer recipe).
class NanoSheet {
  NanoSheet._();

  static NanoOverlayController show(
    BuildContext context, {
    required WidgetBuilder builder,
    NanoOverlayVariant side = NanoOverlayVariant.sheetEnd,
    double? width,
    bool dismissible = true,
  }) {
    assert(
      side == NanoOverlayVariant.sheetStart ||
          side == NanoOverlayVariant.sheetEnd ||
          side == NanoOverlayVariant.sheetBottom,
      'side must be a sheet variant',
    );
    return showNanoOverlay(
      context,
      variant: side,
      barrierDismissible: dismissible,
      contentSize: Size(width ?? 400, double.infinity),
      builder: builder,
    );
  }
}

/// Panel chrome for sheet content: full-height surface with the dialog
/// radius on the open edge, inset padding and an optional drag handle.
class NanoSheetPanel extends StatelessWidget {
  const NanoSheetPanel({
    super.key,
    required this.child,
    this.onClose,
    this.side = NanoOverlayVariant.sheetEnd,
    this.header,
  });

  final Widget child;
  final VoidCallback? onClose;

  /// Which edge the sheet slides from — rounds the open-side corners.
  final NanoOverlayVariant side;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final isEnd = side == NanoOverlayVariant.sheetEnd;
    final radius = theme.radius.surfaceDialog;
    return Container(
      height: side == NanoOverlayVariant.sheetBottom ? null : double.infinity,
      decoration: BoxDecoration(
        color: theme.colors.surface,
        border: Border.all(
          color: theme.colors.border,
          width: theme.borders.controlWidth,
        ),
        borderRadius: side == NanoOverlayVariant.sheetBottom
            ? BorderRadius.vertical(top: Radius.circular(radius))
            : BorderRadius.horizontal(
                left: isEnd ? Radius.circular(radius) : Radius.zero,
                right: isEnd ? Radius.zero : Radius.circular(radius),
              ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (side == NanoOverlayVariant.sheetBottom)
            Center(
              child: Container(
                width: theme.size.iconDefault * 2,
                height: theme.borders.controlFocusWidth,
                margin: EdgeInsets.symmetric(
                  vertical: theme.spacing.insetControl / 2,
                ),
                decoration: BoxDecoration(
                  color: theme.colors.borderStrong,
                  borderRadius: BorderRadius.circular(theme.radius.pill),
                ),
              ),
            ),
          if (header != null)
            Padding(
              padding: EdgeInsets.all(theme.spacing.insetCard),
              child: header!,
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(theme.spacing.insetCard),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// Drag-to-dismiss wrapper for sheet panels — the shadcn drawer (vaul)
/// gesture: drag along the slide axis and release past a threshold.
class NanoSheetDraggable extends StatelessWidget {
  const NanoSheetDraggable({
    super.key,
    required this.child,
    required this.axis,
    required this.negative,
    required this.onDismiss,
  });

  final Widget child;
  final Axis axis;

  /// True when the panel sits at the negative edge (start/top).
  final bool negative;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    void maybeClose(DragEndDetails d) {
      final v = axis == Axis.horizontal
          ? d.velocity.pixelsPerSecond.dx
          : d.velocity.pixelsPerSecond.dy;
      final outward = negative ? v < -600 : v > 600;
      if (outward) onDismiss();
    }

    return axis == Axis.horizontal
        ? GestureDetector(onHorizontalDragEnd: maybeClose, child: child)
        : GestureDetector(onVerticalDragEnd: maybeClose, child: child);
  }
}
