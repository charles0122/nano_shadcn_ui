import '../components/nano_avatar.dart';
import '../components/nano_badge.dart';
import '../components/nano_button.dart';
import '../components/nano_card.dart';
import '../components/nano_input.dart';
import '../components/nano_kbd.dart';
import '../components/nano_label.dart';
import '../components/nano_progress.dart';
import '../components/nano_separator.dart';
import '../components/nano_skeleton.dart';
import '../components/nano_status_banner.dart';
import '../components/nano_text.dart';
import 'nano_registry.dart';

/// Registry preloaded with every serializable component shipped by nano_ui
/// (the core primitives). The shadcn/ui set extends this via
/// `package:nano_shadcn_ui`'s `nanoShadcnRegistry`.
final NanoComponentRegistry nanoStandardRegistry = NanoComponentRegistry(
  specs: [
    nanoButtonSpec,
    nanoBadgeSpec,
    nanoCardSpec,
    nanoTextSpec,
    nanoInputSpec,
    nanoStatusBannerSpec,
    nanoAvatarSpec,
    nanoSeparatorSpec,
    nanoLabelSpec,
    nanoKbdSpec,
    nanoSkeletonSpec,
    nanoSpinnerSpec,
    nanoProgressSpec,
  ],
);
