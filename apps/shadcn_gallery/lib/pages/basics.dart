import 'package:flutter/widgets.dart';
import 'package:nano_ui/nano_ui.dart';

import '../gallery_kit.dart';

Widget introductionPage(BuildContext context) {
  final theme = NanoTheme.of(context);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DemoSection(
        title: 'Tokens are the constitution',
        description:
            'This gallery renders the shadcn/ui component vocabulary on the '
            'nano token pipeline. Every color, radius and shadow below comes '
            'from a W3C DTCG token tree — switch the theme in the sidebar '
            'footer and the same components re-render.',
        child: Wrap(
          spacing: theme.spacing.inlineActions,
          runSpacing: theme.spacing.stackDefault,
          children: [
            NanoButton(label: 'Primary', onPressed: () {}),
            NanoButton(
              label: 'Secondary',
              variant: NanoButtonVariant.secondary,
              onPressed: () {},
            ),
            NanoButton(
              label: 'Destructive',
              variant: NanoButtonVariant.destructive,
              onPressed: () {},
            ),
            NanoButton(
              label: 'Outline',
              variant: NanoButtonVariant.outline,
              onPressed: () {},
            ),
            NanoButton(
              label: 'Ghost',
              variant: NanoButtonVariant.ghost,
              onPressed: () {},
            ),
            NanoButton(
              label: 'Link',
              variant: NanoButtonVariant.link,
              onPressed: () {},
            ),
          ],
        ),
      ),
      const SectionGap(),
      DemoSection(
        title: '80 theme combinations',
        description:
            'Brand (Zinc, Red, Rose, Orange, Green, Blue, Yellow, Violet) × '
            'SemanticColor (Light, Dark) × SemanticRadii (0–1rem). The '
            'generator resolves every combination; the app loads one combo '
            'JSON at a time and drives NanoAnimatedTheme with it.',
        align: AlignmentDirectional.centerStart,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final entry in {
              'action.primary.background.default':
                  'color.action.primary.background.default',
              'border.focus (ring)': 'color.border.focus',
              'status.danger.foreground': 'color.status.danger.foreground',
            }.entries)
              Padding(
                padding: EdgeInsets.only(
                  bottom: theme.spacing.stackDefault / 2,
                ),
                child: Row(
                  children: [
                    _Swatch(path: entry.value),
                    SizedBox(width: theme.spacing.inlineIconLabel),
                    NanoText(entry.key, role: NanoTextRole.body),
                  ],
                ),
              ),
          ],
        ),
      ),
      const SectionGap(),
      DemoSection(
        title: 'Agent-ready by construction',
        description:
            'Declarative components also render from JSON through the '
            'component registry — the path A2UI/GenUI will take.',
        child: NanoRenderer(
          node: const NanoNode(
            type: 'NanoCard',
            props: {'elevated': true},
            children: [
              NanoNode(
                type: 'NanoText',
                props: {'text': 'Rendered from a JSON tree', 'role': 'h4'},
              ),
              NanoNode(
                type: 'NanoStatusBanner',
                props: {
                  'message': 'Same tokens, same renderer, no Dart required.',
                  'status': 'success',
                },
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final color = switch (path) {
      'color.action.primary.background.default' =>
        theme.colors.actionPrimaryBackground,
      'color.border.focus' => theme.colors.borderFocus,
      _ => theme.colors.danger.foreground,
    };
    return Container(
      width: theme.size.iconDefault,
      height: theme.size.iconDefault,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colors.border,
          width: theme.borders.controlWidth,
        ),
      ),
    );
  }
}

Widget typographyPage(BuildContext context) {
  final theme = NanoTheme.of(context);
  const rows = [
    ('Display Hero', NanoTextRole.displayHero, 'Display'),
    ('Display Metric', NanoTextRole.displayMetric, '96.2'),
    ('Display Compact', NanoTextRole.displayCompact, 'Display'),
    ('Heading 1', NanoTextRole.h1, 'The quick brown fox'),
    ('Heading 2', NanoTextRole.h2, 'The quick brown fox'),
    ('Heading 3', NanoTextRole.h3, 'The quick brown fox jumps'),
    ('Heading 4', NanoTextRole.h4, 'The quick brown fox jumps'),
    ('Heading 5', NanoTextRole.h5, 'The quick brown fox jumps over'),
    (
      'Heading 6',
      NanoTextRole.h6,
      'The quick brown fox jumps over the lazy dog',
    ),
    (
      'Body Default',
      NanoTextRole.body,
      '每个 token 都有来源,每个像素都有出处。Body text carries the primary foreground role.',
    ),
    (
      'Body Reading',
      NanoTextRole.bodyReading,
      '长文阅读字号与舒适行高,用于 prose 场景。Reading text is sized for long-form paragraphs.',
    ),
    (
      'Body Supporting',
      NanoTextRole.bodySupporting,
      '辅助说明文字,次级颜色由角色决定。Supporting text resolves to the secondary color.',
    ),
    ('Label Action', NanoTextRole.labelAction, 'Label'),
    ('Label Metadata', NanoTextRole.labelMetadata, 'Metadata'),
    ('Label Navigation', NanoTextRole.labelNavigation, 'Navigation'),
  ];
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DemoSection(
        title: 'DTCG.Type.* scale',
        description:
            'Fifteen typographic roles, Geist-first with automatic '
            'fallback to the platform font.',
        align: AlignmentDirectional.centerStart,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (_, role, text) in rows) ...[
              NanoText(text, role: role),
              SizedBox(height: theme.spacing.stackDefault),
            ],
          ],
        ),
      ),
    ],
  );
}
