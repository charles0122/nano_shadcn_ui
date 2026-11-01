import 'package:flutter/widgets.dart';
import 'package:nano_shadcn_ui/nano_shadcn_ui.dart';

import '../gallery_kit.dart';

// --- Accordion --------------------------------------------------------------

Widget accordionPage(BuildContext context) {
  return DemoSection(
    title: 'Accordion',
    description:
        'Disclosure list with animated sections. One open at a time '
        'by default; pass multiple for independent toggles.',
    align: AlignmentDirectional.centerStart,
    child: NanoAccordion(
      items: [
        NanoAccordionItem(
          value: 'a',
          title: 'Is it accessible?',
          child: const NanoText(
            'Yes — every trigger is a real button with keyboard activation '
            'through the shared interactive base.',
            role: NanoTextRole.bodySupporting,
          ),
        ),
        NanoAccordionItem(
          value: 'b',
          title: 'Is it token-driven?',
          child: const NanoText(
            'Borders, radii and motion all resolve from the theme at build '
            'time; there are no baked-in colors.',
            role: NanoTextRole.bodySupporting,
          ),
        ),
        NanoAccordionItem(
          value: 'c',
          title: 'Can it render from JSON?',
          child: NanoRenderer(
            node: const NanoNode(
              type: 'NanoText',
              props: {
                'text': 'Yes — the accordion registers a spec in the component registry.',
                'role': 'bodySupporting',
              },
            ),
          ),
        ),
      ],
    ),
  );
}

// --- Aspect ratio -----------------------------------------------------------

Widget aspectRatioPage(BuildContext context) {
  final theme = NanoTheme.of(context);
  return DemoSection(
    title: 'Aspect Ratio',
    description: 'Letterboxed content at a fixed ratio — 16:9 here.',
    child: SizedBox(
      width: 400,
      child: NanoAspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: theme.colors.surfaceSubtle,
          alignment: Alignment.center,
          child: NanoIcon(
            NanoIcons.image,
            size: theme.size.iconDecorative,
            color: theme.colors.textSecondary,
          ),
        ),
      ),
    ),
  );
}

// --- Card -------------------------------------------------------------------

