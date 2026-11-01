import 'package:flutter/widgets.dart';

import 'package:nano_ui/nano_ui.dart';

/// Searchable select — shadcn `Combobox`: a select trigger that opens a
/// filterable command list; optional multi-select with check marks.
class NanoCombobox<T> extends StatefulWidget {
  const NanoCombobox({
    super.key,
    required this.items,
    required this.values,
    required this.onChanged,
    this.placeholder = 'Select…',
    this.searchPlaceholder = 'Search…',
    this.multiple = false,
    this.enabled = true,
    this.emptyLabel = 'No option found.',
  });

  final List<NanoComboboxItem<T>> items;

  /// Selected value(s) — a list even in single-select mode.
  final List<T> values;
  final ValueChanged<List<T>> onChanged;
  final String placeholder;
  final String searchPlaceholder;
  final bool multiple;
  final bool enabled;
  final String emptyLabel;

  @override
  State<NanoCombobox<T>> createState() => _NanoComboboxState<T>();
}

class NanoComboboxItem<T> {
  const NanoComboboxItem({required this.value, required this.label});

  final T value;
  final String label;
}

class _NanoComboboxState<T> extends State<NanoCombobox<T>>
    with NanoOverlayHost {
  void _toggle() {
    if (isOverlayOpen) {
      closeOverlay();
      return;
    }
    openOverlay(
      triggerContext: context,
      contentBuilder: (overlayContext) {
        final theme = NanoTheme.of(overlayContext);
        return NanoSurfacePanel(
          minWidth: null,
          maxWidth: 360,
          padding: EdgeInsets.all(theme.spacing.stackDefault / 2),
          child: _ComboboxBody<T>(widget: widget, state: this),
        );
      },
      matchTriggerWidth: true,
    );
  }

  void _select(T value) {
    final values = List.of(widget.values);
    if (widget.multiple) {
      values.contains(value) ? values.remove(value) : values.add(value);
    } else {
      values
        ..clear()
        ..add(value);
      closeOverlay();
    }
    widget.onChanged(values);
  }

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final labels = [
      for (final item in widget.items)
        if (widget.values.contains(item.value)) item.label,
    ];
    final text = widget.multiple
        ? (labels.isEmpty ? widget.placeholder : labels.join(', '))
        : (labels.isEmpty ? widget.placeholder : labels.first);

    return GestureDetector(
      onTap: widget.enabled ? _toggle : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: theme.size.controlHeightDefault,
        padding: EdgeInsets.symmetric(horizontal: theme.spacing.insetControl),
        decoration: BoxDecoration(
          color: widget.enabled
              ? theme.colors.surface
              : theme.colors.surfaceSubtle,
          borderRadius: BorderRadius.circular(theme.radius.controlInput),
          border: Border.all(
            color: isOverlayOpen
                ? theme.colors.borderFocus
                : theme.colors.border,
            width: isOverlayOpen
                ? theme.borders.controlFocusWidth
                : theme.borders.controlWidth,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: theme.type.bodyDefault.copyWith(
                  color: labels.isEmpty
                      ? theme.colors.textDisabled
                      : theme.colors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: theme.spacing.inlineIconLabel / 2),
            NanoIcon(
              NanoIcons.chevronsUpDown,
              size: theme.size.iconInline,
              color: theme.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ComboboxBody<T> extends StatefulWidget {
  const _ComboboxBody({required this.widget, required this.state});

  final NanoCombobox<T> widget;
  final _NanoComboboxState<T> state;

  @override
  State<_ComboboxBody<T>> createState() => _ComboboxBodyState<T>();
}

class _ComboboxBodyState<T> extends State<_ComboboxBody<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final combobox = widget.widget;
    final q = _query.trim().toLowerCase();
    final items = combobox.items
        .where((i) => q.isEmpty || i.label.toLowerCase().contains(q))
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NanoInput(
          placeholder: combobox.searchPlaceholder,
          prefix: NanoIcon(
            NanoIcons.search,
            size: theme.size.iconInline,
            color: theme.colors.textSecondary,
          ),
          onChanged: (v) => setState(() => _query = v),
          fillWidth: true,
        ),
        SizedBox(height: theme.spacing.stackDefault / 2),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: theme.size.controlHeightDefault * 6,
          ),
          child: SingleChildScrollView(
            child: items.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: theme.spacing.insetCard,
                    ),
                    child: NanoText(
                      combobox.emptyLabel,
                      role: NanoTextRole.bodySupporting,
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < items.length; i++)
                        _optionRow(context, theme, items[i]),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _optionRow(
    BuildContext context,
    NanoThemeData theme,
    NanoComboboxItem<T> item,
  ) {
    final selected = widget.widget.values.contains(item.value);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.state._select(item.value),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: theme.size.controlHeightCompact,
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.insetControl / 2,
          ),
          child: Row(
            children: [
              SizedBox(
                width: theme.size.iconInline,
                child: selected
                    ? NanoIcon(
                        NanoIcons.check,
                        size: theme.size.iconInline,
                        color: theme.colors.textPrimary,
                      )
                    : null,
              ),
              SizedBox(width: theme.spacing.inlineIconLabel / 2),
              Expanded(
                child: Text(
                  item.label,
                  style: theme.type.bodyDefault.copyWith(
                    color: theme.colors.textPrimary,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
