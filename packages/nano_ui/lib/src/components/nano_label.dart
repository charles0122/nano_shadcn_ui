import 'package:flutter/widgets.dart';

import '../registry/nano_registry.dart';
import 'nano_text.dart';

/// Form label — shadcn `Label`: `Label.Action` type role with the disabled
/// dim handled by the parent control. Tapping it can request focus on the
/// labeled control by wiring [onTap].
class NanoLabel extends StatelessWidget {
  const NanoLabel(this.text, {super.key, this.onTap, this.color});

  final String text;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final label = NanoText(text, role: NanoTextRole.labelAction, color: color);
    return onTap == null
        ? label
        : GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: label,
          );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoLabelSpec = NanoComponentSpec(
  name: 'NanoLabel',
  description: 'Medium-weight form label text.',
  propsSchema: {
    'text': {'type': 'string'},
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  return NanoLabel((node.props['text'] as String?) ?? '');
}
