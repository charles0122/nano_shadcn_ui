import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Page descriptor for [NanoPagination]; `null` value renders an ellipsis.
class NanoPageItem {
  const NanoPageItem(this.label, {this.value});

  final String label;
  final int? value;

  /// Ellipsis separator.
  static const NanoPageItem ellipsis = NanoPageItem('…');
}

/// Pagination row — shadcn `Pagination`: prev/next icon triggers, outlined
/// page numbers with the active one filled, ellipsis separators.
class NanoPagination extends StatelessWidget {
  const NanoPagination({
    super.key,
    required this.pageCount,
    required this.page,
    required this.onChanged,
    this.enabled = true,
    this.siblings = 1,
  });

  final int pageCount;
  final int page;
  final ValueChanged<int>? onChanged;
  final bool enabled;

  /// Pages shown either side of the current one before collapsing to an
  /// ellipsis.
  final int siblings;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final items = _pageItems();
    Widget trigger({
      required Widget child,
      required VoidCallback? onTap,
      bool active = false,
      double? width,
    }) => NanoInteractive(
      onTap: enabled ? onTap : null,
      enabled: enabled,
      builder: (context, states) {
        final focused = states.contains(WidgetState.focused);
        return AnimatedContainer(
          duration: theme.motion.durationFast,
          curve: theme.motion.curveStandard,
          width: width ?? theme.size.controlHeightDefault,
          height: theme.size.controlHeightDefault,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? theme.colors.actionPrimaryBackground : null,
            borderRadius: BorderRadius.circular(theme.radius.controlButton),
            border: Border.all(
              color: focused
                  ? theme.colors.borderFocus
                  : active
                  ? theme.colors.actionPrimaryBackground
                  : const Color(0x00000000),
              width: focused
                  ? theme.borders.controlFocusWidth
                  : theme.borders.controlWidth,
            ),
          ),
          child: child,
        );
      },
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        trigger(
          onTap: page > 1 ? () => onChanged?.call(page - 1) : null,
          child: NanoIcon(
            NanoIcons.arrowLeft,
            size: theme.size.iconInline,
            color: page > 1
                ? theme.colors.textPrimary
                : theme.colors.textDisabled,
          ),
        ),
        SizedBox(width: theme.spacing.inlineActions / 2),
        for (final item in items) ...[
          if (item.value == null)
            NanoText(
              NanoPageItem.ellipsis.label,
              role: NanoTextRole.bodySupporting,
            )
          else
            trigger(
              onTap: item.value != page
                  ? () => onChanged?.call(item.value!)
                  : null,
              active: item.value == page,
              child: Text(
                item.label,
                style: theme.type.labelAction.copyWith(
                  color: item.value == page
                      ? theme.colors.actionPrimaryForeground
                      : theme.colors.textPrimary,
                ),
              ),
            ),
          SizedBox(width: theme.spacing.inlineActions / 2),
        ],
        trigger(
          onTap: page < pageCount ? () => onChanged?.call(page + 1) : null,
          child: NanoIcon(
            NanoIcons.arrowRight,
            size: theme.size.iconInline,
            color: page < pageCount
                ? theme.colors.textPrimary
                : theme.colors.textDisabled,
          ),
        ),
      ],
    );
  }

  List<NanoPageItem> _pageItems() {
    final out = <NanoPageItem>[];
    final window = <int>{
      for (var p = page - siblings; p <= page + siblings; p++)
        if (p >= 1 && p <= pageCount) p,
      1,
      pageCount,
    }.toList()..sort();
    var previous = 0;
    for (final p in window) {
      if (previous != 0 && p - previous > 1) out.add(NanoPageItem.ellipsis);
      out.add(NanoPageItem('$p', value: p));
      previous = p;
    }
    return out;
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoPaginationSpec = NanoComponentSpec(
  name: 'NanoPagination',
  description: 'Pagination controls; page changes dispatch actionId.',
  propsSchema: {
    'pageCount': {'type': 'number'},
    'page': {'type': 'number'},
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  return NanoPagination(
    pageCount: (node.props['pageCount'] as num?)?.toInt() ?? 10,
    page: (node.props['page'] as num?)?.toInt() ?? 1,
    onChanged: node.actionId == null
        ? null
        : (_) => scope.dispatch(node.actionId!),
  );
}
