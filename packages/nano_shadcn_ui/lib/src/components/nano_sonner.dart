import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Toast visual kind. Colors map onto the `color.status.*` triads.
enum NanoToastVariant { neutral, danger, success, warning, info }

/// A queued toast — created through [NanoToast.show].
class NanoToastEntry {
  NanoToastEntry({
    required this.title,
    this.description,
    this.variant = NanoToastVariant.neutral,
    this.duration = const Duration(seconds: 4),
  });

  final String title;
  final String? description;
  final NanoToastVariant variant;
  final Duration duration;

  Timer? _timer;
  int _generation = 0;

  void _startTimer(VoidCallback onExpire) {
    _timer?.cancel();
    _generation++;
    final generation = _generation;
    _timer = Timer(duration, () {
      if (_generation == generation) onExpire();
    });
  }

  /// Hovering pauses the countdown; leaving resumes it.
  void pause() => _timer?.cancel();

  void resume(VoidCallback onExpire) => _startTimer(onExpire);

  void dispose() => _timer?.cancel();
}

/// Toast host — mount once near the app root. Pushes the toast stack into
/// the root overlay's bottom-end corner (the Sonner position), above dialogs.
class NanoToaster extends StatefulWidget {
  const NanoToaster({super.key, required this.child});

  final Widget child;

  @override
  State<NanoToaster> createState() => NanoToasterState();
}

class NanoToasterState extends State<NanoToaster> {
  final List<NanoToastEntry> _toasts = [];
  OverlayEntry? _entry;

  /// Composition, not a `with ChangeNotifier` mixin: mixing it into a State
  /// makes `super.dispose()` resolve to the mixin and skip State.dispose.
  final _ToastChanges _changes = _ToastChanges();

  /// Enqueues a toast. [anchorContext] is the caller's context — the host
  /// itself sits above the navigator, so the root overlay is reached through
  /// the caller instead.
  void push(NanoToastEntry entry, {BuildContext? anchorContext}) {
    _toasts.add(entry);
    while (_toasts.length > 5) {
      _toasts.removeAt(0);
    }
    entry._startTimer(() => remove(entry));
    _ensureEntry(anchorContext);
    _changes.notify();
  }

  void remove(NanoToastEntry entry) {
    entry.dispose();
    if (_toasts.remove(entry)) _changes.notify();
  }

  void _ensureEntry(BuildContext? anchorContext) {
    if (_entry != null) return;
    final overlayContext = anchorContext ?? (mounted ? context : null);
    if (overlayContext == null || !overlayContext.mounted) return;
    final overlay = Overlay.of(overlayContext, rootOverlay: true);
    _entry = OverlayEntry(
      builder: (overlayContext) => ListenableBuilder(
        listenable: _changes,
        builder: (context, _) => _ToastStack(toasts: _toasts, host: this),
      ),
    );
    overlay.insert(_entry!);
  }

  @override
  void dispose() {
    // The root overlay may already have torn the entry down with the tree —
    // removing twice throws, which would skip the notifier cleanup below.
    if (_entry != null && _entry!.mounted) {
      _entry!.remove();
    }
    _entry = null;
    for (final t in _toasts) {
      t.dispose();
    }
    _changes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Imperative toast API — `NanoToast.show(context, title: 'Saved')`.
abstract final class NanoToast {
  static void show(
    BuildContext context, {
    required String title,
    String? description,
    NanoToastVariant variant = NanoToastVariant.neutral,
    Duration duration = const Duration(seconds: 4),
  }) {
    final state = context.findAncestorStateOfType<NanoToasterState>();
    state?.push(
      NanoToastEntry(
        title: title,
        description: description,
        variant: variant,
        duration: duration,
      ),
      anchorContext: context,
    );
  }
}

/// ChangeNotifier subclass so [notifyListeners] stays inside its subclass.
class _ToastChanges extends ChangeNotifier {
  void notify() => notifyListeners();
}

class _ToastStack extends StatelessWidget {
  const _ToastStack({required this.toasts, required this.host});

  final List<NanoToastEntry> toasts;
  final NanoToasterState host;

  @override
  Widget build(BuildContext context) {
    if (toasts.isEmpty) return const SizedBox.shrink();
    final theme = NanoTheme.of(context);
    return Positioned(
      right: theme.spacing.gutterGrid,
      bottom: theme.spacing.gutterGrid,
      width: 356,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final toast in toasts) _ToastCard(toast: toast, host: host),
        ],
      ),
    );
  }
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({required this.toast, required this.host});

  final NanoToastEntry toast;
  final NanoToasterState host;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final colors = theme.colors;
    final accent = switch (toast.variant) {
      NanoToastVariant.neutral => colors.borderStrong,
      NanoToastVariant.danger => colors.danger.foreground,
      NanoToastVariant.success => colors.success.foreground,
      NanoToastVariant.warning => colors.warning.foreground,
      NanoToastVariant.info => colors.info.foreground,
    };
    return Padding(
      padding: EdgeInsets.only(top: theme.spacing.stackDefault / 2),
      child: MouseRegion(
        onEnter: (_) => toast.pause(),
        onExit: (_) => toast.resume(() => host.remove(toast)),
        child: Container(
          padding: EdgeInsets.all(theme.spacing.insetControl),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(theme.radius.controlInput),
            border: Border.all(
              color: colors.border,
              width: theme.borders.controlWidth,
            ),
            boxShadow: theme.elevation.floating,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: theme.borders.controlFocusWidth,
                height: theme.size.controlHeightCompact - 4,
                margin: EdgeInsets.only(right: theme.spacing.inlineIconLabel),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(theme.radius.pill),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NanoText(toast.title, role: NanoTextRole.labelAction),
                    if (toast.description != null) ...[
                      SizedBox(height: theme.spacing.stackLabelContent / 2),
                      NanoText(
                        toast.description!,
                        role: NanoTextRole.bodySupporting,
                      ),
                    ],
                  ],
                ),
              ),
              NanoInteractive(
                onTap: () => host.remove(toast),
                builder: (context, states) {
                  final hovered = states.contains(WidgetState.hovered);
                  return Container(
                    width: theme.size.iconDefault,
                    height: theme.size.iconDefault,
                    decoration: BoxDecoration(
                      color: hovered ? colors.surfaceSubtle : null,
                      borderRadius: BorderRadius.circular(
                        theme.radius.controlDefault / 2,
                      ),
                    ),
                    child: Center(
                      child: NanoIcon(
                        NanoIcons.x,
                        size: theme.size.iconInline,
                        color: colors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
