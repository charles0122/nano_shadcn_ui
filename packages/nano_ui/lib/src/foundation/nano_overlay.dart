import 'dart:math' as math;

import 'package:flutter/services.dart'
    show HardwareKeyboard, KeyDownEvent, KeyRepeatEvent, LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import '../theme/nano_theme.dart';

/// Where an anchored overlay sits relative to its trigger. Vertical flipping
/// happens automatically when there is no room on the preferred side.
enum NanoPlacement {
  bottomStart,
  bottomEnd,
  bottomCenter,
  topStart,
  topEnd,
  topCenter,
}

/// Which modal shape an overlay takes.
enum NanoOverlayVariant {
  /// Floating panel anchored to a trigger rect (popover, menu, tooltip).
  anchored,

  /// Centered dialog with a scrim.
  dialog,

  /// Full-height side panel sliding in from the start edge.
  sheetStart,

  /// Full-height side panel sliding in from the end edge.
  sheetEnd,

  /// Full-width panel sliding up from the bottom edge.
  sheetBottom,
}

/// Owns one open overlay. Open it with [showNanoOverlay]; widgets inside the
/// overlay reach the controller through [NanoOverlayScope.of] to dismiss it.
class NanoOverlayController {
  NanoOverlayController._(this._scopeNode);

  late final OverlayEntry _entry;
  final FocusScopeNode _scopeNode;

  bool _isOpen = true;
  bool get isOpen => _isOpen;

  void close() {
    if (!_isOpen) return;
    _isOpen = false;
    _entry.remove();
  }

  /// Moves focus to the next focusable inside the overlay, wrapping around.
  void focusNext() {
    if (!_scopeNode.nextFocus()) _scopeNode.requestFocus();
  }

  /// Moves focus to the previous focusable inside the overlay, wrapping.
  void focusPrevious() {
    if (!_scopeNode.previousFocus()) _scopeNode.requestFocus();
  }
}

/// Reach the enclosing overlay's controller (e.g. to close a menu when an
/// item is activated).
class NanoOverlayScope extends InheritedWidget {
  const NanoOverlayScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final NanoOverlayController controller;

  static NanoOverlayController? of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<NanoOverlayScope>()
      ?.controller;

  @override
  bool updateShouldNotify(NanoOverlayScope oldWidget) => false;
}

/// Opens an overlay above everything else and returns its controller.
///
/// The overlay is closed by [NanoOverlayController.close], the Escape key,
/// and — when [barrierDismissible] — by tapping the barrier. [anchorRect]
/// (global coordinates) is required for [NanoOverlayVariant.anchored].
NanoOverlayController showNanoOverlay(
  BuildContext context, {
  required WidgetBuilder builder,
  NanoOverlayVariant variant = NanoOverlayVariant.anchored,
  Rect? anchorRect,
  NanoPlacement placement = NanoPlacement.bottomStart,
  bool matchAnchorWidth = false,
  double offset = 8,
  Color? scrimColor,

  /// Tap-through barrier (tooltips): the barrier never blocks the pointer.
  bool ignorePointerBarrier = false,
  bool barrierDismissible = true,
  Size? contentSize,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  final scopeNode = FocusScopeNode();
  final controller = NanoOverlayController._(scopeNode);
  late final OverlayEntry entry = OverlayEntry(
    builder: (overlayContext) {
      final theme = NanoTheme.of(overlayContext);
      final effectiveScrim =
          scrimColor ??
          (variant == NanoOverlayVariant.anchored ? null : theme.colors.scrim);

      Widget barrier = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: barrierDismissible ? controller.close : null,
        child: effectiveScrim == null
            ? const SizedBox.expand()
            : ColoredBox(color: effectiveScrim),
      );
      if (ignorePointerBarrier) barrier = IgnorePointer(child: barrier);

      Widget content;
      switch (variant) {
        case NanoOverlayVariant.anchored:
          content = Positioned.fill(
            child: CustomSingleChildLayout(
              delegate: _AnchorLayoutDelegate(
                triggerRect: anchorRect!,
                placement: placement,
                offset: offset,
                matchTriggerWidth: matchAnchorWidth,
                screenPadding: theme.spacing.insetControl / 2,
              ),
              child: _OverlayPanel(
                controller: controller,
                child: builder(overlayContext),
              ),
            ),
          );
        case NanoOverlayVariant.dialog:
          content = Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.all(theme.spacing.gutterGrid),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: contentSize?.width ?? 512,
                  maxHeight: contentSize?.height ?? double.infinity,
                ),
                child: _OverlayPanel(
                  controller: controller,
                  child: builder(overlayContext),
                ),
              ),
            ),
          );
        case NanoOverlayVariant.sheetStart || NanoOverlayVariant.sheetEnd:
          final isStart = variant == NanoOverlayVariant.sheetStart;
          content = Align(
            alignment: isStart ? Alignment.centerLeft : Alignment.centerRight,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentSize?.width ?? 400),
              child: _OverlayPanel(
                controller: controller,
                slideFrom: isStart ? -1 : 1,
                vertical: false,
                child: builder(overlayContext),
              ),
            ),
          );
        case NanoOverlayVariant.sheetBottom:
          content = Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: contentSize?.height ?? double.infinity,
              ),
              child: _OverlayPanel(
                controller: controller,
                slideFrom: 1,
                vertical: true,
                child: builder(overlayContext),
              ),
            ),
          );
      }

      return NanoOverlayScope(
        controller: controller,
        child: Stack(
          children: [
            Positioned.fill(child: barrier),
            content,
          ],
        ),
      );
    },
  );

  controller._entry = entry;
  overlay.insert(entry);
  // Grab focus once mounted: autofocus alone won't steal it from the
  // trigger, and Escape / Tab handling assumes focus lives in the overlay.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (controller.isOpen) scopeNode.requestFocus();
  });
  return controller;
}

