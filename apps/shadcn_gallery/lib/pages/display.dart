import 'package:flutter/widgets.dart';
import 'package:nano_shadcn_ui/nano_shadcn_ui.dart';

import '../gallery_kit.dart';

// --- Alert ------------------------------------------------------------------

Widget alertPage(BuildContext context) {
  return const DemoSection(
    title: 'Alert',
    description:
        'Callout with icon, title and description — neutral and '
        'status triad variants.',
    align: AlignmentDirectional.centerStart,
    child: Column(
      children: [
        NanoAlert(
          title: 'Heads up!',
          description: 'You can compose alerts from the status color triads.',
          icon: NanoIcons.info,
        ),
      ],
    ),
  );
}

class _AlertVariantsDemo extends StatelessWidget {
  const _AlertVariantsDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children:
          [
                const NanoAlert(
                  title: 'Deployment failed',
                  description: 'color.status.danger drove the border and icon.',
                  variant: NanoAlertVariant.danger,
                ),
                const NanoAlert(
                  title: 'All checks passed',
                  description: 'Ready to promote to production.',
                  variant: NanoAlertVariant.success,
                ),
                const NanoAlert(
                  title: 'Approaching quota',
                  description: '80% of your monthly build minutes are used.',
                  variant: NanoAlertVariant.warning,
                ),
                const NanoAlert(
                  title: 'New version available',
                  description: 'Flutter 3.47.9 shipped two days ago.',
                  variant: NanoAlertVariant.info,
                ),
              ]
              .map(
                (w) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: w,
                ),
              )
              .toList(),
    );
  }
}

// --- Avatar -----------------------------------------------------------------

class _AvatarDemo extends StatelessWidget {
  const _AvatarDemo();

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Column(
      children: [
        Row(
          children: [
            const NanoAvatar('CN', size: NanoAvatarSize.compact),
            SizedBox(width: theme.spacing.inlineActions),
            const NanoAvatar('SD', size: NanoAvatarSize.medium),
            SizedBox(width: theme.spacing.inlineActions),
            const NanoAvatar('XL', size: NanoAvatarSize.large),
          ],
        ),
        SizedBox(height: theme.spacing.stackDefault),
        NanoAvatarGroup(
          avatars: const [
            NanoAvatar('A'),
            NanoAvatar('B'),
            NanoAvatar('C'),
            NanoAvatar('D'),
            NanoAvatar('E'),
            NanoAvatar('F'),
          ],
        ),
      ],
    );
  }
}

// --- Badge ------------------------------------------------------------------

Widget badgePage(BuildContext context) {
  return const DemoSection(
    title: 'Badge',
    description: 'Small status pill in four variants.',
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        NanoBadge('Badge'),
        NanoBadge('Secondary', variant: NanoBadgeVariant.secondary),
        NanoBadge('Destructive', variant: NanoBadgeVariant.destructive),
        NanoBadge('Outline', variant: NanoBadgeVariant.outline),
      ],
    ),
  );
}

// --- Breadcrumb -------------------------------------------------------------

Widget breadcrumbPage(BuildContext context) {
  return DemoSection(
    title: 'Breadcrumb',
    description:
        'Link trail with chevron separators — you are looking at one '
        'in the header right now.',
    align: AlignmentDirectional.centerStart,
    child: NanoBreadcrumb(
      items: [
        NanoBreadcrumbItem('Home', onTap: () {}),
        NanoBreadcrumbItem('Components', onTap: () {}),
        NanoBreadcrumbItem('Breadcrumb'),
      ],
    ),
  );
}

// --- Carousel ---------------------------------------------------------------

class _CarouselSlide extends StatelessWidget {
  const _CarouselSlide(this.label, this.index);

  final String label;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final shades = [
      theme.colors.surfaceSubtle,
      theme.colors.border,
      theme.colors.borderStrong,
      theme.colors.actionPrimaryBackground,
      theme.colors.actionDisabledForeground,
    ];
    final bg = shades[index % shades.length];
    final fg = index == 3
        ? theme.colors.actionPrimaryForeground
        : theme.colors.textPrimary;
    return Container(
      color: bg,
      alignment: Alignment.center,
      child: Text(label, style: theme.type.headingH2.copyWith(color: fg)),
    );
  }
}

Widget carouselPage(BuildContext context) {
  return DemoSection(
    title: 'Carousel',
    description: 'Paged slides with peek, edge arrows and a dot indicator.',
    child: SizedBox(
      width: 520,
      child: NanoCarousel(
        height: 180,
        children: [
          for (var i = 1; i <= 5; i++) _CarouselSlide('Slide $i', i - 1),
        ],
      ),
    ),
  );
}

// --- Empty ------------------------------------------------------------------

Widget emptyPage(BuildContext context) {
  return DemoSection(
    title: 'Empty',
    description: 'Placeholder for empty collections with an action row.',
    child: NanoEmpty(
      title: 'No results',
      description: 'Try a different search term.',
      actions: [
        NanoButton(
          label: 'Clear filters',
          variant: NanoButtonVariant.outline,
          size: NanoButtonSize.compact,
          onPressed: () {},
        ),
      ],
    ),
  );
}

// --- Kbd --------------------------------------------------------------------

