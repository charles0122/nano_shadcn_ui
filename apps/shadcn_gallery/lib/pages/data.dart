import 'package:flutter/widgets.dart';
import 'package:nano_shadcn_ui/nano_shadcn_ui.dart';

import '../gallery_kit.dart';

// --- Chart ------------------------------------------------------------------

class _ChartDemo extends StatelessWidget {
  const _ChartDemo();

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return SizedBox(
      width: 560,
      child: Column(
        children: [
          NanoBarChart(
            height: 200,
            series: [
              NanoChartSeries('Revenue', const [
                NanoChartPoint('Jan', 4200),
                NanoChartPoint('Feb', 3800),
                NanoChartPoint('Mar', 5100),
                NanoChartPoint('Apr', 4600),
                NanoChartPoint('May', 5900),
                NanoChartPoint('Jun', 6300),
              ]),
            ],
          ),
          SizedBox(height: theme.spacing.stackSections),
          NanoLineChart(
            height: 160,
            series: [
              NanoChartSeries('Desktop', const [
                NanoChartPoint('Jan', 180),
                NanoChartPoint('Feb', 240),
                NanoChartPoint('Mar', 210),
                NanoChartPoint('Apr', 290),
                NanoChartPoint('May', 320),
                NanoChartPoint('Jun', 300),
              ]),
              NanoChartSeries('Mobile', const [
                NanoChartPoint('Jan', 90),
                NanoChartPoint('Feb', 130),
                NanoChartPoint('Mar', 170),
                NanoChartPoint('Apr', 160),
                NanoChartPoint('May', 220),
                NanoChartPoint('Jun', 250),
              ], color: theme.colors.success.foreground),
            ],
          ),
          SizedBox(height: theme.spacing.stackSections),
          NanoAreaChart(
            height: 140,
            series: [
              NanoChartSeries('Builds', const [
                NanoChartPoint('Mon', 12),
                NanoChartPoint('Tue', 19),
                NanoChartPoint('Wed', 15),
                NanoChartPoint('Thu', 22),
                NanoChartPoint('Fri', 28),
              ]),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Data table ---------------------------------------------------------------

class _Payment {
  const _Payment(this.id, this.status, this.method, this.amount);
  final String id;
  final String status;
  final String method;
  final double amount;
}

class _DataTableDemo extends StatefulWidget {
  const _DataTableDemo();

  @override
  State<_DataTableDemo> createState() => _DataTableDemoState();
}

class _DataTableDemoState extends State<_DataTableDemo> {
  Set<int> _selected = {};

  static const _payments = [
    _Payment('m_5f9a', 'Paid', 'Credit Card', 316.00),
    _Payment('m_2ac1', 'Pending', 'PayPal', 242.00),
    _Payment('m_9b31', 'Paid', 'Bank Transfer', 184.00),
    _Payment('m_71e0', 'Failed', 'Credit Card', 92.00),
    _Payment('m_c4d8', 'Paid', 'Credit Card', 428.00),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        NanoDataTable<_Payment>(
          selectable: true,
          rows: _payments,
          onSelectionChanged: (s) => setState(() => _selected = s),
          columns: [
            NanoDataTableColumn(
              header: 'Status',
              sortKey: (p) => p.status,
              cell: (context, p) => NanoBadge(
                p.status,
                variant: p.status == 'Paid'
                    ? NanoBadgeVariant.secondary
                    : p.status == 'Pending'
                    ? NanoBadgeVariant.outline
                    : NanoBadgeVariant.destructive,
              ),
            ),
            NanoDataTableColumn(
              header: 'Email',
              sortKey: (p) => p.id,
              cell: (context, p) => Text(
                '${p.id}@example.dev',
                style: theme.type.bodyDefault.copyWith(
                  color: theme.colors.textPrimary,
                ),
              ),
            ),
            NanoDataTableColumn(
              header: 'Method',
              sortKey: (p) => p.method,
              cell: (context, p) => Text(
                p.method,
                style: theme.type.bodyDefault.copyWith(
                  color: theme.colors.textPrimary,
                ),
              ),
            ),
            NanoDataTableColumn(
              header: 'Amount',
              sortKey: (p) => p.amount,
              cell: (context, p) => Text(
                '\$${p.amount.toStringAsFixed(2)}',
                style: theme.type.bodyDefault.copyWith(
                  color: theme.colors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: theme.spacing.stackDefault),
        NanoText(
          '${_selected.length} row(s) selected. Click a header to sort.',
          role: NanoTextRole.labelMetadata,
        ),
      ],
    );
  }
}

// --- Pagination ----------------------------------------------------------------

class _PaginationDemo extends StatefulWidget {
  const _PaginationDemo();

  @override
  State<_PaginationDemo> createState() => _PaginationDemoState();
}

class _PaginationDemoState extends State<_PaginationDemo> {
  int _page = 2;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NanoPagination(
          pageCount: 20,
          page: _page,
          onChanged: (p) => setState(() => _page = p),
        ),
        SizedBox(height: theme.spacing.stackDefault),
        NanoText('Page $_page of 20', role: NanoTextRole.labelMetadata),
      ],
    );
  }
}

Widget chartPage(BuildContext context) {
  return const DemoSection(
    title: 'Chart',
    description:
        'Bar, line and area painters — series colors resolve from '
        'token roles.',
    align: AlignmentDirectional.centerStart,
    child: _ChartDemo(),
  );
}

Widget dataTablePage(BuildContext context) {
  return const DemoSection(
    title: 'Data Table',
    description:
        'Sortable headers with direction arrows and checkbox row '
        'selection.',
    align: AlignmentDirectional.centerStart,
    child: _DataTableDemo(),
  );
}

Widget paginationPage(BuildContext context) {
  return const DemoSection(
    title: 'Pagination',
    description: 'Windowed page numbers with ellipsis collapse.',
    child: _PaginationDemo(),
  );
}