/// Shared overlay chrome: focus scope with Escape handling + a Tab trap, and
/// an entry animation (fade, plus scale for popovers and slide for sheets).
class _OverlayPanel extends StatefulWidget {
  const _OverlayPanel({
    required this.controller,
    required this.child,
    this.slideFrom = 0,
    this.vertical = false,
  });

  final NanoOverlayController controller;
  final Widget child;

  /// -1/1 = slide in along the axis from that side; 0 = no slide.
  final double slideFrom;
  final bool vertical;

  @override
  State<_OverlayPanel> createState() => _OverlayPanelState();
}

class _OverlayPanelState extends State<_OverlayPanel> {
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.controller.close();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.tab) {
      if (HardwareKeyboard.instance.isShiftPressed) {
        widget.controller.focusPrevious();
      } else {
        widget.controller.focusNext();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context, aspect: NanoThemeAspect.motion);
    final motion = theme.motion;
    return FocusScope(
      node: widget.controller._scopeNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: FocusTraversalGroup(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: motion.durationFast,
          curve: motion.curveStandard,
          builder: (context, t, child) {
            final slideOffset = widget.slideFrom == 0
                ? Offset.zero
                : (widget.vertical
                      ? Offset(0, widget.slideFrom * (1 - t))
                      : Offset(widget.slideFrom * (1 - t), 0));
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: slideOffset * 24,
                child: Transform.scale(
                  scale: widget.slideFrom == 0 ? 0.97 + 0.03 * t : 1,
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// Positions an anchored overlay panel relative to the trigger rect: prefers
/// the requested placement, flips vertically when there is no room, and
/// clamps horizontally inside the screen padding.
class _AnchorLayoutDelegate extends SingleChildLayoutDelegate {
  _AnchorLayoutDelegate({
    required this.triggerRect,
    required this.placement,
    required this.offset,
    required this.matchTriggerWidth,
    required this.screenPadding,
  });

  final Rect triggerRect;
  final NanoPlacement placement;
  final double offset;
  final bool matchTriggerWidth;
  final double screenPadding;

  Size _screen = Size.zero;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    _screen = constraints.biggest;
    final maxW = math.max(0.0, constraints.maxWidth - screenPadding * 2);
    final maxH = math.max(0.0, constraints.maxHeight - screenPadding * 2);
    final anchorWidth = math.min(triggerRect.width, maxW);
    return BoxConstraints(
      minWidth: matchTriggerWidth ? anchorWidth : 0.0,
      maxWidth: math.max(matchTriggerWidth ? anchorWidth : 0.0, maxW),
      maxHeight: maxH,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final bounds = EdgeInsets.all(screenPadding)
        .deflateRect(Offset.zero & _screen);
    final preferBelow =
        placement == NanoPlacement.bottomStart ||
        placement == NanoPlacement.bottomEnd ||
        placement == NanoPlacement.bottomCenter;
    final alignStart =
        placement == NanoPlacement.bottomStart ||
        placement == NanoPlacement.topStart;
    final alignEnd =
        placement == NanoPlacement.bottomEnd ||
        placement == NanoPlacement.topEnd;

    // Vertical: preferred side, flipping when the panel would overflow.
    double top;
    final spaceBelow = bounds.bottom - triggerRect.bottom;
    final spaceAbove = triggerRect.top - bounds.top;
    final fitsBelow =
        triggerRect.bottom + offset + childSize.height <= bounds.bottom;
    final fitsAbove = triggerRect.top - offset - childSize.height >= bounds.top;
    if (preferBelow) {
      top = fitsBelow || spaceBelow >= spaceAbove || !fitsAbove
          ? triggerRect.bottom + offset
          : triggerRect.top - offset - childSize.height;
    } else {
      top = fitsAbove || spaceAbove >= spaceBelow || !fitsBelow
          ? triggerRect.top - offset - childSize.height
          : triggerRect.bottom + offset;
    }

    // Horizontal: alignment relative to the trigger, clamped to the screen.
    double left;
    if (alignStart) {
      left = triggerRect.left;
    } else if (alignEnd) {
      left = triggerRect.right - childSize.width;
    } else {
      left = triggerRect.center.dx - childSize.width / 2;
    }
    left = left
        .clamp(
          bounds.left,
          math.max(bounds.left, bounds.right - childSize.width),
        )
        .toDouble();

    return Offset(left, top);
  }

  @override
  bool shouldRelayout(_AnchorLayoutDelegate oldDelegate) =>
      oldDelegate.triggerRect != triggerRect ||
      oldDelegate.placement != placement ||
      oldDelegate.offset != offset ||
      oldDelegate.matchTriggerWidth != matchTriggerWidth;
}

/// Base class for stateful widgets that park an overlay above a trigger.
/// Subclasses own the open/close lifecycle (click, hover, context menu…).
mixin NanoOverlayHost<T extends StatefulWidget> on State<T> {
  NanoOverlayController? _controller;

  /// The current overlay, if open.
  NanoOverlayController? get overlayController => _controller;

  bool get isOverlayOpen => _controller?.isOpen ?? false;

  /// Global rect of [triggerKeyContext]'s render box at open time.
  Rect _rectOf(BuildContext triggerContext) {
    final box = triggerContext.findRenderObject()! as RenderBox;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  /// Opens the overlay. [contentBuilder] runs inside the overlay; wrap the
  /// panel in the surface chrome yourself (e.g. [_NanoSurfacePanel]).
  void openOverlay({
    required BuildContext triggerContext,
    required WidgetBuilder contentBuilder,
    NanoOverlayVariant variant = NanoOverlayVariant.anchored,
    NanoPlacement placement = NanoPlacement.bottomStart,
    bool matchTriggerWidth = false,
    double offset = 8,
    Color? scrimColor,
    bool ignorePointerBarrier = false,
    bool barrierDismissible = true,
    Size? contentSize,
  }) {
    if (isOverlayOpen) return;
    final rect = _rectOf(triggerContext);
    _controller = showNanoOverlay(
      context,
      builder: contentBuilder,
      variant: variant,
      anchorRect: rect,
      placement: placement,
      matchAnchorWidth: matchTriggerWidth,
      offset: offset,
      scrimColor: scrimColor,
      ignorePointerBarrier: ignorePointerBarrier,
      barrierDismissible: barrierDismissible,
      contentSize: contentSize,
    );
  }

  void closeOverlay() => _controller?.close();

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }
}

/// The standard surface chrome for anchored panels: surface color, border,
/// popover radius, floating shadow, and padding — the shadcn popover/menu
/// recipe, expressed purely in tokens.
class NanoSurfacePanel extends StatelessWidget {
  const NanoSurfacePanel({
    super.key,
    required this.child,
    this.padding,
    this.minWidth,
    this.maxWidth,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? minWidth;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Container(
      padding: padding,
      constraints: BoxConstraints(
        minWidth: minWidth ?? 0,
        maxWidth: maxWidth ?? 320,
      ),
      decoration: BoxDecoration(
        color: theme.colors.surface,
        borderRadius: BorderRadius.circular(theme.radius.surfacePopover),
        border: Border.all(
          color: theme.colors.border,
          width: theme.borders.controlWidth,
        ),
        boxShadow: theme.elevation.floating,
      ),
      child: child,
    );
  }
}
