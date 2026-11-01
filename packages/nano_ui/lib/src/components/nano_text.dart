import 'package:flutter/widgets.dart';

import '../registry/nano_registry.dart';
import '../theme/nano_theme.dart';

/// Semantic text roles backed by the `DTCG.Type.*` typography tokens.
enum NanoTextRole {
  displayHero,
  displayMetric,
  displayCompact,
  h1,
  h2,
  h3,
  h4,
  h5,
  h6,
  body,
  bodyReading,
  bodySupporting,
  labelAction,
  labelMetadata,
  labelNavigation,
}

class NanoText extends StatelessWidget {
  const NanoText(
    this.text, {
    super.key,
    this.role = NanoTextRole.body,
    this.color,
  });

  final String text;
  final NanoTextRole role;

  /// Overrides the role's default color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context, aspect: NanoThemeAspect.typography);
    final colors = NanoTheme.of(context, aspect: NanoThemeAspect.colors).colors;
    var style = switch (role) {
      NanoTextRole.displayHero => theme.type.displayHero,
      NanoTextRole.displayMetric => theme.type.displayMetric,
      NanoTextRole.displayCompact => theme.type.displayCompact,
      NanoTextRole.h1 => theme.type.headingH1,
      NanoTextRole.h2 => theme.type.headingH2,
      NanoTextRole.h3 => theme.type.headingH3,
      NanoTextRole.h4 => theme.type.headingH4,
      NanoTextRole.h5 => theme.type.headingH5,
      NanoTextRole.h6 => theme.type.headingH6,
      NanoTextRole.body => theme.type.bodyDefault,
      NanoTextRole.bodyReading => theme.type.bodyReading,
      NanoTextRole.bodySupporting => theme.type.bodySupporting,
      NanoTextRole.labelAction => theme.type.labelAction,
      NanoTextRole.labelMetadata => theme.type.labelMetadata,
      NanoTextRole.labelNavigation => theme.type.labelNavigation,
    };
    final defaultColor = switch (role) {
      NanoTextRole.bodySupporting ||
      NanoTextRole.labelMetadata ||
      NanoTextRole.labelNavigation => colors.textSecondary,
      _ => colors.textPrimary,
    };
    style = style.copyWith(color: color ?? defaultColor);
    return Text(text, style: style);
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoTextSpec = NanoComponentSpec(
  name: 'NanoText',
  description: 'Styled text. Roles map to the typography token scale.',
  propsSchema: {
    'text': {'type': 'string'},
    'role': {
      'type': 'enum',
      'values': [
        'displayHero',
        'displayMetric',
        'displayCompact',
        'h1',
        'h2',
        'h3',
        'h4',
        'h5',
        'h6',
        'body',
        'bodyReading',
        'bodySupporting',
        'labelAction',
        'labelMetadata',
        'labelNavigation',
      ],
    },
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  final role = NanoTextRole.values.firstWhere(
    (r) => r.name == node.props['role'],
    orElse: () => NanoTextRole.body,
  );
  return NanoText((node.props['text'] as String?) ?? '', role: role);
}
