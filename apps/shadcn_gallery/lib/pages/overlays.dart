import 'package:flutter/widgets.dart';
import 'package:nano_shadcn_ui/nano_shadcn_ui.dart';

import '../gallery_kit.dart';

// --- Dialog -----------------------------------------------------------------

class _DialogDemo extends StatelessWidget {
  const _DialogDemo();

  @override
  Widget build(BuildContext context) {
    return NanoButton(
      label: 'Edit profile',
      onPressed: () => NanoDialog.show(
        context,
        builder: (dialogContext) => NanoDialogPanel(
          onClose: () => NanoOverlayScope.of(dialogContext)?.close(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NanoDialogHeader(
                title: 'Edit profile',
                description:
                    'Make changes to your profile here. '
                    'Click save when you are done.',
              ),
              SizedBox(
                height: NanoTheme.of(dialogContext).spacing.stackDefault,
              ),
              const NanoInput(
                label: 'Name',
                placeholder: 'Ada Lovelace',
                fillWidth: true,
              ),
              SizedBox(
                height: NanoTheme.of(dialogContext).spacing.stackDefault,
              ),
              const NanoInput(
                label: 'Email',
                placeholder: 'ada@nano.dev',
                fillWidth: true,
              ),
              SizedBox(
                height: NanoTheme.of(dialogContext).spacing.stackSections,
              ),
              NanoDialogFooter(
                children: [
                  NanoButton(
                    label: 'Cancel',
                    variant: NanoButtonVariant.outline,
                    size: NanoButtonSize.compact,
                    onPressed: () =>
                        NanoOverlayScope.of(dialogContext)?.close(),
                  ),
                  NanoButton(
                    label: 'Save changes',
                    size: NanoButtonSize.compact,
                    onPressed: () {
                      NanoOverlayScope.of(dialogContext)?.close();
                      NanoToast.show(
                        dialogContext,
                        title: 'Profile saved',
                        variant: NanoToastVariant.success,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Alert dialog ------------------------------------------------------------

class _AlertDialogDemo extends StatelessWidget {
  const _AlertDialogDemo();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        NanoButton(
          label: 'Show dialog',
          variant: NanoButtonVariant.outline,
          onPressed: () => NanoAlertDialog.show(
            context,
            title: 'Delete workspace?',
            description:
                'This action cannot be undone. All tokens and '
                'components in this workspace will be removed.',
            confirmLabel: 'Delete',
            destructive: true,
            onConfirm: () => NanoToast.show(
              context,
              title: 'Workspace deleted',
              variant: NanoToastVariant.danger,
            ),
          ),
        ),
      ],
    );
  }
}

// --- Sheet & drawer -----------------------------------------------------------

class _SheetDemo extends StatelessWidget {
  const _SheetDemo();

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        NanoButton(
          label: 'Right sheet',
          variant: NanoButtonVariant.outline,
          onPressed: () => NanoSheet.show(
            context,
            builder: (sheetContext) => NanoSheetPanel(
              header: const NanoDialogHeader(
                title: 'Settings',
                description: 'Change preferences for this workspace.',
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const NanoText(
                    'Sheets trap focus and close on Escape or '
                    'scrim tap.',
                    role: NanoTextRole.bodySupporting,
                  ),
                  SizedBox(height: theme.spacing.stackDefault),
                  const NanoSwitch(value: true),
                ],
              ),
            ),
          ),
        ),
        NanoButton(
          label: 'Bottom sheet',
          variant: NanoButtonVariant.outline,
          onPressed: () => NanoSheet.show(
            context,
            side: NanoOverlayVariant.sheetBottom,
            builder: (sheetContext) => NanoSheetPanel(
              side: NanoOverlayVariant.sheetBottom,
              header: const NanoDialogHeader(title: 'Share'),
              child: const NanoText(
                'Drag down or tap the scrim to dismiss.',
                role: NanoTextRole.bodySupporting,
              ),
            ),
          ),
        ),
        // Drawer: side sheet with drag-to-fling.
        NanoButton(
          label: 'Drawer (drag to close)',
          variant: NanoButtonVariant.outline,
          onPressed: () {
            NanoSheet.show(
              context,
              side: NanoOverlayVariant.sheetStart,
              width: 320,
              builder: (sheetContext) => NanoSheetDraggable(
                axis: Axis.horizontal,
                negative: true,
                onDismiss: () => NanoOverlayScope.of(sheetContext)?.close(),
                child: NanoSheetPanel(
                  side: NanoOverlayVariant.sheetStart,
                  header: const NanoDialogHeader(
                    title: 'Drawer',
                    description: 'Fling the panel left to close.',
                  ),
                  child: const NanoText(
                    'The vaul-style drag gesture closes the panel with '
                    'velocity past the threshold.',
                    role: NanoTextRole.bodySupporting,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// --- Dropdown menu -------------------------------------------------------------

class _DropdownDemo extends StatelessWidget {
  const _DropdownDemo();

  @override
  Widget build(BuildContext context) {
    return NanoDropdownMenu(
      label: 'Open',
      items: [
        const NanoMenuLabelEntry('Actions'),
        NanoMenuItemEntry(
          label: 'Duplicate',
          icon: NanoIcons.copy,
          shortcut: const ['⌘', 'D'],
          onSelect: () => NanoToast.show(context, title: 'Duplicated'),
        ),
        NanoMenuItemEntry(
          label: 'Archive',
          icon: NanoIcons.folder,
          onSelect: () => NanoToast.show(context, title: 'Archived'),
        ),
        const NanoMenuItemEntry(label: 'Unavailable', enabled: false),
        const NanoMenuSeparator(),
        NanoMenuItemEntry(
          label: 'Delete',
          icon: NanoIcons.trash,
          shortcut: const ['⌘', '⌫'],
          destructive: true,
          onSelect: () => NanoToast.show(
            context,
            title: 'Deleted',
            variant: NanoToastVariant.danger,
          ),
        ),
        const NanoMenuSeparator(),
        const NanoMenuSubmenu(
          label: 'Export as',
          icon: NanoIcons.externalLink,
          items: [
            NanoMenuItemEntry(label: 'JSON'),
            NanoMenuItemEntry(label: 'SVG'),
            NanoMenuItemEntry(label: 'PDF'),
          ],
        ),
      ],
    );
  }
}

// --- Context menu -------------------------------------------------------------

class _ContextMenuDemo extends StatelessWidget {
  const _ContextMenuDemo();

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return NanoContextMenu(
      items: [
        NanoMenuItemEntry(
          label: 'Back',
          icon: NanoIcons.arrowLeft,
          shortcut: const ['⌘', '['],
          onSelect: () {},
        ),
        NanoMenuItemEntry(
          label: 'Forward',
          icon: NanoIcons.arrowRight,
          shortcut: const ['⌘', ']'],
          enabled: false,
        ),
        const NanoMenuSeparator(),
        NanoMenuItemEntry(
          label: 'Reload',
          icon: NanoIcons.refreshCw,
          onSelect: () {},
        ),
        const NanoMenuSeparator(),
        NanoMenuItemEntry(
          label: 'Inspect',
          icon: NanoIcons.search,
          destructive: true,
          onSelect: () {},
        ),
      ],
      child: Container(
        width: 320,
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colors.surfaceSubtle,
          borderRadius: BorderRadius.circular(theme.radius.controlInput),
          border: Border.all(
            color: theme.colors.border,
            width: theme.borders.controlWidth,
          ),
        ),
        child: const NanoText(
          'Right click here',
          role: NanoTextRole.bodySupporting,
        ),
      ),
    );
  }
}

// --- Menubar -----------------------------------------------------------------

class _MenubarDemo extends StatelessWidget {
  const _MenubarDemo();

  @override
  Widget build(BuildContext context) {
    return NanoMenubar(
      menus: [
        NanoMenubarMenu(
          label: 'File',
          items: [
            NanoMenuItemEntry(
              label: 'New Tab',
              shortcut: const ['⌘', 'T'],
              onSelect: () {},
            ),
            NanoMenuItemEntry(
              label: 'New Window',
              shortcut: const ['⌘', 'N'],
              onSelect: () {},
            ),
            const NanoMenuSeparator(),
            NanoMenuItemEntry(
              label: 'Share…',
              icon: NanoIcons.externalLink,
              onSelect: () {},
            ),
          ],
        ),
        NanoMenubarMenu(
          label: 'Edit',
          items: [
            NanoMenuItemEntry(
              label: 'Undo',
              shortcut: const ['⌘', 'Z'],
              onSelect: () {},
            ),
            NanoMenuItemEntry(
              label: 'Redo',
              shortcut: const ['⇧', '⌘', 'Z'],
              enabled: false,
            ),
            const NanoMenuSeparator(),
            NanoMenuItemEntry(
              label: 'Find',
              icon: NanoIcons.search,
              shortcut: const ['⌘', 'F'],
              onSelect: () {},
            ),
          ],
        ),
        NanoMenubarMenu(
          label: 'View',
          items: [
            NanoMenuItemEntry(label: 'Toggle Sidebar', onSelect: () {}),
            NanoMenuItemEntry(label: 'Toggle Full Screen', onSelect: () {}),
          ],
        ),
      ],
    );
  }
}

// --- Popover -----------------------------------------------------------------

class _PopoverDemo extends StatelessWidget {
  const _PopoverDemo();

  @override
  Widget build(BuildContext context) {
    return NanoPopover(
      contentBuilder: (context) {
        final theme = NanoTheme.of(context);
        return SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const NanoText('Dimensions', role: NanoTextRole.labelAction),
              SizedBox(height: theme.spacing.stackDefault),
              const NanoInput(
                label: 'Width',
                placeholder: '100%',
                fillWidth: true,
              ),
              SizedBox(height: theme.spacing.stackDefault),
              const NanoInput(
                label: 'Height',
                placeholder: '25%',
                fillWidth: true,
              ),
              SizedBox(height: theme.spacing.stackDefault),
              const NanoText(
                'Set the dimensions the content should be '
                'clipped to.',
                role: NanoTextRole.bodySupporting,
              ),
            ],
          ),
        );
      },
      child: const NanoButton(
        label: 'Open popover',
        variant: NanoButtonVariant.outline,
      ),
    );
  }
}

// --- Tooltip -----------------------------------------------------------------

class _TooltipDemo extends StatelessWidget {
  const _TooltipDemo();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        NanoTooltip(
          message: 'Hover tooltip — inverted surface',
          child: const NanoButton(
            label: 'Hover me',
            variant: NanoButtonVariant.outline,
          ),
        ),
      ],
    );
  }
}

// --- Hover card --------------------------------------------------------------

class _HoverCardDemo extends StatelessWidget {
  const _HoverCardDemo();

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return NanoHoverCard(
      contentBuilder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const NanoAvatar('AL', size: NanoAvatarSize.compact),
              SizedBox(width: theme.spacing.inlineIconLabel),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NanoText('@ada', role: NanoTextRole.labelAction),
                    NanoText('Ada Lovelace', role: NanoTextRole.labelMetadata),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacing.stackDefault),
          const NanoText(
            'Primary author of the DTCG pipeline. Tokens are the constitution.',
            role: NanoTextRole.bodySupporting,
          ),
        ],
      ),
      child: const NanoButton(label: '@ada', variant: NanoButtonVariant.link),
    );
  }
}

// --- Navigation menu -----------------------------------------------------------

class _NavigationMenuDemo extends StatelessWidget {
  const _NavigationMenuDemo();

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return NanoNavigationMenu(
      entries: [
        NanoNavigationEntry(label: 'Home', onTap: () {}, active: true),
        NanoNavigationEntry(
          label: 'Components',
          panelBuilder: (panelContext) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _navLink(
                    panelContext,
                    'Alert',
                    'Callout with icon and title.',
                  ),
                  _navLink(panelContext, 'Badge', 'Small status pill.'),
                  _navLink(panelContext, 'Button', 'Interactive action.'),
                ],
              ),
              SizedBox(width: theme.spacing.gutterGrid),
              Container(
                width: 160,
                height: 110,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(
                    theme.radius.controlInput,
                  ),
                ),
                child: NanoIcon(
                  NanoIcons.sparkle,
                  size: theme.size.iconDecorative,
                  color: theme.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const NanoNavigationEntry(label: 'Docs', onTap: null),
      ],
    );
  }

  Widget _navLink(BuildContext context, String title, String description) {
    final theme = NanoTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: theme.spacing.stackDefault),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NanoText(title, role: NanoTextRole.labelAction),
            SizedBox(height: theme.spacing.stackLabelContent / 4),
            NanoText(description, role: NanoTextRole.labelMetadata),
          ],
        ),
      ),
    );
  }
}

