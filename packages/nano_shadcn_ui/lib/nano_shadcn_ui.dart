/// nano_shadcn_ui — the shadcn/ui component vocabulary for the nano design
/// system.
///
/// Desktop/admin-oriented widgets (overlays, data grids, calendars, command
/// palettes…) layered on `package:nano_ui`'s token theme, interactive base
/// and primitives. Mobile-first product UI should use nano_ui primitives
/// directly; this set optimizes for dense, pointer-driven back-office UI.
library;

/// Re-export the nano constitution and primitives so an app adopting this
/// complete component vocabulary needs a single package import.
export 'package:nano_ui/nano_ui.dart';

export 'src/nano_shadcn_registry.dart';

export 'src/components/nano_accordion.dart';
export 'src/components/nano_alert.dart';
export 'src/components/nano_aspect_ratio.dart';
export 'src/components/nano_breadcrumb.dart';
export 'src/components/nano_calendar.dart';
export 'src/components/nano_carousel.dart';
export 'src/components/nano_chart.dart';
export 'src/components/nano_checkbox.dart';
export 'src/components/nano_collapsible.dart';
export 'src/components/nano_combobox.dart';
export 'src/components/nano_command.dart';
export 'src/components/nano_context_menu.dart';
export 'src/components/nano_data_table.dart';
export 'src/components/nano_date_picker.dart';
export 'src/components/nano_dialog.dart';
export 'src/components/nano_dropdown_menu.dart';
export 'src/components/nano_empty.dart';
export 'src/components/nano_form.dart';
export 'src/components/nano_hover_card.dart';
export 'src/components/nano_input_otp.dart';
export 'src/components/nano_item.dart';
export 'src/components/nano_menu.dart';
export 'src/components/nano_menubar.dart';
export 'src/components/nano_navigation_menu.dart';
export 'src/components/nano_pagination.dart';
export 'src/components/nano_popover.dart';
export 'src/components/nano_radio_group.dart';
export 'src/components/nano_resizable.dart';
export 'src/components/nano_scroll_area.dart';
export 'src/components/nano_select.dart';
export 'src/components/nano_sheet.dart';
export 'src/components/nano_sidebar.dart';
export 'src/components/nano_slider.dart';
export 'src/components/nano_sonner.dart';
export 'src/components/nano_switch.dart';
export 'src/components/nano_table.dart';
export 'src/components/nano_tabs.dart';
export 'src/components/nano_timeline.dart';
export 'src/components/nano_toggle.dart';