Widget kbdPage(BuildContext context) {
  final theme = NanoTheme.of(context);
  return DemoSection(
    title: 'Kbd',
    description: 'Keyboard-key chip.',
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const NanoKbd(['Ctrl']),
        SizedBox(width: theme.spacing.stackDefault / 2),
        const NanoKbd(['K']),
        SizedBox(width: theme.spacing.stackDefault),
        const NanoText(
          'to open the command palette',
          role: NanoTextRole.bodySupporting,
        ),
      ],
    ),
  );
}

// --- Skeleton ---------------------------------------------------------------

class _SkeletonDemo extends StatelessWidget {
  const _SkeletonDemo();

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const NanoSkeleton(width: 40, height: 40, radius: 999),
            SizedBox(width: theme.spacing.stackDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const NanoSkeleton(width: 160, height: 14),
                  SizedBox(height: theme.spacing.stackDefault / 2),
                  const NanoSkeleton(width: 240, height: 12),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: theme.spacing.stackDefault),
        const NanoSkeleton(width: 320, height: 90),
      ],
    );
  }
}

// --- Spinner ----------------------------------------------------------------

class _SpinnerDemo extends StatelessWidget {
  const _SpinnerDemo();

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const NanoSpinner(),
        SizedBox(width: theme.spacing.inlineActions),
        NanoSpinner(size: theme.size.iconDecorative),
        SizedBox(width: theme.spacing.inlineActions),
        NanoButton(
          label: 'Loading…',
          size: NanoButtonSize.compact,
          icon: null,
          onPressed: null,
        ),
      ],
    );
  }
}

// --- Progress ---------------------------------------------------------------

class _ProgressDemo extends StatelessWidget {
  const _ProgressDemo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      child: Column(
        children: [
          const NanoProgress(value: 0.62),
          SizedBox(height: NanoTheme.of(context).spacing.stackDefault),
          const NanoProgress(value: 0.3),
        ],
      ),
    );
  }
}

// --- Table ------------------------------------------------------------------

class _TableDemo extends StatelessWidget {
  const _TableDemo();

  static const _invoices = [
    ('INV001', 'Paid', 'Credit Card', 250.00),
    ('INV002', 'Pending', 'PayPal', 150.00),
    ('INV003', 'Unpaid', 'Bank Transfer', 350.00),
    ('INV004', 'Paid', 'Credit Card', 450.00),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    Widget cell(String text, {bool right = false}) => Text(
      text,
      style: theme.type.bodyDefault.copyWith(color: theme.colors.textPrimary),
    );
    return NanoTable(
      columns: const [
        NanoTableColumn(header: 'Invoice'),
        NanoTableColumn(header: 'Status'),
        NanoTableColumn(header: 'Method'),
        NanoTableColumn(header: 'Amount'),
      ],
      rows: [
        for (final (id, status, method, amount) in _invoices)
          [
            cell(id),
            NanoBadge(
              status,
              variant: status == 'Paid'
                  ? NanoBadgeVariant.secondary
                  : status == 'Pending'
                  ? NanoBadgeVariant.outline
                  : NanoBadgeVariant.destructive,
            ),
            cell(method),
            cell('\$${amount.toStringAsFixed(2)}'),
          ],
      ],
    );
  }
}

// --- Timeline ---------------------------------------------------------------

class _TimelineDemo extends StatelessWidget {
  const _TimelineDemo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: NanoTimeline(
        items: const [
          NanoTimelineItem(
            title: 'Order placed',
            description: 'Your order #1042 has been placed.',
            time: '09:12',
            highlight: true,
          ),
          NanoTimelineItem(
            title: 'Payment confirmed',
            description: 'Visa ending in 4242 · \$75.00',
            time: '09:13',
            highlight: true,
          ),
          NanoTimelineItem(
            title: 'Shipped',
            description: 'Package handed to the carrier.',
            time: '14:38',
          ),
          NanoTimelineItem(
            title: 'Delivered',
            description: 'Expected tomorrow before 18:00.',
          ),
        ],
      ),
    );
  }
}

Widget alertVariantsPage(BuildContext context) {
  return const DemoSection(
    title: 'Alert — status triads',
    description: 'Each status color set paints border, icon and text.',
    align: AlignmentDirectional.centerStart,
    child: _AlertVariantsDemo(),
  );
}

Widget avatarPage(BuildContext context) {
  return const DemoSection(
    title: 'Avatar',
    description:
        'Initials fallback sizes and an overlapping group with an '
        'overflow counter.',
    child: _AvatarDemo(),
  );
}

Widget skeletonPage(BuildContext context) {
  return const DemoSection(
    title: 'Skeleton',
    description: 'Pulsing placeholders that reserve layout while loading.',
    child: _SkeletonDemo(),
  );
}

Widget spinnerPage(BuildContext context) {
  return const DemoSection(
    title: 'Spinner',
    description: 'Rotating loader arc; a disabled button shows it inline.',
    child: _SpinnerDemo(),
  );
}

Widget progressPage(BuildContext context) {
  return const DemoSection(
    title: 'Progress',
    description: 'Determinate bars driven by the value prop.',
    child: _ProgressDemo(),
  );
}

Widget tablePage(BuildContext context) {
  return const DemoSection(
    title: 'Table',
    description: 'Muted header band, hairline dividers, badge status cells.',
    align: AlignmentDirectional.centerStart,
    child: _TableDemo(),
  );
}

Widget timelinePage(BuildContext context) {
  return const DemoSection(
    title: 'Timeline',
    description: 'Vertical rail with markers, descriptions and timestamps.',
    align: AlignmentDirectional.centerStart,
    child: _TimelineDemo(),
  );
}