Widget cardPage(BuildContext context) {
  final theme = NanoTheme.of(context);
  return DemoSection(
    title: 'Card',
    description: 'Raised surface with header/content/footer parts.',
    align: AlignmentDirectional.centerStart,
    child: SizedBox(
      width: 380,
      child: NanoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NanoCardHeader(
              title: 'Create project',
              description: 'Deploy your new project in one click.',
              action: NanoIcon(
                NanoIcons.folder,
                size: theme.size.iconStatus,
                color: theme.colors.textSecondary,
              ),
            ),
            SizedBox(height: theme.spacing.stackDefault),
            NanoInput(
              label: 'Name',
              placeholder: 'Name of your project',
              fillWidth: true,
            ),
            SizedBox(height: theme.spacing.stackDefault),
            NanoCardFooter(
              children: [
                NanoButton(
                  label: 'Cancel',
                  variant: NanoButtonVariant.outline,
                  size: NanoButtonSize.compact,
                  onPressed: () {},
                ),
                NanoButton(
                  label: 'Deploy',
                  size: NanoButtonSize.compact,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// --- Collapsible ------------------------------------------------------------

Widget collapsiblePage(BuildContext context) {
  return DemoSection(
    title: 'Collapsible',
    description: 'A single disclosure toggle with a rotating chevron.',
    align: AlignmentDirectional.centerStart,
    child: SizedBox(
      width: 320,
      child: NanoCollapsible(
        trigger: const NanoText(
          ' starred@nano.dev',
          role: NanoTextRole.labelAction,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const NanoText('nano@zcode.dev', role: NanoTextRole.bodySupporting),
            const NanoText(
              'tokens@nano.dev',
              role: NanoTextRole.bodySupporting,
            ),
          ],
        ),
      ),
    ),
  );
}

// --- Item -------------------------------------------------------------------

Widget itemPage(BuildContext context) {
  final theme = NanoTheme.of(context);
  return DemoSection(
    title: 'Item',
    description: 'Surface rows composed of media, content and actions.',
    align: AlignmentDirectional.centerStart,
    child: SizedBox(
      width: 420,
      child: Column(
        children: [
          NanoItem(
            onTap: () {},
            child: Row(
              children: [
                NanoItemMedia(
                  child: NanoIcon(
                    NanoIcons.creditCard,
                    size: theme.size.iconInline,
                    color: theme.colors.textSecondary,
                  ),
                ),
                SizedBox(width: theme.spacing.inlineIconLabel),
                const NanoItemContent(
                  title: 'Update payment method',
                  description: 'Expires 12/2026 · Visa ending in 4242',
                ),
                const NanoItemActions(
                  children: [
                    NanoBadge('Default', variant: NanoBadgeVariant.secondary),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: theme.spacing.stackDefault),
          NanoItem(
            variant: NanoItemVariant.outline,
            onTap: () {},
            child: Row(
              children: [
                NanoItemMedia(
                  child: NanoIcon(
                    NanoIcons.mail,
                    size: theme.size.iconInline,
                    color: theme.colors.textSecondary,
                  ),
                ),
                SizedBox(width: theme.spacing.inlineIconLabel),
                const NanoItemContent(
                  title: 'Billing email',
                  description: 'billing@nano.dev',
                ),
                NanoItemActions(
                  children: [
                    NanoIcon(
                      NanoIcons.chevronRight,
                      size: theme.size.iconInline,
                      color: theme.colors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// --- Resizable --------------------------------------------------------------

Widget resizablePage(BuildContext context) {
  Widget pane(String label) =>
      Center(child: NanoText(label, role: NanoTextRole.labelMetadata));
  return DemoSection(
    title: 'Resizable',
    description: 'Drag the handle to re-partition the panes.',
    child: NanoResizable(
      height: 200,
      first: pane('One'),
      second: NanoResizable(
        direction: Axis.vertical,
        height: double.infinity,
        first: pane('Two'),
        second: pane('Three'),
      ),
    ),
  );
}

// --- Scroll area ------------------------------------------------------------

Widget scrollAreaPage(BuildContext context) {
  final theme = NanoTheme.of(context);
  return DemoSection(
    title: 'Scroll Area',
    description:
        'Native-feeling overlay scrollbar drawn from border tokens; '
        'hover to reveal, drag to scroll.',
    child: NanoScrollArea(
      height: 200,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 1; i <= 20; i++)
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: theme.spacing.stackDefault / 2,
                ),
                child: NanoText(
                  'Item $i — jasper williams',
                  role: NanoTextRole.body,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

// --- Separator --------------------------------------------------------------

Widget separatorPage(BuildContext context) {
  final theme = NanoTheme.of(context);
  return DemoSection(
    title: 'Separator',
    description: 'Hairline divider in the default border color.',
    child: SizedBox(
      width: 320,
      child: Column(
        children: [
          const NanoText('nano_ui', role: NanoTextRole.labelAction),
          const NanoText(
            'Token-first design system for Flutter.',
            role: NanoTextRole.bodySupporting,
          ),
          SizedBox(height: theme.spacing.stackDefault),
          const NanoSeparator(),
          SizedBox(height: theme.spacing.stackDefault),
          Row(
            children: [
              const NanoText('Blog', role: NanoTextRole.body),
              SizedBox(width: theme.spacing.inlineActions),
              const NanoText('Docs', role: NanoTextRole.body),
              SizedBox(width: theme.spacing.inlineActions),
              const NanoText('Source', role: NanoTextRole.body),
            ],
          ),
        ],
      ),
    ),
  );
}

// --- Sidebar (embedded demo) ------------------------------------------------

Widget sidebarPage(BuildContext context) {
  final theme = NanoTheme.of(context);
  return DemoSection(
    title: 'Sidebar',
    description:
        'Collapsible navigation rail — the same component this gallery '
        'runs on. Click the panel icon in its header to collapse.',
    child: Container(
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(theme.radius.surfaceCard),
        border: Border.all(
          color: theme.colors.border,
          width: theme.borders.controlWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: NanoSidebar(
        expandedWidth: 220,
        activeId: 'inbox',
        onItemTap: (_) {},
        header: Row(
          children: [
            NanoIcon(
              NanoIcons.house,
              size: theme.size.iconDefault,
              color: theme.colors.textPrimary,
            ),
            SizedBox(width: theme.spacing.inlineIconLabel),
            const NanoText('Acme Inc', role: NanoTextRole.labelAction),
          ],
        ),
        groups: [
          const NanoSidebarGroup(
            items: [
              NanoSidebarItem(
                id: 'inbox',
                label: 'Inbox',
                icon: NanoIcons.inbox,
                badge: '12',
              ),
              NanoSidebarItem(
                id: 'calendar',
                label: 'Calendar',
                icon: NanoIcons.calendar,
              ),
              NanoSidebarItem(
                id: 'search',
                label: 'Search',
                icon: NanoIcons.search,
              ),
            ],
          ),
          const NanoSidebarGroup(
            label: 'Settings',
            items: [
              NanoSidebarItem(
                id: 'profile',
                label: 'Profile',
                icon: NanoIcons.user,
              ),
              NanoSidebarItem(
                id: 'logout',
                label: 'Log out',
                icon: NanoIcons.logOut,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// --- Tabs -------------------------------------------------------------------

class _TabsDemo extends StatefulWidget {
  const _TabsDemo();

  @override
  State<_TabsDemo> createState() => _TabsDemoState();
}

class _TabsDemoState extends State<_TabsDemo> {
  String _tab = 'account';

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return NanoTabs<String>(
      value: _tab,
      onChanged: (v) => setState(() => _tab = v),
      tabs: [
        NanoTab(
          value: 'account',
          label: 'Account',
          contentBuilder: (context) => SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const NanoInput(
                  label: 'Name',
                  placeholder: 'Ada Lovelace',
                  fillWidth: true,
                ),
                SizedBox(height: theme.spacing.stackDefault),
                const NanoInput(
                  label: 'Email',
                  placeholder: 'ada@nano.dev',
                  fillWidth: true,
                ),
                SizedBox(height: theme.spacing.stackDefault),
                const NanoButton(
                  label: 'Save changes',
                  size: NanoButtonSize.compact,
                ),
              ],
            ),
          ),
        ),
        NanoTab(
          value: 'password',
          label: 'Password',
          contentBuilder: (context) => SizedBox(
            width: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NanoInput(
                  label: 'New password',
                  placeholder: '••••••••',
                  obscureText: true,
                  fillWidth: true,
                ),
                SizedBox(height: theme.spacing.stackDefault),
                const NanoText(
                  'Use at least 8 characters.',
                  role: NanoTextRole.bodySupporting,
                ),
                SizedBox(height: theme.spacing.stackDefault),
                const NanoButton(
                  label: 'Change password',
                  size: NanoButtonSize.compact,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget tabsPage(BuildContext context) {
  return const DemoSection(
    title: 'Tabs',
    description: 'Segmented switcher with lazily built content panes.',
    align: AlignmentDirectional.centerStart,
    child: _TabsDemo(),
  );
}
