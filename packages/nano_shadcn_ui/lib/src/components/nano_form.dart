import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Form field composition — shadcn `Form` layout: label, control,
/// description and error message in one vertical rhythm, with the error
/// state handed to the control through [NanoFormFieldScope].
class NanoFormItem extends StatelessWidget {
  const NanoFormItem({
    super.key,
    required this.child,
    this.label,
    this.description,
    this.error,
    this.trailing,
  });

  final Widget child;

  /// Field label above the control.
  final String? label;

  /// Helper text below the control (hidden while an [error] shows).
  final String? description;

  /// Error message; shown in the danger color and pushed into the control.
  final String? error;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final hasError = error != null && error!.isNotEmpty;
    return NanoFormFieldScope(
      hasError: hasError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null || trailing != null)
            Row(
              children: [
                if (label != null)
                  Expanded(
                    child: NanoText(label!, role: NanoTextRole.labelAction),
                  ),
                if (trailing != null) trailing!,
              ],
            ),
          if (label != null || trailing != null)
            SizedBox(height: theme.spacing.stackLabelContent / 2),
          child,
          SizedBox(height: theme.spacing.stackLabelContent / 2),
          if (hasError)
            NanoText(
              error!,
              role: NanoTextRole.labelMetadata,
              color: theme.colors.danger.foreground,
            )
          else if (description != null)
            NanoText(description!, role: NanoTextRole.labelMetadata),
        ],
      ),
    );
  }
}
