import 'dart:js_interop';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:nano_shadcn_ui/nano_shadcn_ui.dart';

import 'gallery_kit.dart';
import 'main.dart';
import 'pages/pages.dart';

@JS('history.replaceState')
external void _historyReplaceState(JSAny? state, String title, String url);

/// Docs-style application shell: collapsible sidebar, sticky header with the
/// theme customizer, and a scrollable page column — all built from nano_ui
/// components (the shell dogfoods the sidebar it documents).
class GalleryShell extends StatefulWidget {
  const GalleryShell({
    super.key,
    required this.selection,
    required this.manifest,
    required this.onSelectionChanged,
  });

  final ThemeSelection selection;
  final Map<String, Object?> manifest;
  final ValueChanged<ThemeSelection> onSelectionChanged;

  @override
  State<GalleryShell> createState() => _GalleryShellState();
}

class _GalleryShellState extends State<GalleryShell> {
  final GlobalKey<NanoSidebarState> _sidebarKey = GlobalKey();
  final ScrollController _scroll = ScrollController();

  /// Deep link: `#calendar` opens that docs page directly.
  late String _activeId = () {
    final fragment = Uri.base.fragment.replaceFirst('#', '');
    return galleryPages.any((p) => p.id == fragment)
        ? fragment
        : galleryPages.first.id;
  }();

  GalleryPage get _page => galleryPages.firstWhere((p) => p.id == _activeId);

