import 'package:flutter/widgets.dart';

import '../registry/nano_registry.dart';
import '../theme/nano_theme.dart';
import '../foundation/nano_form_scope.dart';
import 'nano_text.dart';

/// Single-line (or multiline) text input built directly on the core
/// `EditableText` — no Material. Border, radius, colors and heights are all
/// token-driven: `border.width.control.*` / `color.border.focus` /
/// `radii.control.input` / `size.control.height.*`.
///
/// [prefix]/[suffix] host the Input Group recipe (icon, shortcut, button);
/// [maxLines] > 1 turns the field into a textarea.
class NanoInput extends StatefulWidget {
  const NanoInput({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.placeholder,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.hasError = false,
    this.fillWidth = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Rendered above the field in the `Label.Metadata` role.
  final String? label;
  final String? placeholder;

  /// Widget rendered before the text, inside the field (input group).
  final Widget? prefix;

  /// Widget rendered after the text, inside the field (input group).
  final Widget? suffix;

  /// 1 = single line; null or >1 = multiline textarea.
  final int? maxLines;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Danger border driven by the enclosing form item.
  final bool hasError;
  final bool fillWidth;

  @override
  State<NanoInput> createState() => _NanoInputState();
}

class _NanoInputState extends State<NanoInput> {
  TextEditingController? _ownedController;
  FocusNode? _ownedFocusNode;
  bool _hovered = false;

  TextEditingController get _controller =>
      widget.controller ?? (_ownedController ??= TextEditingController());
  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void dispose() {
    _ownedController?.dispose();
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final colors = theme.colors;
    final enabled = widget.enabled;
    final focused = _focusNode.hasFocus;
    final multiline = widget.maxLines == null || widget.maxLines! > 1;
    final hasError =
        widget.hasError ||
        (NanoFormFieldScope.maybeOf(context)?.hasError ?? false);

    final Color borderColor;
    if (hasError && enabled) {
      borderColor = colors.danger.foreground;
    } else if (focused && enabled) {
      borderColor = colors.borderFocus;
    } else if (_hovered && enabled) {
      borderColor = colors.borderStrong;
    } else {
      borderColor = colors.border;
    }
    final borderWidth = focused && enabled && !hasError
        ? theme.borders.controlFocusWidth
        : theme.borders.controlWidth;

    final field = GestureDetector(
      onTap: enabled ? () => _focusNode.requestFocus() : null,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: theme.motion.durationFast,
          curve: theme.motion.curveStandard,
          constraints: BoxConstraints(
            minHeight: multiline
                ? theme.size.controlHeightLarge * 1.6
                : theme.size.controlHeightDefault,
            minWidth: theme.size.controlHeightDefault,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.insetControl,
            vertical: multiline ? theme.spacing.insetControl / 2 : 0,
          ),
          decoration: BoxDecoration(
            color: enabled ? theme.colors.surface : theme.colors.surfaceSubtle,
            borderRadius: BorderRadius.circular(theme.radius.controlInput),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: ListenableBuilder(
            listenable: Listenable.merge([_controller, _focusNode]),
            builder: (context, _) {
              final showPlaceholder = _controller.text.isEmpty;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.prefix != null) ...[
                    widget.prefix!,
                    SizedBox(width: theme.spacing.inlineIconLabel / 2),
                  ],
                  Expanded(
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        if (showPlaceholder && widget.placeholder != null)
                          Text(
                            widget.placeholder!,
                            style: theme.type.bodyDefault.copyWith(
                              color: colors.textDisabled,
                            ),
                            maxLines: widget.maxLines,
                          ),
                        ExcludeSemantics(
                          child: EditableText(
                            controller: _controller,
                            focusNode: _focusNode,
                            readOnly: !enabled,
                            maxLines: widget.maxLines,
                            minLines: widget.maxLines,
                            expands: false,
                            obscureText: widget.obscureText,
                            style: theme.type.bodyDefault.copyWith(
                              color: enabled
                                  ? colors.textPrimary
                                  : colors.textDisabled,
                            ),
                            cursorColor: colors.accent,
                            backgroundCursorColor: colors.border,
                            keyboardType: widget.keyboardType,
                            onChanged: widget.onChanged,
                            onSubmitted: widget.onSubmitted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.suffix != null) ...[
                    SizedBox(width: theme.spacing.inlineIconLabel / 2),
                    widget.suffix!,
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );

    if (widget.label == null && widget.fillWidth) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          NanoText(widget.label!, role: NanoTextRole.labelMetadata),
          SizedBox(height: theme.spacing.stackLabelContent / 2),
        ],
        widget.fillWidth
            ? SizedBox(width: double.infinity, child: field)
            : field,
      ],
    );
  }
}

/// Registry contract: creates its own controller; value is not serializable.
const NanoComponentSpec nanoInputSpec = NanoComponentSpec(
  name: 'NanoInput',
  description:
      'Single-line text input. Focus ring uses border.focus tokens; '
      'disabled state uses the disabled colors.',
  propsSchema: {
    'label': {'type': 'string'},
    'placeholder': {'type': 'string'},
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  return NanoInput(
    label: node.props['label'] as String?,
    placeholder: node.props['placeholder'] as String?,
  );
}
