import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Rich hover preview — shadcn `Hover Card`: opens on hover after a delay
/// and stays open while the pointer moves onto the card itself.
class NanoHoverCard extends StatefulWidget {
  const NanoHoverCard({
    super.key,
    required this.child,
    required this.contentBuilder,
    this.placement = NanoPlacement.bottomStart,
    this.openDelay = const Duration(milliseconds: 150),
  });

  final Widget child;
  final WidgetBuilder contentBuilder;
  final NanoPlacement placement;
  final Duration openDelay;

  @override
  State<NanoHoverCard> createState() => _NanoHoverCardState();
}

class _NanoHoverCardState extends State<NanoHoverCard> with NanoOverlayHost {
  bool _insideTrigger = false;
  bool _insidePanel = false;
  Timer? _closeTimer;
  Timer? _openTimer;

  void _cancelClose() {
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  void _enterTrigger() {
    _insideTrigger = true;
    _cancelClose();
    if (isOverlayOpen) return;
    _openTimer?.cancel();
    _openTimer = Timer(widget.openDelay, () {
      if (mounted && !isOverlayOpen && _insideTrigger) _open();
    });
  }

  void _exitTrigger() {
    _insideTrigger = false;
    _scheduleClose();
  }

  void _open() {
    openOverlay(
      triggerContext: context,
      contentBuilder: (overlayContext) => MouseRegion(
        onEnter: (_) {
          _insidePanel = true;
          _cancelClose();
        },
        onExit: (_) {
          _insidePanel = false;
          _scheduleClose();
        },
        child: NanoSurfacePanel(
          minWidth: null,
          maxWidth: 360,
          child: Padding(
            padding: EdgeInsets.all(
              NanoTheme.of(overlayContext).spacing.insetControl,
            ),
            child: widget.contentBuilder(overlayContext),
          ),
        ),
      ),
      placement: widget.placement,
      offset: 8,
      ignorePointerBarrier: true,
      barrierDismissible: false,
    );
  }

  void _scheduleClose() {
    _cancelClose();
    _closeTimer = Timer(const Duration(milliseconds: 120), () {
      if (mounted && !_insideTrigger && !_insidePanel) closeOverlay();
    });
  }

  @override
  void dispose() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _enterTrigger(),
      onExit: (_) => _exitTrigger(),
      child: widget.child,
    );
  }
}
