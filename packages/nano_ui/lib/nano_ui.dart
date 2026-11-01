/// nano_ui — token-first design system for Flutter.
///
/// Every color, radius, spacing and motion curve originates from a W3C DTCG
/// token source (package:nano_tokens). Components are renderers of that
/// token set and register a declarative contract, so the same registry
/// renders Dart-built and JSON-driven (agent) UI.
///
/// This package is the core: theme, interactive/overlay foundation, icon
/// set and universal primitives. Larger opinionated sets (the shadcn/ui
/// vocabulary for desktop/admin UI) live in `package:nano_shadcn_ui`.
library;

// Foundation.
export 'src/foundation/nano_form_scope.dart';
export 'src/foundation/nano_icons.dart';
export 'src/foundation/nano_interactive.dart';
export 'src/foundation/nano_overlay.dart';

// Registry & agent rendering.
export 'src/registry/nano_registry.dart';
export 'src/registry/standard_registry.dart';

// Theme.
export 'src/theme/nano_animated_theme.dart';
export 'src/theme/nano_theme.dart';
export 'src/theme/nano_theme_data.dart';
export 'src/theme/theme_from_tokens.dart';

// Components.
export 'src/components/nano_avatar.dart';
export 'src/components/nano_badge.dart';
export 'src/components/nano_button.dart';
export 'src/components/nano_card.dart';
export 'src/components/nano_input.dart';
export 'src/components/nano_kbd.dart';
export 'src/components/nano_label.dart';
export 'src/components/nano_progress.dart';
export 'src/components/nano_separator.dart';
export 'src/components/nano_skeleton.dart';
export 'src/components/nano_status_banner.dart';
export 'src/components/nano_text.dart';
