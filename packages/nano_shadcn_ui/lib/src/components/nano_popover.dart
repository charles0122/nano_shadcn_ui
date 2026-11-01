import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Generic popover — shadcn `Popover`: the [child] trigger opens an anchored
/// surface panel with arbitrary content below (flipping upward when tight).
class NanoPopover extends StatefulWidget {
  const NanoPopover({
    super.key,
    required this.child,
    required this.contentBuilder,
    this.placement = NanoPlacement.bottomStart,
  });

  final Widget child;
  final WidgetBuilder contentBuilder;
  final NanoPlacement placement;

  @override
  State<NanoPopover> createState() => _NanoPopoverState();
}

class _NanoPopoverState extends State<NanoPopover> with NanoOverlayHost {
  void _toggle() {
    if (isOverlayOpen) {
      closeOverlay();
      return;
    }
    openOverlay(
      triggerContext: context,
      contentBuilder: (overlayContext) => NanoSurfacePanel(
        minWidth: null,
        child: Padding(
          padding: EdgeInsets.all(
            NanoTheme.of(overlayContext).spacing.insetControl,
          ),
          child: widget.contentBuilder(overlayContext),
        ),
      ),
      placement: widget.placement,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: widget.child,
    );
  }
}

/// Hover tooltip — shadcn `Tooltip`: inverted surface
/// (`action.primary.background` fill, `action.primary.foreground` text),
/// opens after a short delay and never blocks the pointer.
class NanoTooltip extends StatefulWidget {
  const NanoTooltip({
    super.key,
    required this.message,
    required this.child,
    this.placement = NanoPlacement.topCenter,
    this.delay = const Duration(milliseconds: 300),
  });

  final String message;
  final Widget child;
  final NanoPlacement placement;
  final Duration delay;

  @override
  State<NanoTooltip> createState() => _NanoTooltipState();
}

class _NanoTooltipState extends State<NanoTooltip> with NanoOverlayHost {
  bool _inside = false;

  void _enter() {
    _inside = true;
    if (isOverlayOpen) return;
    Future.delayed(widget.delay, () {
      if (!_inside || isOverlayOpen || !mounted) return;
      openOverlay(
        triggerContext: context,
        contentBuilder: (overlayContext) {
          final theme = NanoTheme.of(overlayContext);
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing.insetControl,
              vertical: theme.spacing.insetControl / 2,
            ),
            decoration: BoxDecoration(
              color: theme.colors.actionPrimaryBackground,
              borderRadius: BorderRadius.circular(
                theme.radius.controlDefault / 2,
              ),
              boxShadow: theme.elevation.floating,
            ),
            child: NanoText(
              widget.message,
              role: NanoTextRole.body,
              color: theme.colors.actionPrimaryForeground,
            ),
          );
        },
        placement: widget.placement,
        offset: 6,
        ignorePointerBarrier: true,
        barrierDismissible: false,
      );
    });
  }

  void _exit() {
    _inside = false;
    closeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _enter(),
      onExit: (_) => _exit(),
      child: widget.child,
    );
  }
}
