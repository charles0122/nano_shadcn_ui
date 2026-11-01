import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import '../theme/nano_theme.dart';

/// The shared interactive base for all tappable nano components.
///
/// Wires up, once, what Material used to give for free:
/// * `WidgetState` tracking (hovered / pressed / focused / disabled) via
///   [WidgetStatesController],
/// * keyboard activation (Space / Enter) through `Shortcuts` + `Actions`,
/// * button semantics,
/// * motion-token-driven press feedback (scale).
class NanoInteractive extends StatefulWidget {
  const NanoInteractive({
    super.key,
    required this.builder,
    this.onTap,
    this.enabled = true,
    this.semanticsLabel,
    this.mouseCursor,
  });

  /// Rebuilds whenever interaction states change.
  final Widget Function(BuildContext context, Set<WidgetState> states) builder;

  final VoidCallback? onTap;
  final bool enabled;
  final String? semanticsLabel;
  final MouseCursor? mouseCursor;

  @override
  State<NanoInteractive> createState() => _NanoInteractiveState();
}

class _NanoInteractiveState extends State<NanoInteractive> {
  final WidgetStatesController _states = WidgetStatesController();
  bool _pressed = false;

  bool get _effectiveEnabled => widget.enabled && widget.onTap != null;

  void _set(WidgetState state, bool active) {
    final value = Set.of(_states.value);
    active ? value.add(state) : value.remove(state);
    _states.value = value;
  }

  @override
  void initState() {
    super.initState();
    if (!widget.enabled) _set(WidgetState.disabled, true);
  }

  @override
  void didUpdateWidget(covariant NanoInteractive oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) {
      _set(WidgetState.disabled, !widget.enabled);
    }
  }

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  void _handleTap() => widget.onTap?.call();

  @override
  Widget build(BuildContext context) {
    final motion = NanoTheme.of(context, aspect: NanoThemeAspect.motion).motion;
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (ActivateIntent intent) {
              if (_effectiveEnabled) _handleTap();
              return null;
            },
          ),
        },
        child: FocusableActionDetector(
          enabled: _effectiveEnabled,
          mouseCursor:
              widget.mouseCursor ??
              (_effectiveEnabled
                  ? SystemMouseCursors.click
                  : MouseCursor.defer),
          onShowHoverHighlight: (hovered) => _set(WidgetState.hovered, hovered),
          onShowFocusHighlight: (focused) => _set(WidgetState.focused, focused),
          child: GestureDetector(
            onTap: _effectiveEnabled ? _handleTap : null,
            onTapDown: (_) {
              setState(() => _pressed = true);
              _set(WidgetState.pressed, true);
            },
            onTapUp: (_) {
              setState(() => _pressed = false);
              _set(WidgetState.pressed, false);
            },
            onTapCancel: () {
              setState(() => _pressed = false);
              _set(WidgetState.pressed, false);
            },
            child: Semantics(
              button: true,
              enabled: _effectiveEnabled,
              label: widget.semanticsLabel,
              child: AnimatedScale(
                scale: _pressed ? 0.97 : 1.0,
                duration: motion.durationFast,
                curve: motion.curveStandard,
                child: ListenableBuilder(
                  listenable: _states,
                  builder: (context, _) =>
                      widget.builder(context, Set.of(_states.value)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
