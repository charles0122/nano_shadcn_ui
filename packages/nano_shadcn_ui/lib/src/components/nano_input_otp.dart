import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// One-time-code input — shadcn `Input OTP`: fixed number of cells, auto
/// advance, backspace to retract, group gap every three cells.
class NanoInputOTP extends StatefulWidget {
  const NanoInputOTP({
    super.key,
    this.length = 6,
    this.value = '',
    this.onChanged,
    this.onCompleted,
    this.enabled = true,
  });

  final int length;

  /// Current code (plain characters, no separators).
  final String value;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool enabled;

  @override
  State<NanoInputOTP> createState() => _NanoInputOTPState();
}

class _NanoInputOTPState extends State<NanoInputOTP> {
  late final FocusNode _focusNode = FocusNode(onKeyEvent: _handleKey);
  String get _chars {
    final v = widget.value.characters.take(widget.length).join();
    return v;
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.backspace) {
      if (_chars.isNotEmpty) {
        widget.onChanged?.call(_chars.substring(0, _chars.length - 1));
      }
      return KeyEventResult.handled;
    }
    final char = key.keyLabel;
    if (char.length == 1 &&
        RegExp(r'[0-9a-zA-Z]').hasMatch(char) &&
        _chars.length < widget.length) {
      final next = _chars + char;
      widget.onChanged?.call(next);
      if (next.length == widget.length) widget.onCompleted?.call(next);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final focusedIndex = _chars.length.clamp(0, widget.length - 1);
    final cellHeight = theme.size.controlHeightLarge;
    final cellWidth = cellHeight * 0.82;
    final cellRadius = theme.radius.controlInput;

    return Focus(
      focusNode: _focusNode,
      canRequestFocus: widget.enabled,
      child: GestureDetector(
        onTap: widget.enabled ? () => _focusNode.requestFocus() : null,
        behavior: HitTestBehavior.opaque,
        child: Semantics(
          textField: true,
          value: _chars,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < widget.length; i++) ...[
                if (i > 0 && i % 3 == 0)
                  SizedBox(width: theme.spacing.inlineIconLabel),
                _OTPCell(
                  char: i < _chars.length ? _chars[i] : null,
                  focused: widget.enabled && i == focusedIndex,
                  height: cellHeight,
                  width: cellWidth,
                  radius: cellRadius,
                  theme: theme,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _OTPCell extends StatelessWidget {
  const _OTPCell({
    required this.char,
    required this.focused,
    required this.height,
    required this.width,
    required this.radius,
    required this.theme,
  });

  final String? char;
  final bool focused;
  final double height;
  final double width;
  final double radius;
  final NanoThemeData theme;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: theme.motion.durationFast,
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: focused ? theme.colors.borderFocus : theme.colors.border,
          width: focused
              ? theme.borders.controlFocusWidth
              : theme.borders.controlWidth,
        ),
      ),
      child: char == null
          ? null
          : Text(
              char!,
              style: theme.type.headingH4.copyWith(
                color: theme.colors.textPrimary,
              ),
            ),
    );
  }
}

/// Registry contract: value is not serializable.
const NanoComponentSpec nanoInputOTPSpec = NanoComponentSpec(
  name: 'NanoInputOTP',
  description: 'One-time-code input with per-character cells.',
  propsSchema: {
    'length': {'type': 'number'},
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  return NanoInputOTP(length: (node.props['length'] as num?)?.toInt() ?? 6);
}
