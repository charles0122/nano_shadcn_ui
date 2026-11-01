import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

import 'nano_checkbox.dart';

/// Sort direction of a [NanoDataTableColumn].
enum NanoSortDirection { ascending, descending }

/// Typed column of a [NanoDataTable].
class NanoDataTableColumn<T> {
  const NanoDataTableColumn({
    required this.header,
    required this.cell,
    this.sortKey,
    this.width,
  });

  final String header;

  /// Builds the cell for one row.
  final Widget Function(BuildContext context, T row) cell;

  /// Enables sorting on this column when provided.
  final Comparable? Function(T row)? sortKey;
  final double? width;
}

/// Data table — shadcn `Data Table`: sortable header triggers with
/// direction arrows, an optional checkbox selection column with select-all,
/// hover-highlighted rows and hairline dividers.
class NanoDataTable<T> extends StatefulWidget {
  const NanoDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.initialSortColumn = 0,
    this.initialSortDirection = NanoSortDirection.ascending,
    this.selectable = false,
    this.onSelectionChanged,
    this.onRowTap,
  });

  final List<NanoDataTableColumn<T>> columns;
  final List<T> rows;
  final int initialSortColumn;
  final NanoSortDirection initialSortDirection;
  final bool selectable;
  final ValueChanged<Set<int>>? onSelectionChanged;
  final void Function(T row)? onRowTap;

  @override
  State<NanoDataTable<T>> createState() => _NanoDataTableState<T>();
}

class _NanoDataTableState<T> extends State<NanoDataTable<T>> {
  late int _sortColumn = widget.initialSortColumn;
  late NanoSortDirection _sortDirection = widget.initialSortDirection;
  final Set<int> _selected = {};

  bool get _allSelected =>
      widget.rows.isNotEmpty && _selected.length == widget.rows.length;

  List<T> get _sorted {
    final key = widget.columns[_sortColumn].sortKey;
    if (key == null) return widget.rows;
    final rows = List.of(widget.rows);
    rows.sort((a, b) {
      final ka = key(a), kb = key(b);
      if (ka == null || kb == null) return 0;
      var result = Comparable.compare(ka, kb);
      if (_sortDirection == NanoSortDirection.descending) result = -result;
      return result;
    });
    return rows;
  }

  void _toggleAll(NanoTristate checked) {
    setState(() {
      _selected.clear();
      if (checked == NanoTristate.checked) {
        _selected.addAll(List.generate(widget.rows.length, (i) => i));
      }
    });
    widget.onSelectionChanged?.call(Set.of(_selected));
  }

  void _toggleRow(int index) {
    setState(
      () => _selected.contains(index)
          ? _selected.remove(index)
          : _selected.add(index),
    );
    widget.onSelectionChanged?.call(Set.of(_selected));
  }

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final rows = _sorted;

    Widget cellBox({
      required Widget child,
      double? width,
      EdgeInsets? padding,
    }) => Container(
      width: width,
      alignment: AlignmentDirectional.centerStart,
      padding:
          padding ??
          EdgeInsets.symmetric(horizontal: theme.spacing.insetControl),
      child: child,
    );

