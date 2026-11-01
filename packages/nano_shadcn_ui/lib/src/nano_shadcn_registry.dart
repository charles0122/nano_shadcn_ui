import 'package:nano_ui/nano_ui.dart';

import 'components/nano_accordion.dart';
import 'components/nano_alert.dart';
import 'components/nano_aspect_ratio.dart';
import 'components/nano_breadcrumb.dart';
import 'components/nano_calendar.dart';
import 'components/nano_carousel.dart';
import 'components/nano_checkbox.dart';
import 'components/nano_collapsible.dart';
import 'components/nano_empty.dart';
import 'components/nano_input_otp.dart';
import 'components/nano_item.dart';
import 'components/nano_pagination.dart';
import 'components/nano_radio_group.dart';
import 'components/nano_resizable.dart';
import 'components/nano_switch.dart';
import 'components/nano_table.dart';
import 'components/nano_tabs.dart';
import 'components/nano_timeline.dart';
import 'components/nano_toggle.dart';

/// Component registry for the shadcn set: every serializable spec here plus
/// the nano_ui primitives, so an agent renderer gets one registry covering
/// both packages. Imperative widgets (menus, popovers, dialogs, the sidebar,
/// charts…) stay out — their props are callbacks and state, not data.
final NanoComponentRegistry nanoShadcnRegistry = NanoComponentRegistry(
  specs: [
    // nano_ui primitives.
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
    // shadcn set.
    nanoAccordionSpec,
    nanoAlertSpec,
    nanoAspectRatioSpec,
    nanoBreadcrumbSpec,
    nanoCalendarSpec,
    nanoCarouselSpec,
    nanoCheckboxSpec,
    nanoCollapsibleSpec,
    nanoEmptySpec,
    nanoInputOTPSpec,
    nanoItemSpec,
    nanoPaginationSpec,
    nanoRadioSpec,
    nanoResizableSpec,
    nanoSwitchSpec,
    nanoTableSpec,
    nanoTabsSpec,
    nanoTimelineSpec,
    nanoToggleSpec,
  ],
);
