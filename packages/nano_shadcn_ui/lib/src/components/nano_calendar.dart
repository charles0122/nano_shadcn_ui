import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Selection mode of a [NanoCalendar].
enum NanoCalendarMode { single, multiple, range }

int _weekday(DateTime date) => date.weekday % 7; // Sunday == 0

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Month calendar — shadcn `Calendar` (react-day-picker): weekday header,
/// Sunday-first grid, month navigation, single / multiple / range selection,
/// today outline, outside days dimmed.
class NanoCalendar extends StatefulWidget {
  const NanoCalendar({
    super.key,
    this.month,
    this.selected = const [],
    this.mode = NanoCalendarMode.single,
    this.onChanged,
    this.isDayEnabled,
    this.showOutsideDays = false,
  });

  /// Displayed month; defaults to the month of the first selected day.
  final DateTime? month;

  /// Selected days (start/end for range mode).
  final List<DateTime> selected;
  final NanoCalendarMode mode;
  final ValueChanged<List<DateTime>>? onChanged;

  /// Predicate for selectable days.
  final bool Function(DateTime day)? isDayEnabled;
  final bool showOutsideDays;

  @override
  State<NanoCalendar> createState() => _NanoCalendarState();
}

class _NanoCalendarState extends State<NanoCalendar> {
  late DateTime _month =
      widget.month ??
      (widget.selected.isNotEmpty ? widget.selected.first : DateTime.now());
  late List<DateTime> _selected = List.of(widget.selected);

  void _commit() => widget.onChanged?.call(List.of(_selected));

  void _toggleDay(DateTime day) {
    final only = _dateOnly(day);
    if (widget.mode == NanoCalendarMode.multiple) {
      _selected.any((d) => _dateOnly(d) == only)
          ? _selected.removeWhere((d) => _dateOnly(d) == only)
          : _selected.add(only);
    } else {
      _selected
        ..clear()
        ..add(only);
    }
    setState(() {});
    _commit();
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final colors = theme.colors;
    const weekdays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    final firstOfMonth = DateTime(_month.year, _month.month, 1);
    final gridStart = firstOfMonth.subtract(
      Duration(days: _weekday(firstOfMonth)),
    );
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final weeks = ((daysInMonth + _weekday(firstOfMonth)) / 7).ceil();
    final today = _dateOnly(DateTime.now());
    final now = DateTime.now();

    final rangeStart = _selected.isNotEmpty ? _dateOnly(_selected.first) : null;
    final rangeEnd = _selected.length > 1 ? _dateOnly(_selected.last) : null;

    Widget navButton(NanoIconData icon, VoidCallback? onTap) => NanoInteractive(
      onTap: onTap,
      builder: (context, states) {
        final hovered = states.contains(WidgetState.hovered);
        return Container(
          width: theme.size.controlHeightCompact * 0.75,
          height: theme.size.controlHeightCompact * 0.75,
          decoration: BoxDecoration(
            color: hovered ? colors.surfaceSubtle : null,
            borderRadius: BorderRadius.circular(
              theme.radius.controlDefault / 2,
            ),
          ),
          child: Center(
            child: NanoIcon(
              icon,
              size: theme.size.iconInline,
              color: colors.textPrimary,
            ),
          ),
        );
      },
    );

    return SizedBox(
      width: theme.size.controlHeightDefault * 7 + theme.spacing.insetCard * 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: month label + navigation.
          Padding(
            padding: EdgeInsets.only(bottom: theme.spacing.stackDefault),
            child: Row(
              children: [
                Expanded(
                  child: NanoText(
                    _monthLabel(_month),
                    role: NanoTextRole.labelAction,
                  ),
                ),
                navButton(NanoIcons.chevronLeft, () => _shiftMonth(-1)),
                SizedBox(width: theme.spacing.inlineIconLabel / 2),
                navButton(NanoIcons.chevronRight, () => _shiftMonth(1)),
              ],
            ),
          ),
          // Weekday row.
          Row(
            children: [
              for (final label in weekdays)
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: theme.size.controlHeightCompact,
                      child: NanoText(label, role: NanoTextRole.labelMetadata),
                    ),
                  ),
                ),
            ],
          ),
          // Day grid.
          for (var w = 0; w < weeks; w++)
            Row(
              children: [
                for (var d = 0; d < 7; d++)
                  Expanded(
                    child: _DayCell(
                      date: gridStart.add(Duration(days: w * 7 + d)),
                      month: _month,
                      now: now,
                      today: today,
                      mode: widget.mode,
                      selected: _selected,
                      rangeStart: rangeStart,
                      rangeEnd: rangeEnd,
                      enabled:
                          widget.isDayEnabled?.call(
                            gridStart.add(Duration(days: w * 7 + d)),
                          ) ??
                          true,
                      showOutside: widget.showOutsideDays,
                      onTap: _toggleDay,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  static String _monthLabel(DateTime month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${names[month.month - 1]} ${month.year}';
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.month,
    required this.now,
    required this.today,
    required this.mode,
    required this.selected,
    required this.rangeStart,
    required this.rangeEnd,
    required this.enabled,
    required this.showOutside,
    required this.onTap,
  });

  final DateTime date;
  final DateTime month;
  final DateTime now;
  final DateTime today;
  final NanoCalendarMode mode;
  final List<DateTime> selected;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final bool enabled;
  final bool showOutside;
  final void Function(DateTime) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final colors = theme.colors;
    final day = _dateOnly(date);
    final outside = day.month != month.month;
    if (outside && !showOutside) return const SizedBox();

    final isSelected = selected.any((d) => _dateOnly(d) == day);
    final isToday = day == today;
    final inRange =
        rangeStart != null &&
        rangeEnd != null &&
        day.isAfter(rangeStart!) &&
        day.isBefore(rangeEnd!);

    final Color background;
    final Color foreground;
    if (isSelected) {
      background = colors.actionPrimaryBackground;
      foreground = colors.actionPrimaryForeground;
    } else if (inRange) {
      background = colors.surfaceSubtle;
      foreground = colors.textPrimary;
    } else {
      background = const Color(0x00000000);
      foreground = outside
          ? colors.textDisabled
          : enabled
          ? colors.textPrimary
          : colors.textDisabled;
    }

    return NanoInteractive(
      onTap: enabled && !outside ? () => onTap(date) : null,
      enabled: enabled && !outside,
      builder: (context, states) {
        final hovered =
            states.contains(WidgetState.hovered) && enabled && !outside;
        return Center(
          child: AnimatedContainer(
            duration: theme.motion.durationFast,
            curve: theme.motion.curveStandard,
            width: theme.size.controlHeightDefault,
            height: theme.size.controlHeightDefault,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: hovered && !isSelected ? colors.surfaceSubtle : background,
              borderRadius: BorderRadius.circular(
                theme.radius.controlDefault / 2,
              ),
              border: isToday && !isSelected
                  ? Border.all(
                      color: colors.borderStrong,
                      width: theme.borders.controlWidth,
                    )
                  : null,
            ),
            child: Text(
              '${date.day}',
              style: theme.type.bodyDefault.copyWith(color: foreground),
            ),
          ),
        );
      },
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoCalendarSpec = NanoComponentSpec(
  name: 'NanoCalendar',
  description: 'Month calendar grid; selection is owned by the host app.',
  propsSchema: {},
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  return NanoCalendar(onChanged: (_) {});
}
