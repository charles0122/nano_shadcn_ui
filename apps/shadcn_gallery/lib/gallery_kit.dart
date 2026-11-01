import 'package:flutter/widgets.dart';
import 'package:nano_ui/nano_ui.dart';

/// One docs page in the gallery sidebar.
class GalleryPage {
  const GalleryPage({
    required this.id,
    required this.title,
    required this.group,
    required this.description,
    required this.builder,
  });

  final String id;
  final String title;
  final String group;
  final String description;
  final WidgetBuilder builder;
}

/// Preview panel — the shadcn docs recipe: bordered rounded surface with
/// generous padding and centered content, preceded by title + description.
class DemoSection extends StatelessWidget {
  const DemoSection({
    super.key,
    required this.title,
    required this.child,
    this.description,
    this.align = Alignment.center,
    this.maxWidth,
  });

  final String title;
  final String? description;
  final Widget child;
  final AlignmentGeometry align;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        NanoText(title, role: NanoTextRole.h4),
        if (description != null) ...[
          SizedBox(height: theme.spacing.stackLabelContent / 2),
          NanoText(description!, role: NanoTextRole.bodySupporting),
        ],
        SizedBox(height: theme.spacing.stackDefault),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
          padding: EdgeInsets.all(theme.spacing.insetCard),
          decoration: BoxDecoration(
            color: theme.colors.surface,
            borderRadius: BorderRadius.circular(theme.radius.surfaceCard),
            border: Border.all(
              color: theme.colors.border,
              width: theme.borders.surfaceCardWidth,
            ),
          ),
          child: Align(alignment: align, child: child),
        ),
      ],
    );
  }
}

/// Vertical rhythm between sections on a page.
class SectionGap extends StatelessWidget {
  const SectionGap({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: NanoTheme.of(context).spacing.stackSections);
  }
}
