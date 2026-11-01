import 'package:flutter/widgets.dart';

import '../registry/nano_registry.dart';
import '../theme/nano_theme.dart';

/// Keyboard-key chip — shadcn `Kbd`: muted fill, hairline border, mono-ish
/// metadata text. The tight 4px padding is the kbd geometry (px-1.5).
class NanoKbd extends StatelessWidget {
  const NanoKbd(this.keys, {super.key});

  /// One or more key names, e.g. `['⌘']` or `['Ctrl', 'Shift', 'P']`.
  final List<String> keys;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(theme.radius.controlDefault / 2),
        border: Border.all(
          color: theme.colors.border,
          width: theme.borders.controlWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colors.shadow.withAlpha(96),
            offset: const Offset(0, 1),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        keys.join(' '),
        style: theme.type.labelMetadata.copyWith(
          color: theme.colors.textSecondary,
        ),
        maxLines: 1,
      ),
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoKbdSpec = NanoComponentSpec(
  name: 'NanoKbd',
  description: 'Keyboard-key chip in a muted surface.',
  propsSchema: {
    'keys': {'type': 'string', 'description': 'Space-separated key names.'},
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  final raw = (node.props['keys'] as String?) ?? '';
  return NanoKbd(raw.isEmpty ? const [] : raw.split(' '));
}