    Widget headerCell(int index) {
      final column = widget.columns[index];
      final active = _sortColumn == index;
      final sortable = column.sortKey != null;
      final content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          NanoText(column.header, role: NanoTextRole.labelMetadata),
          if (sortable) ...[
            SizedBox(width: theme.spacing.inlineIconLabel / 2),
            AnimatedOpacity(
              opacity: active ? 1 : 0.4,
              duration: theme.motion.durationFast,
              child: active
                  ? AnimatedRotation(
                      turns: _sortDirection == NanoSortDirection.descending
                          ? 0.5
                          : 0,
                      duration: theme.motion.durationFast,
                      child: NanoIcon(
                        NanoIcons.arrowUp,
                        size: theme.size.iconInline - 2,
                        color: theme.colors.textPrimary,
                      ),
                    )
                  : NanoIcon(
                      NanoIcons.chevronsUpDown,
                      size: theme.size.iconInline - 2,
                      color: theme.colors.textSecondary,
                    ),
            ),
          ],
        ],
      );
      if (!sortable) return cellBox(child: content, width: column.width);
      return NanoInteractive(
        onTap: () => setState(() {
          if (active) {
            _sortDirection = _sortDirection == NanoSortDirection.ascending
                ? NanoSortDirection.descending
                : NanoSortDirection.ascending;
          } else {
            _sortColumn = index;
            _sortDirection = NanoSortDirection.ascending;
          }
        }),
        builder: (context, states) =>
            cellBox(child: content, width: column.width),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.radius.controlInput),
        border: Border.all(
          color: theme.colors.border,
          width: theme.borders.controlWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header band.
          Container(
            color: theme.colors.surfaceSubtle,
            padding: EdgeInsets.symmetric(
              vertical: theme.spacing.insetControl / 2,
            ),
            child: Row(
              children: [
                if (widget.selectable)
                  cellBox(
                    width: 48,
                    padding: EdgeInsets.symmetric(
                      horizontal: theme.spacing.insetControl / 2,
                    ),
                    child: Center(
                      child: NanoCheckbox(
                        value: NanoCheckbox.of(_allSelected),
                        onChanged: _toggleAll,
                      ),
                    ),
                  ),
                for (var i = 0; i < widget.columns.length; i++)
                  Expanded(
                    flex: widget.columns[i].width == null ? 1 : 0,
                    child: widget.columns[i].width != null
                        ? SizedBox(
                            width: widget.columns[i].width,
                            child: headerCell(i),
                          )
                        : headerCell(i),
                  ),
              ],
            ),
          ),
          // Rows.
          for (var i = 0; i < rows.length; i++)
            _Row<T>(
              key: ValueKey(i),
              index: i,
              row: rows[i],
              columns: widget.columns,
              selectable: widget.selectable,
              selected: _selected.contains(i),
              onToggle: () => _toggleRow(i),
              onTap: widget.onRowTap,
              isLast: i == rows.length - 1,
            ),
        ],
      ),
    );
  }
}

class _Row<T> extends StatelessWidget {
  const _Row({
    super.key,
    required this.index,
    required this.row,
    required this.columns,
    required this.selectable,
    required this.selected,
    required this.onToggle,
    required this.onTap,
    required this.isLast,
  });

  final int index;
  final T row;
  final List<NanoDataTableColumn<T>> columns;
  final bool selectable;
  final bool selected;
  final VoidCallback onToggle;
  final void Function(T row)? onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final divider = Container(
      height: theme.borders.dividerWidth,
      color: theme.colors.border,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NanoInteractive(
          onTap: onTap != null ? () => onTap!(row) : null,
          builder: (context, states) {
            final hovered = states.contains(WidgetState.hovered);
            return Container(
              color: hovered || selected ? theme.colors.surfaceSubtle : null,
              padding: EdgeInsets.symmetric(
                vertical: theme.spacing.insetControl / 2,
              ),
              child: Row(
                children: [
                  if (selectable)
                    Container(
                      width: 48,
                      padding: EdgeInsets.symmetric(
                        horizontal: theme.spacing.insetControl / 2,
                      ),
                      child: Center(
                        child: NanoCheckbox(
                          value: NanoCheckbox.of(selected),
                          onChanged: (_) => onToggle(),
                        ),
                      ),
                    ),
                  for (final column in columns)
                    Expanded(
                      flex: column.width == null ? 1 : 0,
                      child: column.width != null
                          ? SizedBox(
                              width: column.width,
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: column.cell(context, row),
                              ),
                            )
                          : Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: column.cell(context, row),
                            ),
                    ),
                ],
              ),
            );
          },
        ),
        if (!isLast) divider,
      ],
    );
  }
}
