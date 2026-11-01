import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// One entry of a [NanoTimeline].
class NanoTimelineItem {
  const NanoTimelineItem({
    required this.title,
    this.description,
    this.time,
    this.highlight = false,
  });

  final String title;
  final String? description;

  /// Right-aligned timestamp, e.g. `'15:42'`.
  final String? time;

  /// Renders the marker filled instead of outlined.
  final bool highlight;
}

/// Vertical event list — shadcn `Timeline`: markers on a continuous rail
/// with title, description and timestamp.
class NanoTimeline extends StatelessWidget {
  const NanoTimeline({super.key, required this.items});

  final List<NanoTimelineItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Marker column: dot + rail.
                SizedBox(
                  width: theme.size.iconStatus,
                  child: Column(
                    children: [
                      Container(
                        width: theme.size.indicatorDot,
                        height: theme.size.indicatorDot,
                        margin: EdgeInsets.only(
                          top: theme.spacing.stackDefault,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: items[i].highlight
                              ? theme.colors.actionPrimaryBackground
                              : theme.colors.surface,
                          border: Border.all(
                            color: items[i].highlight
                                ? theme.colors.actionPrimaryBackground
                                : theme.colors.borderStrong,
                            width: theme.borders.controlWidth,
                          ),
                        ),
                      ),
                      if (i < items.length - 1)
                        Expanded(
                          child: Center(
                            child: Container(
                              width: theme.borders.dividerWidth,
                              color: theme.colors.border,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: theme.spacing.inlineIconLabel),
                // Content column.
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: i < items.length - 1
                          ? theme.spacing.stackDefault
                          : 0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              NanoText(
                                items[i].title,
                                role: NanoTextRole.labelAction,
                              ),
                              if (items[i].description != null) ...[
                                SizedBox(
                                  height: theme.spacing.stackLabelContent / 2,
                                ),
                                NanoText(
                                  items[i].description!,
                                  role: NanoTextRole.bodySupporting,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (items[i].time != null)
                          NanoText(
                            items[i].time!,
                            role: NanoTextRole.labelMetadata,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoTimelineSpec = NanoComponentSpec(
  name: 'NanoTimeline',
  description: 'Vertical event list with markers on a rail.',
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