// --- Sonner -----------------------------------------------------------------

class _SonnerDemo extends StatelessWidget {
  const _SonnerDemo();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        NanoButton(
          label: 'Neutral',
          variant: NanoButtonVariant.outline,
          onPressed: () => NanoToast.show(
            context,
            title: 'Event created',
            description: 'Monday, October 31 · 4:00 PM',
          ),
        ),
        NanoButton(
          label: 'Success',
          variant: NanoButtonVariant.outline,
          onPressed: () => NanoToast.show(
            context,
            title: 'Saved',
            description: 'All changes synced.',
            variant: NanoToastVariant.success,
          ),
        ),
        NanoButton(
          label: 'Danger',
          variant: NanoButtonVariant.outline,
          onPressed: () => NanoToast.show(
            context,
            title: 'Deployment failed',
            description: 'Check the build logs for details.',
            variant: NanoToastVariant.danger,
          ),
        ),
      ],
    );
  }
}

Widget dialogPage(BuildContext context) {
  return const DemoSection(
    title: 'Dialog',
    description: 'Scrim, centered panel, focus trap, Escape + scrim dismiss.',
    child: _DialogDemo(),
  );
}

Widget alertDialogPage(BuildContext context) {
  return const DemoSection(
    title: 'Alert Dialog',
    description: 'Requires an explicit decision — the scrim does not dismiss.',
    child: _AlertDialogDemo(),
  );
}

