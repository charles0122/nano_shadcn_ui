import 'package:flutter/widgets.dart';

import '../registry/nano_registry.dart';
import '../theme/nano_theme.dart';

/// Avatar sizes from the `size.avatar.*` tokens.
enum NanoAvatarSize { compact, medium, large }

/// Avatar — `size.avatar.*` diameter, `radii.shape.avatar` circle. Shows the
/// [image] when available, otherwise the [initials] fallback on an accent
/// surface (shadcn Avatar + AvatarFallback).
class NanoAvatar extends StatelessWidget {
  const NanoAvatar(
    this.initials, {
    super.key,
    this.size = NanoAvatarSize.medium,
    this.image,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Fallback initials, e.g. `'CN'`.
  final String initials;
  final NanoAvatarSize size;

  /// Optional image; painted above the fallback while loading.
  final ImageProvider? image;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final diameter = switch (size) {
      NanoAvatarSize.compact => theme.size.avatarCompact,
      NanoAvatarSize.medium => theme.size.avatarDefault,
      NanoAvatarSize.large => theme.size.avatarLarge,
    };
    final label = switch (size) {
      NanoAvatarSize.compact => theme.type.labelMetadata,
      NanoAvatarSize.medium => theme.type.labelAction,
      NanoAvatarSize.large => theme.type.headingH5,
    };
    final shape = Container(
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(theme.radius.avatar),
      ),
      child: Text(
        initials,
        style: label.copyWith(
          color: foregroundColor ?? theme.colors.textPrimary,
        ),
        maxLines: 1,
      ),
    );
    final image = this.image;
    if (image == null) return shape;
    return ClipRRect(
      borderRadius: BorderRadius.circular(theme.radius.avatar),
      child: Stack(
        fit: StackFit.expand,
        children: [
          shape,
          Image(
            image: image,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => shape,
          ),
        ],
      ),
    );
  }
}

/// Overlapping avatar row with a "+n" overflow chip (shadcn AvatarGroup).
class NanoAvatarGroup extends StatelessWidget {
  const NanoAvatarGroup({
    super.key,
    required this.avatars,
    this.maxVisible = 4,
    this.size = NanoAvatarSize.medium,
  });

  final List<NanoAvatar> avatars;
  final int maxVisible;
  final NanoAvatarSize size;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final diameter = switch (size) {
      NanoAvatarSize.compact => theme.size.avatarCompact,
      NanoAvatarSize.medium => theme.size.avatarDefault,
      NanoAvatarSize.large => theme.size.avatarLarge,
    };
    final visible = avatars.take(maxVisible);
    final hidden = avatars.length - visible.length;
    return Stack(
      children: [
        for (var i = 0; i < visible.length; i++)
          Padding(
            padding: EdgeInsets.only(left: i * diameter * 0.7),
            child: Container(
              padding: EdgeInsets.all(theme.borders.controlWidth + 1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colors.surface,
              ),
              child: visible.elementAt(i),
            ),
          ),
        if (hidden > 0)
          Padding(
            padding: EdgeInsets.only(left: visible.length * diameter * 0.7),
            child: Container(
              width: diameter,
              height: diameter,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colors.surfaceSubtle,
                border: Border.all(
                  color: theme.colors.surface,
                  width: theme.borders.controlWidth + 1,
                ),
              ),
              child: Text(
                '+$hidden',
                style: theme.type.labelMetadata.copyWith(
                  color: theme.colors.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Registry contract for agent-driven rendering.
const NanoComponentSpec nanoAvatarSpec = NanoComponentSpec(
  name: 'NanoAvatar',
  description: 'Initials avatar sized by the size.avatar.* tokens.',
  propsSchema: {
    'initials': {'type': 'string'},
    'size': {
      'type': 'enum',
      'values': ['compact', 'medium', 'large'],
    },
  },
  builder: _buildFromNode,
);

Widget _buildFromNode(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
) {
  final size = switch (node.props['size'] as String?) {
    'compact' => NanoAvatarSize.compact,
    'large' => NanoAvatarSize.large,
    _ => NanoAvatarSize.medium,
  };
  return NanoAvatar((node.props['initials'] as String?) ?? '', size: size);
}
