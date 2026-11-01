import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Modal dialog — shadcn `Dialog`: scrim, centered surface panel
/// (`radii.surface.dialog` + overlay shadow), Escape / scrim-tap dismiss,
/// focus trapped to the panel.
class NanoDialog {
  NanoDialog._();

  static NanoOverlayController show(
    BuildContext context, {
    required WidgetBuilder builder,
    bool dismissible = true,
    double maxWidth = 512,
  }) {
    return showNanoOverlay(
      context,
      variant: NanoOverlayVariant.dialog,
      barrierDismissible: dismissible,
      contentSize: Size(maxWidth, double.infinity),
      builder: builder,
    );
  }
}

/// Panel chrome for dialog content: surface fill, dialog radius, overlay
/// shadow and card padding. Compose the header/footer yourself.
class NanoDialogPanel extends StatelessWidget {
  const NanoDialogPanel({super.key, required this.child, this.onClose});

  final Widget child;

  /// Shows the close button in the top-end corner.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colors.surface,
        borderRadius: BorderRadius.circular(theme.radius.surfaceDialog),
        border: Border.all(
          color: theme.colors.border,
          width: theme.borders.controlWidth,
        ),
        boxShadow: theme.elevation.overlay,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(theme.spacing.insetCard),
            child: child,
          ),
          if (onClose != null)
            Positioned(
              top: theme.spacing.insetControl,
              right: theme.spacing.insetControl,
              child: NanoInteractive(
                onTap: onClose,
                builder: (context, states) {
                  final hovered = states.contains(WidgetState.hovered);
                  return Container(
                    width: theme.size.controlHeightCompact / 2,
                    height: theme.size.controlHeightCompact / 2,
                    decoration: BoxDecoration(
                      color: hovered ? theme.colors.surfaceSubtle : null,
                      borderRadius: BorderRadius.circular(
                        theme.radius.controlDefault / 2,
                      ),
                    ),
                    child: Center(
                      child: NanoIcon(
                        NanoIcons.x,
                        size: theme.size.iconInline,
                        color: theme.colors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Dialog header: title in `Heading.H4`, description in supporting text.
class NanoDialogHeader extends StatelessWidget {
  const NanoDialogHeader({super.key, required this.title, this.description});

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        NanoText(title, role: NanoTextRole.h4),
        if (description != null) ...[
          SizedBox(height: theme.spacing.stackLabelContent / 2),
          NanoText(description!, role: NanoTextRole.bodySupporting),
        ],
      ],
    );
  }
}

/// Dialog footer: end-aligned actions row.
class NanoDialogFooter extends StatelessWidget {
  const NanoDialogFooter({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: theme.spacing.inlineActions),
          children[i],
        ],
      ],
    );
  }
}

/// Modal confirmation — shadcn `Alert Dialog`: requires an explicit decision
/// (the scrim tap does NOT dismiss), danger-tinted confirm when destructive.
class NanoAlertDialog {
  NanoAlertDialog._();

  static NanoOverlayController show(
    BuildContext context, {
    required String title,
    required String description,
    String cancelLabel = 'Cancel',
    required String confirmLabel,
    bool destructive = false,
    VoidCallback? onConfirm,
  }) {
    final theme = NanoTheme.of(context);
    final controller = showNanoOverlay(
      context,
      variant: NanoOverlayVariant.dialog,
      barrierDismissible: false,
      contentSize: const Size(448, double.infinity),
      builder: (overlayContext) => NanoDialogPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NanoDialogHeader(title: title, description: description),
            SizedBox(height: theme.spacing.stackSections),
            NanoDialogFooter(
              children: [
                NanoButton(
                  label: cancelLabel,
                  variant: NanoButtonVariant.outline,
                  size: NanoButtonSize.compact,
                  onPressed: () => NanoOverlayScope.of(overlayContext)?.close(),
                ),
                _ConfirmButton(
                  label: confirmLabel,
                  destructive: destructive,
                  onPressed: () {
                    NanoOverlayScope.of(overlayContext)?.close();
                    onConfirm?.call();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return controller;
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.label,
    required this.destructive,
    required this.onPressed,
  });

  final String label;
  final bool destructive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return NanoInteractive(
      onTap: onPressed,
      builder: (context, states) {
        final theme = NanoTheme.of(context);
        final colors = theme.colors;
        return Container(
          height: theme.size.controlHeightCompact,
          padding: EdgeInsets.symmetric(horizontal: theme.spacing.insetControl),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: destructive
                ? colors.danger.foreground
                : colors.actionPrimaryBackground,
            borderRadius: BorderRadius.circular(theme.radius.controlButton),
          ),
          child: Text(
            label,
            style: theme.type.labelAction.copyWith(color: colors.onAccent),
          ),
        );
      },
    );
  }
}
