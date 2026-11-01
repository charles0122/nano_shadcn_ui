import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// One entry of a [NanoNavigationMenu]: a plain link or a trigger with a
/// rich hover panel.
class NanoNavigationEntry {
  const NanoNavigationEntry({
    required this.label,
    this.onTap,
    this.active = false,
    this.panelBuilder,
  });

  final String label;
  final VoidCallback? onTap;
  final bool active;

  /// When provided, hovering opens this content in a wide dropdown panel
  /// (the shadcn "components" mega-menu pattern).
  final WidgetBuilder? panelBuilder;
}

/// Horizontal navigation — shadcn `Navigation Menu`: underlined triggers;
/// entries with panels open them on hover with a floating surface.
class NanoNavigationMenu extends StatefulWidget {
  const NanoNavigationMenu({super.key, required this.entries});

  final List<NanoNavigationEntry> entries;

  @override
  State<NanoNavigationMenu> createState() => _NanoNavigationMenuState();
}

class _NanoNavigationMenuState extends State<NanoNavigationMenu>
    with NanoOverlayHost {
  int? _openIndex;
  bool _insideTrigger = false;
  bool _insidePanel = false;
  Timer? _timer;

  void _hoverStart(int index) {
    _insideTrigger = true;
    _timer?.cancel();
    final panel = widget.entries[index].panelBuilder;
    if (panel == null) return;
    if (isOverlayOpen && _openIndex == index) return;
    _timer = Timer(const Duration(milliseconds: 120), () {
      if (!mounted || !_insideTrigger) return;
      setState(() => _openIndex = index);
      closeOverlay();
      openOverlay(
        triggerContext: context,
        contentBuilder: (overlayContext) => MouseRegion(
          onEnter: (_) => _insidePanel = true,
          onExit: (_) {
            _insidePanel = false;
            _scheduleClose();
          },
          child: NanoSurfacePanel(
            minWidth: null,
            maxWidth: 560,
            child: widget.entries[index].panelBuilder!(overlayContext),
          ),
        ),
        placement: NanoPlacement.bottomStart,
        offset: 6,
        ignorePointerBarrier: true,
        barrierDismissible: false,
      );
    });
  }

  void _hoverEnd() {
    _insideTrigger = false;
    _scheduleClose();
  }

  void _scheduleClose() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 120), () {
      if (mounted && !_insideTrigger && !_insidePanel) {
        closeOverlay();
        setState(() => _openIndex = null);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.entries.length; i++)
          MouseRegion(
            onEnter: (_) => _hoverStart(i),
            onExit: (_) => _hoverEnd(),
            child: GestureDetector(
              onTap: widget.entries[i].onTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing.insetControl,
                  vertical: theme.spacing.stackDefault / 2,
                ),
                decoration: BoxDecoration(
                  color: _openIndex == i ? theme.colors.surfaceSubtle : null,
                  borderRadius: BorderRadius.circular(
                    theme.radius.controlDefault / 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NanoText(
                      widget.entries[i].label,
                      role: NanoTextRole.body,
                      color: widget.entries[i].active
                          ? theme.colors.textPrimary
                          : theme.colors.textSecondary,
                    ),
                    if (widget.entries[i].panelBuilder != null) ...[
                      SizedBox(width: theme.spacing.inlineIconLabel / 4),
                      NanoIcon(
                        NanoIcons.chevronDown,
                        size: theme.size.iconInline - 2,
                        color: theme.colors.textSecondary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
