import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// One tab of a [NanoTabs]. [contentBuilder] runs lazily on activation.
class NanoTab<T> {
  const NanoTab({
    required this.value,
    required this.label,
    this.contentBuilder,
  });

  final T value;
  final String label;
  final WidgetBuilder? contentBuilder;
}

/// Segmented tab bar + lazy content — shadcn `Tabs`: a muted pill list where
/// the active tab lifts onto the surface color with a raised shadow.
class NanoTabs<T> extends StatelessWidget {
  const NanoTabs({
    super.key,
    required this.tabs,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final List<NanoTab<T>> tabs;
  final T value;
  final ValueChanged<T>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final active = tabs.indexWhere((t) => t.value == value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _TabList(
          tabs: tabs,
          value: value,
          onChanged: onChanged,
          enabled: enabled,
        ),
        if (active != -1 && tabs[active].contentBuilder != null) ...[
          SizedBox(height: theme.spacing.stackDefault),
          Builder(key: ValueKey(value), builder: tabs[active].contentBuilder!),
        ],
      ],
    );
  }
}

class _TabList<T> extends StatelessWidget {
  const _TabList({
    required this.tabs,
    required this.value,
    required this.onChanged,
    required this.enabled,
  });

  final List<NanoTab<T>> tabs;
  final T value;
  final ValueChanged<T>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Container(
      padding: EdgeInsets.all(theme.spacing.stackDefault / 2),
      decoration: BoxDecoration(
        color: theme.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(theme.radius.controlInput),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final tab in tabs)
            NanoInteractive(
              onTap: enabled ? () => onChanged?.call(tab.value) : null,
              enabled: enabled,
              builder: (context, states) {
                final selected = tab.value == value;
                final focused = states.contains(WidgetState.focused);
                return AnimatedContainer(
                  duration: theme.motion.durationFast,
                  curve: theme.motion.curveStandard,
                  padding: EdgeInsets.symmetric(
                    horizontal: theme.spacing.insetControl,
                    vertical: theme.spacing.stackDefault / 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colors.surface
                        : const Color(0x00000000),
                    borderRadius: BorderRadius.circular(
                      theme.radius.controlButton / 2,
                    ),
                    border: focused && !selected
                        ? Border.all(
                            color: theme.colors.borderFocus,
                            width: theme.borders.controlFocusWidth,
                          )
                        : null,
                    boxShadow: selected ? theme.elevation.raised : null,
                  ),
                  child: Text(
                    tab.label,
                    style: theme.type.labelAction.copyWith(
                      color: selected
                          ? theme.colors.textPrimary
                          : theme.colors.textSecondary,
                    ),
                    maxLines: 1,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

/// Underline-style tabs (shadcn underline variant): text triggers with an
/// animated active underline, no content pane.
class NanoTabBar<T> extends StatelessWidget {
  const NanoTabBar({
    super.key,
    required this.tabs,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final List<NanoTab<T>> tabs;
  final T value;
  final ValueChanged<T>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final tab in tabs)
          NanoInteractive(
            onTap: enabled ? () => onChanged?.call(tab.value) : null,
            enabled: enabled,
            builder: (context, states) {
              final selected = tab.value == value;
              return AnimatedContainer(
                duration: theme.motion.durationFast,
                curve: theme.motion.curveStandard,
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing.insetControl,
                  vertical: theme.spacing.stackDefault / 2,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected
                          ? theme.colors.actionPrimaryBackground
                          : const Color(0x00000000),
                      width: theme.borders.controlFocusWidth,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      tab.label,
                      style: theme.type.labelAction.copyWith(
                        color: selected
                            ? theme.colors.textPrimary
                            : theme.colors.textSecondary,
                      ),
                    ),
                    if (selected) ...[
                      SizedBox(width: theme.spacing.inlineIconLabel / 2),
                      NanoIcon(
                        NanoIcons.check,
                        size: theme.size.iconInline,
                        color: theme.colors.textPrimary,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoTabsSpec = NanoComponentSpec(
  name: 'NanoTabs',
  description: 'Segmented tab list; active pane comes from the host app.',
  propsSchema: {
    'tabs': {'type': 'string', 'description': 'Comma-separated labels.'},
    'activeIndex': {'type': 'number'},
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  final labels = ((node.props['tabs'] as String?) ?? '')
      .split(',')
      .where((l) => l.trim().isNotEmpty)
      .toList();
  final activeIndex = (node.props['activeIndex'] as num?)?.toInt() ?? 0;
  return NanoTabBar<int>(
    tabs: [
      for (var i = 0; i < labels.length; i++)
        NanoTab(value: i, label: labels[i]),
    ],
    value: activeIndex,
    onChanged: node.actionId == null
        ? null
        : (_) => scope.dispatch(node.actionId!),
  );
}
