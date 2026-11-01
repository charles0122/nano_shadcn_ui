import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// One expandable section of a [NanoAccordion].
class NanoAccordionItem {
  const NanoAccordionItem({
    required this.value,
    required this.title,
    required this.child,
  });

  final String value;
  final String title;
  final Widget child;
}

/// Disclosure list — shadcn `Accordion`: hairline-separated rows, rotating
/// chevron, animated height. One open section at a time unless [multiple].
class NanoAccordion extends StatefulWidget {
  const NanoAccordion({
    super.key,
    required this.items,
    this.multiple = false,
    this.initiallyOpen = const [],
  });

  final List<NanoAccordionItem> items;
  final bool multiple;
  final List<String> initiallyOpen;

  @override
  State<NanoAccordion> createState() => _NanoAccordionState();
}

class _NanoAccordionState extends State<NanoAccordion> {
  late final Set<String> _open = Set.of(widget.initiallyOpen);

  void _toggle(String value) {
    setState(() {
      if (widget.multiple) {
        _open.contains(value) ? _open.remove(value) : _open.add(value);
      } else {
        final wasOpen = _open.contains(value);
        _open.clear();
        if (!wasOpen) _open.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
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
          for (var i = 0; i < widget.items.length; i++) ...[
            if (i > 0)
              Container(
                height: theme.borders.dividerWidth,
                color: theme.colors.border,
              ),
            _AccordionRow(
              item: widget.items[i],
              open: _open.contains(widget.items[i].value),
              onToggle: () => _toggle(widget.items[i].value),
            ),
          ],
        ],
      ),
    );
  }
}

class _AccordionRow extends StatelessWidget {
  const _AccordionRow({
    required this.item,
    required this.open,
    required this.onToggle,
  });

  final NanoAccordionItem item;
  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NanoInteractive(
          onTap: onToggle,
          builder: (context, states) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacing.insetCard,
                vertical: theme.spacing.insetControl,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: NanoText(
                      item.title,
                      role: NanoTextRole.labelAction,
                      color: theme.colors.textPrimary,
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: theme.motion.durationBase,
                    curve: theme.motion.curveStandard,
                    child: NanoIcon(
                      NanoIcons.chevronDown,
                      size: theme.size.iconInline,
                      color: theme.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        AnimatedCrossFade(
          duration: theme.motion.durationBase,
          sizeCurve: theme.motion.curveStandard,
          crossFadeState: open
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: EdgeInsets.only(
              left: theme.spacing.insetCard,
              right: theme.spacing.insetCard,
              bottom: theme.spacing.insetControl,
            ),
            child: item.child,
          ),
        ),
      ],
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoAccordionSpec = NanoComponentSpec(
  name: 'NanoAccordion',
  description: 'Expandable disclosure list; children render inside sections.',
  propsSchema: {},
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  final theme = NanoTheme.of(context);
  return NanoAccordion(
    items: [
      NanoAccordionItem(
        value: 'section',
        title: (node.props['title'] as String?) ?? 'Section',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final child in node.children) ...[
              scope.renderChild(context, child),
              SizedBox(height: theme.spacing.stackDefault),
            ],
          ],
        ),
      ),
    ],
  );
}
