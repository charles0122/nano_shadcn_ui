import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

import 'nano_calendar.dart';

/// Date field — shadcn `Date Picker`: a field-like trigger that opens a
/// [NanoCalendar] in a popover. Single date or range.
class NanoDatePicker extends StatefulWidget {
  const NanoDatePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.mode = NanoCalendarMode.single,
    this.placeholder = 'Pick a date',
    this.enabled = true,
    this.fillWidth = false,
  });

  final List<DateTime> value;
  final ValueChanged<List<DateTime>> onChanged;
  final NanoCalendarMode mode;
  final String placeholder;
  final bool enabled;
  final bool fillWidth;

  @override
  State<NanoDatePicker> createState() => _NanoDatePickerState();
}

class _NanoDatePickerState extends State<NanoDatePicker> with NanoOverlayHost {
  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String get _label {
    if (widget.value.isEmpty) return '';
    String fmt(DateTime d) => '${_monthNames[d.month - 1]} ${d.day}, ${d.year}';
    return widget.mode == NanoCalendarMode.range && widget.value.length > 1
        ? '${fmt(widget.value.first)} – ${fmt(widget.value.last)}'
        : fmt(widget.value.first);
  }

  void _toggle() {
    if (isOverlayOpen) {
      closeOverlay();
      return;
    }
    openOverlay(
      triggerContext: context,
      contentBuilder: (overlayContext) => NanoSurfacePanel(
        minWidth: null,
        maxWidth: 400,
        child: NanoCalendar(
          mode: widget.mode,
          selected: widget.value,
          onChanged: (dates) {
            widget.onChanged(dates);
            if (dates.isNotEmpty && widget.mode != NanoCalendarMode.multiple) {
              // Keep the popover open in range mode until both ends picked.
              if (widget.mode == NanoCalendarMode.single) closeOverlay();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final hasValue = _label.isNotEmpty;
    final trigger = GestureDetector(
      onTap: widget.enabled ? _toggle : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: theme.size.controlHeightDefault,
        padding: EdgeInsets.symmetric(horizontal: theme.spacing.insetControl),
        decoration: BoxDecoration(
          color: widget.enabled
              ? theme.colors.surface
              : theme.colors.surfaceSubtle,
          borderRadius: BorderRadius.circular(theme.radius.controlInput),
          border: Border.all(
            color: isOverlayOpen
                ? theme.colors.borderFocus
                : theme.colors.border,
            width: isOverlayOpen
                ? theme.borders.controlFocusWidth
                : theme.borders.controlWidth,
          ),
        ),
        child: Row(
          children: [
            NanoIcon(
              NanoIcons.calendar,
              size: theme.size.iconInline,
              color: theme.colors.textSecondary,
            ),
            SizedBox(width: theme.spacing.inlineIconLabel / 2),
            Expanded(
              child: Text(
                hasValue ? _label : widget.placeholder,
                style: theme.type.bodyDefault.copyWith(
                  color: hasValue
                      ? theme.colors.textPrimary
                      : theme.colors.textDisabled,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
    return widget.fillWidth
        ? SizedBox(width: double.infinity, child: trigger)
        : IntrinsicWidth(child: trigger);
  }
}
