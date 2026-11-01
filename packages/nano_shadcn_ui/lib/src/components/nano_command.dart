import 'package:flutter/services.dart'
    show KeyDownEvent, KeyRepeatEvent, LogicalKeyboardKey;
import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

import 'nano_menu.dart';

/// One command palette row.
class NanoCommandItem {
  const NanoCommandItem({
    required this.label,
    this.group,
    this.icon,
    this.shortcut,
    this.keywords = const [],
    this.onSelect,
    this.enabled = true,
  });

  final String label;

  /// Optional group heading rows are derived from this.
  final String? group;
  final NanoIconData? icon;
  final List<String>? shortcut;
  final List<String> keywords;
  final VoidCallback? onSelect;
  final bool enabled;
}

/// Command palette body — shadcn `Command` (cmdk): search field, grouped
/// filtered list, Up/Down + Enter keyboard navigation, empty state.
/// Wrap it in a dialog via [showNanoCommandDialog] or embed inline.
class NanoCommand extends StatefulWidget {
  const NanoCommand({
    super.key,
    required this.items,
    this.placeholder = 'Type a command or search…',
    this.emptyLabel = 'No results found.',
    this.maxHeight = 320,
  });

  final List<NanoCommandItem> items;
  final String placeholder;
  final String emptyLabel;
  final double maxHeight;

  @override
  State<NanoCommand> createState() => _NanoCommandState();
}

class _NanoCommandState extends State<NanoCommand> {
  final TextEditingController _query = TextEditingController();
  final FocusNode _fieldFocus = FocusNode();
  final FocusNode _listFocus = FocusNode(onKeyEvent: _noop);
  int _highlight = 0;

  static KeyEventResult _noop(FocusNode node, KeyEvent event) =>
      KeyEventResult.ignored;

  @override
  void dispose() {
    _query.dispose();
    _fieldFocus.dispose();
    _listFocus.dispose();
    super.dispose();
  }

  List<NanoCommandItem> get _filtered {
    final q = _query.text.trim().toLowerCase();
    final items = widget.items.where((item) => item.enabled).where((item) {
      if (q.isEmpty) return true;
      return item.label.toLowerCase().contains(q) ||
          item.keywords.any((k) => k.toLowerCase().contains(q)) ||
          (item.group?.toLowerCase().contains(q) ?? false);
    }).toList();
    if (_highlight >= items.length)
      _highlight = items.isEmpty ? 0 : items.length - 1;
    return items;
  }

  void _run(int index, List<NanoCommandItem> items) {
    if (index < 0 || index >= items.length) return;
    final item = items[index];
    if (item.onSelect == null) return;
    Navigator.of(context, rootNavigator: true).maybePop();
    item.onSelect!();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final items = _filtered;
    if (items.isEmpty) return KeyEventResult.ignored;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowDown:
        setState(() => _highlight = (_highlight + 1) % items.length);
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        setState(
          () => _highlight = (_highlight - 1 + items.length) % items.length,
        );
        return KeyEventResult.handled;
      case LogicalKeyboardKey.enter || LogicalKeyboardKey.numpadEnter:
        _run(_highlight, items);
        return KeyEventResult.handled;
      default:
        return KeyEventResult.ignored;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final items = _filtered;

    // Grouped rows in first-seen group order, ungrouped first.
    final rows = <Widget>[];
    String? currentGroup;
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final group = item.group;
      if (group != currentGroup) {
        currentGroup = group;
        if (group != null) {
          if (rows.isNotEmpty)
            rows.add(SizedBox(height: theme.spacing.stackDefault / 2));
          rows.add(NanoMenuSeparatorView());
          rows.add(
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacing.insetControl / 2,
                vertical: theme.spacing.stackDefault / 2,
              ),
              child: NanoText(group, role: NanoTextRole.labelMetadata),
            ),
          );
        }
      }
      final highlighted = i == _highlight;
      rows.add(
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (_) {
            if (_highlight != i) setState(() => _highlight = i);
          },
          child: GestureDetector(
            onTap: () => _run(i, items),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: theme.size.controlHeightCompact,
              padding: EdgeInsets.symmetric(
                horizontal: theme.spacing.insetControl / 2,
              ),
              decoration: BoxDecoration(
                color: highlighted ? theme.colors.surfaceSubtle : null,
                borderRadius: BorderRadius.circular(
                  theme.radius.controlDefault / 2,
                ),
              ),
              child: Row(
                children: [
                  if (item.icon != null) ...[
                    NanoIcon(
                      item.icon!,
                      size: theme.size.iconInline,
                      color: theme.colors.textSecondary,
                    ),
                    SizedBox(width: theme.spacing.inlineIconLabel / 2),
                  ],
                  Expanded(
                    child: Text(
                      item.label,
                      style: theme.type.bodyDefault.copyWith(
                        color: theme.colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.shortcut != null)
                    Padding(
                      padding: EdgeInsets.only(
                        left: theme.spacing.inlineIconLabel,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final key in item.shortcut!)
                            Padding(
                              padding: EdgeInsets.only(
                                left: theme.spacing.stackDefault / 4,
                              ),
                              child: Text(
                                key,
                                style: theme.type.labelMetadata.copyWith(
                                  color: theme.colors.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Focus(
      focusNode: _listFocus,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: NanoSurfacePanel(
        padding: EdgeInsets.all(theme.spacing.stackDefault / 2),
        minWidth: null,
        maxWidth: 512,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NanoInput(
              controller: _query,
              focusNode: _fieldFocus,
              placeholder: widget.placeholder,
              prefix: NanoIcon(
                NanoIcons.search,
                size: theme.size.iconInline,
                color: theme.colors.textSecondary,
              ),
              onChanged: (_) => setState(() => _highlight = 0),
              fillWidth: true,
            ),
            SizedBox(height: theme.spacing.stackDefault / 2),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: widget.maxHeight),
              child: SingleChildScrollView(
                child: items.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: theme.spacing.insetCard,
                          horizontal: theme.spacing.insetControl,
                        ),
                        child: NanoText(
                          widget.emptyLabel,
                          role: NanoTextRole.bodySupporting,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: rows,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ⌘K style dialog hosting a [NanoCommand].
class NanoCommandDialog {
  NanoCommandDialog._();

  static NanoOverlayController show(
    BuildContext context, {
    required List<NanoCommandItem> items,
    String? placeholder,
  }) {
    return showNanoOverlay(
      context,
      variant: NanoOverlayVariant.dialog,
      scrimColor: NanoTheme.of(context).colors.scrim.withAlpha(150),
      builder: (overlayContext) => NanoCommand(
        items: items,
        placeholder: placeholder ?? 'Type a command or search…',
      ),
    );
  }
}