  void _openPage(String id) {
    setState(() => _activeId = id);
    _scroll.jumpTo(0);
    // Keep the hash shareable without polluting history.
    _historyReplaceState(null, '', '#$id');
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyK, meta: true): _CommandIntent(),
        SingleActivator(LogicalKeyboardKey.keyK, control: true):
            _CommandIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _CommandIntent: CallbackAction<_CommandIntent>(
            onInvoke: (_) {
              _openCommandPalette();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Container(
            color: theme.colors.canvas,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NanoSidebar(
                  key: _sidebarKey,
                  activeId: _activeId,
                  onItemTap: _openPage,
                  header: _SidebarHeader(
                    collapsed: false,
                    onToggle: () => _sidebarKey.currentState?.toggle(),
                  ),
                  footer: _SidebarFooter(
                    selection: widget.selection,
                    manifest: widget.manifest,
                    onSelectionChanged: widget.onSelectionChanged,
                  ),
                  groups: [
                    for (final group in galleryGroups)
                      NanoSidebarGroup(
                        label: group,
                        items: [
                          for (final page in galleryPages.where(
                            (p) => p.group == group,
                          ))
                            NanoSidebarItem(
                              id: page.id,
                              label: page.title,
                              icon: pageIcons[page.id] ?? NanoIcons.circle,
                            ),
                        ],
                      ),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header bar.
                      Container(
                        height: theme.size.controlHeightLarge + 16,
                        padding: EdgeInsets.symmetric(
                          horizontal: theme.spacing.gutterGrid,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colors.canvas,
                          border: Border(
                            bottom: BorderSide(
                              color: theme.colors.border,
                              width: theme.borders.controlWidth,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            NanoBreadcrumb(
                              items: [
                                NanoBreadcrumbItem(
                                  'Docs',
                                  onTap: () => _openPage('introduction'),
                                ),
                                NanoBreadcrumbItem(_page.title),
                              ],
                            ),
                            const Spacer(),
                            NanoTooltip(
                              message: 'Search components [⌘K]',
                              child: _HeaderIconButton(
                                icon: NanoIcons.search,
                                onPressed: _openCommandPalette,
                              ),
                            ),
                            SizedBox(width: theme.spacing.inlineActions / 2),
                            NanoTooltip(
                              message: 'Customize theme',
                              child: _ThemeCustomizerButton(
                                selection: widget.selection,
                                manifest: widget.manifest,
                                onSelectionChanged: widget.onSelectionChanged,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Page content.
                      Expanded(
                        child: SingleChildScrollView(
                          controller: _scroll,
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 880),
                              child: Padding(
                                padding: EdgeInsets.all(
                                  theme.spacing.gutterPage,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    NanoText(
                                      _page.title,
                                      role: NanoTextRole.displayCompact,
                                    ),
                                    SizedBox(
                                      height:
                                          theme.spacing.stackLabelContent / 2,
                                    ),
                                    NanoText(
                                      _page.description,
                                      role: NanoTextRole.bodySupporting,
                                    ),
                                    SizedBox(
                                      height: theme.spacing.stackSections,
                                    ),
                                    Builder(
                                      key: ValueKey(_activeId),
                                      builder: _page.builder,
                                    ),
                                    SizedBox(
                                      height: theme.spacing.gutterPage * 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
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

  void _openCommandPalette() {
    NanoCommandDialog.show(
      context,
      placeholder: 'Jump to a component…',
      items: [
        for (final page in galleryPages)
          NanoCommandItem(
            label: page.title,
            group: page.group,
            icon: pageIcons[page.id] ?? NanoIcons.circle,
            keywords: [page.id],
            onSelect: () => _openPage(page.id),
          ),
      ],
    );
  }
}

class _CommandIntent extends Intent {
  const _CommandIntent();
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader({required this.collapsed, required this.onToggle});

  final bool collapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Row(
      children: [
        Container(
          width: theme.size.avatarCompact,
          height: theme.size.avatarCompact,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colors.actionPrimaryBackground,
            borderRadius: BorderRadius.circular(
              theme.radius.controlDefault / 2,
            ),
          ),
          child: NanoIcon(
            NanoIcons.sparkle,
            size: theme.size.iconInline,
            color: theme.colors.actionPrimaryForeground,
          ),
        ),
        SizedBox(width: theme.spacing.inlineIconLabel),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NanoText('shadcn/ui', role: NanoTextRole.labelAction),
              NanoText('× nano_ui', role: NanoTextRole.labelMetadata),
            ],
          ),
        ),
        NanoTooltip(
          message: 'Toggle sidebar',
          child: _HeaderIconButton(
            icon: NanoIcons.panelLeft,
            onPressed: onToggle,
          ),
        ),
      ],
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter({
    required this.selection,
    required this.manifest,
    required this.onSelectionChanged,
  });

  final ThemeSelection selection;
  final Map<String, Object?> manifest;
  final ValueChanged<ThemeSelection> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return NanoPopover(
      contentBuilder: (context) => _ThemeCustomizer(
        selection: selection,
        manifest: manifest,
        onSelectionChanged: onSelectionChanged,
      ),
      placement: NanoPlacement.topStart,
      child: Container(
        width: double.infinity,
        height: theme.size.controlHeightCompact,
        padding: EdgeInsets.symmetric(horizontal: theme.spacing.insetControl),
        alignment: AlignmentDirectional.centerStart,
        decoration: BoxDecoration(
          color: theme.colors.surfaceSubtle,
          borderRadius: BorderRadius.circular(theme.radius.controlDefault / 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NanoIcon(
              NanoIcons.palette,
              size: theme.size.iconInline,
              color: theme.colors.textSecondary,
            ),
            SizedBox(width: theme.spacing.inlineIconLabel / 2),
            NanoText('Customize theme', role: NanoTextRole.labelMetadata),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onPressed});

  final NanoIconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return NanoInteractive(
      onTap: onPressed,
      builder: (context, states) {
        final hovered = states.contains(WidgetState.hovered);
        final focused = states.contains(WidgetState.focused);
        return Container(
          width: theme.size.controlHeightCompact + 4,
          height: theme.size.controlHeightCompact + 4,
          decoration: BoxDecoration(
            color: hovered ? theme.colors.surfaceSubtle : null,
            borderRadius: BorderRadius.circular(
              theme.radius.controlDefault / 2,
            ),
            border: focused
                ? Border.all(
                    color: theme.colors.borderFocus,
                    width: theme.borders.controlFocusWidth,
                  )
                : null,
          ),
          child: Center(
            child: NanoIcon(
              icon,
              size: theme.size.iconDefault,
              color: theme.colors.textPrimary,
            ),
          ),
        );
      },
    );
  }
}

class _ThemeCustomizerButton extends StatelessWidget {
  const _ThemeCustomizerButton({
    required this.selection,
    required this.manifest,
    required this.onSelectionChanged,
  });

  final ThemeSelection selection;
  final Map<String, Object?> manifest;
  final ValueChanged<ThemeSelection> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return NanoPopover(
      contentBuilder: (context) => _ThemeCustomizer(
        selection: selection,
        manifest: manifest,
        onSelectionChanged: onSelectionChanged,
      ),
      child: const _HeaderIconButton(icon: NanoIcons.palette, onPressed: null),
    );
  }
}

/// The shadcn/ui theme customizer: base color dots, light/dark switch and
/// radius select — each maps onto one DTCG theme group.
class _ThemeCustomizer extends StatelessWidget {
  const _ThemeCustomizer({
    required this.selection,
    required this.manifest,
    required this.onSelectionChanged,
  });

  final ThemeSelection selection;
  final Map<String, Object?> manifest;
  final ValueChanged<ThemeSelection> onSelectionChanged;

  static const _brandHex = {
    'Zinc': Color(0xFF18181B),
    'Red': Color(0xFFDC2626),
    'Rose': Color(0xFFE11D48),
    'Orange': Color(0xFFF97316),
    'Green': Color(0xFF16A34A),
    'Blue': Color(0xFF3B82F6),
    'Yellow': Color(0xFFEAB308),
    'Violet': Color(0xFF8B5CF6),
  };

  static const _radiusLabels = {
    'R000': '0',
    'R025': '0.25',
    'R050': '0.5',
    'R075': '0.75',
    'R100': '1.0',
  };

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final groups = manifest['groups'] as Map?;
    final brands =
        (groups?['Brand'] as List?)?.cast<String>() ?? _brandHex.keys.toList();
    final radii =
        (groups?['SemanticRadii'] as List?)?.cast<String>() ??
        _radiusLabels.keys.toList();
    final modes =
        (groups?['SemanticColor'] as List?)?.cast<String>() ??
        const ['Light', 'Dark'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        NanoText('Color', role: NanoTextRole.labelAction),
        SizedBox(height: theme.spacing.stackDefault / 2),
        Wrap(
          spacing: theme.spacing.stackDefault / 2,
          runSpacing: theme.spacing.stackDefault / 2,
          children: [
            for (final brand in brands)
              NanoTooltip(
                message: brand,
                placement: NanoPlacement.bottomCenter,
                child: GestureDetector(
                  onTap: () =>
                      onSelectionChanged(selection.copyWith(brand: brand)),
                  child: Container(
                    width: theme.size.iconDefault,
                    height: theme.size.iconDefault,
                    decoration: BoxDecoration(
                      color: _brandHex[brand] ?? theme.colors.textPrimary,
                      shape: BoxShape.circle,
                      border: selection.brand == brand
                          ? Border.all(
                              color: theme.colors.borderFocus,
                              width: theme.borders.controlFocusWidth,
                            )
                          : Border.all(
                              color: theme.colors.border,
                              width: theme.borders.controlWidth,
                            ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: theme.spacing.stackDefault),
        NanoText('Mode', role: NanoTextRole.labelAction),
        SizedBox(height: theme.spacing.stackDefault / 2),
        Row(
          children: [
            for (final mode in modes)
              Expanded(
                child: NanoToggle(
                  pressed: selection.mode == mode,
                  label: mode,
                  outline: true,
                  onPressed: () =>
                      onSelectionChanged(selection.copyWith(mode: mode)),
                ),
              ),
          ],
        ),
        SizedBox(height: theme.spacing.stackDefault),
        NanoText('Radius', role: NanoTextRole.labelAction),
        SizedBox(height: theme.spacing.stackDefault / 2),
        NanoSelect<String>(
          fillWidth: true,
          items: [
            for (final radius in radii)
              NanoSelectItem(
                value: radius,
                label: _radiusLabels[radius] ?? radius,
              ),
          ],
          value: selection.radius,
          onChanged: (v) => v == null
              ? null
              : onSelectionChanged(selection.copyWith(radius: v)),
        ),
      ],
    );
  }
}
