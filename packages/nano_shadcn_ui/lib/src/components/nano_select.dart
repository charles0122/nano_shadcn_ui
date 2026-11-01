import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

import 'nano_menu.dart';

/// One option of a [NanoSelect].
class NanoSelectItem<T> {
  const NanoSelectItem({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  final T value;
  final String label;
  final bool enabled;
}

/// Option list picker — shadcn `Select`: a field-like trigger showing the
/// selected label (or placeholder), with a check-marked menu panel. The
/// panel never closes on selection of the same value? It always closes,
/// matching Radix behavior.
class NanoSelect<T> extends StatefulWidget {
  const NanoSelect({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.placeholder = 'Select…',
    this.enabled = true,
    this.fillWidth = false,
  });

  final List<NanoSelectItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String placeholder;
  final bool enabled;

  /// Stretch the trigger to the parent width (form layout).
  final bool fillWidth;

  @override
  State<NanoSelect<T>> createState() => _NanoSelectState<T>();
}

class _NanoSelectState<T> extends State<NanoSelect<T>> with NanoOverlayHost {
  bool _hovered = false;

  String get _selectedLabel {
    for (final item in widget.items) {
      if (item.value == widget.value) return item.label;
    }
    return '';
  }

  void _toggle() {
    if (isOverlayOpen) {
      closeOverlay();
      return;
    }
    openOverlay(
      triggerContext: context,
      contentBuilder: (overlayContext) {
        final theme = NanoTheme.of(overlayContext);
        final entries = <NanoMenuEntry>[
          for (final item in widget.items)
            NanoMenuItemEntry(
              label: item.label,
              enabled: item.enabled,
              trailing: item.value == widget.value
                  ? NanoIcon(
                      NanoIcons.check,
                      size: theme.size.iconInline,
                      color: theme.colors.textPrimary,
                    )
                  : null,
              onSelect: item.enabled && widget.onChanged != null
                  ? () => widget.onChanged!(item.value)
                  : null,
            ),
        ];
        return NanoMenuPanel(entries: entries, minWidth: null, maxWidth: null);
      },
      matchTriggerWidth: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final hasError = NanoFormFieldScope.maybeOf(context)?.hasError ?? false;
    final focused = isOverlayOpen;
    final hasValue = _selectedLabel.isNotEmpty;

    final trigger = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? _toggle : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: theme.motion.durationFast,
          curve: theme.motion.curveStandard,
          height: theme.size.controlHeightDefault,
          padding: EdgeInsets.symmetric(horizontal: theme.spacing.insetControl),
          decoration: BoxDecoration(
            color: widget.enabled
                ? theme.colors.surface
                : theme.colors.surfaceSubtle,
            borderRadius: BorderRadius.circular(theme.radius.controlInput),
            border: Border.all(
              color: focused
                  ? theme.colors.borderFocus
                  : hasError
                  ? theme.colors.danger.foreground
                  : _hovered && widget.enabled
                  ? theme.colors.borderStrong
                  : theme.colors.border,
              width: focused
                  ? theme.borders.controlFocusWidth
                  : theme.borders.controlWidth,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasValue ? _selectedLabel : widget.placeholder,
                  style: theme.type.bodyDefault.copyWith(
                    color: hasValue
                        ? (widget.enabled
                              ? theme.colors.textPrimary
                              : theme.colors.textDisabled)
                        : theme.colors.textDisabled,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: theme.spacing.inlineIconLabel / 2),
              NanoIcon(
                NanoIcons.chevronsUpDown,
                size: theme.size.iconInline,
                color: theme.colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );

    return widget.fillWidth
        ? SizedBox(width: double.infinity, child: trigger)
        : IntrinsicWidth(child: trigger);
  }
}