Widget sheetPage(BuildContext context) {
  return const DemoSection(
    title: 'Sheet & Drawer',
    description: 'Side and bottom panels; the drawer adds fling-to-close.',
    child: _SheetDemo(),
  );
}

Widget dropdownMenuPage(BuildContext context) {
  return const DemoSection(
    title: 'Dropdown Menu',
    description:
        'Labels, shortcuts, disabled and destructive items, '
        'submenus.',
    child: _DropdownDemo(),
  );
}

Widget contextMenuPage(BuildContext context) {
  return const DemoSection(
    title: 'Context Menu',
    description: 'Secondary-tap menu at the pointer position.',
    child: _ContextMenuDemo(),
  );
}

Widget menubarPage(BuildContext context) {
  return const DemoSection(
    title: 'Menubar',
    description: 'Horizontal bar — hovering another label swaps menus.',
    child: _MenubarDemo(),
  );
}

Widget popoverPage(BuildContext context) {
  return const DemoSection(
    title: 'Popover',
    description: 'Anchored surface panel with arbitrary content.',
    child: _PopoverDemo(),
  );
}

Widget tooltipPage(BuildContext context) {
  return const DemoSection(
    title: 'Tooltip',
    description: 'Hover-triggered inverted label with open delay.',
    child: _TooltipDemo(),
  );
}

Widget hoverCardPage(BuildContext context) {
  return const DemoSection(
    title: 'Hover Card',
    description: 'Rich preview that stays open while the pointer is on it.',
    child: _HoverCardDemo(),
  );
}

Widget navigationMenuPage(BuildContext context) {
  return const DemoSection(
    title: 'Navigation Menu',
    description: 'Horizontal nav with a hover mega-panel.',
    align: AlignmentDirectional.centerStart,
    child: _NavigationMenuDemo(),
  );
}

Widget sonnerPage(BuildContext context) {
  return const DemoSection(
    title: 'Sonner (Toast)',
    description:
        'Bottom-end toast stack with variants, hover-to-pause and '
        'manual dismiss.',
    child: _SonnerDemo(),
  );
}
