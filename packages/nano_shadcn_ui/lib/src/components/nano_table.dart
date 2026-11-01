import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Column descriptor of a [NanoTable].
class NanoTableColumn {
  const NanoTableColumn({
    required this.header,
    this.width,
    this.alignment = AlignmentDirectional.centerStart,
  });

  final String header;
  final double? width;
  final AlignmentDirectional alignment;
}

/// Bordered table — shadcn `Table`: muted header band, hairline row
/// dividers, control-height rows. Cells are plain widgets.
class NanoTable extends StatelessWidget {
  const NanoTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.striped = false,
  });

  final List<NanoTableColumn> columns;

  /// One list of cells per row, aligned with [columns].
  final List<List<Widget>> rows;
  final void Function(int rowIndex)? onRowTap;
  final bool striped;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final headerStyle = theme.type.labelMetadata.copyWith(
      color: theme.colors.textSecondary,
    );

    Widget row(
      List<Widget> cells, {
      bool header = false,
      int? index,
      Color? bg,
    }) {
      final hovered = ValueNotifier(false);
      return ValueListenableBuilder(
        valueListenable: hovered,
        builder: (context, hover, _) => MouseRegion(
          onEnter: header || onRowTap == null
              ? null
              : (_) => hovered.value = true,
          onExit: (_) => hovered.value = false,
          child: GestureDetector(
            onTap: header || onRowTap == null ? null : () => onRowTap!(index!),
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: hover ? theme.colors.surfaceSubtle : bg,
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacing.insetControl,
                vertical: theme.spacing.insetControl / 2,
              ),
              constraints: BoxConstraints(
                minHeight: header
                    ? theme.size.controlHeightCompact
                    : theme.size.controlHeightDefault,
              ),
              child: Table(
                columnWidths: {
                  for (var i = 0; i < columns.length; i++)
                    i: columns[i].width != null
                        ? FixedColumnWidth(columns[i].width!)
                        : const FlexColumnWidth(),
                },
                border: header
                    ? null
                    : TableBorder(
                        bottom: BorderSide(
                          color: theme.colors.border,
                          width: theme.borders.dividerWidth,
                        ),
                      ),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      for (var i = 0; i < columns.length; i++)
                        Align(
                          alignment: columns[i].alignment,
                          child: header
                              ? Text(columns[i].header, style: headerStyle)
                              : cells[i],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
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
        children: [
          row(const [], header: true),
          for (var i = 0; i < rows.length; i++)
            row(
              rows[i],
              index: i,
              bg: striped && i.isOdd ? theme.colors.surfaceSubtle : null,
            ),
        ],
      ),
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoTableSpec = NanoComponentSpec(
  name: 'NanoTable',
  description: 'Bordered table; rows and cells come from the host app.',
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
