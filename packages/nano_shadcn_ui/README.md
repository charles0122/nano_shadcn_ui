# nano_shadcn_ui

The shadcn/ui component vocabulary implemented for Flutter on top of
[`nano_ui`](../nano_ui): token-driven, Material-free, registry-aware.

## Scope

This package is intentionally optimized for desktop, web and B2B/admin
interfaces:

- dense pointer + keyboard interactions;
- menus, popovers, dialogs, sheets and toasts;
- calendars, command palettes, data tables and charts;
- resizable panels and collapsible sidebars.

`nano_ui` remains the cross-platform core (tokens, themes, interaction and
overlay foundations, universal primitives). Mobile-oriented components can be
designed as another package without inheriting desktop density and navigation
patterns.

## Usage

```dart
import 'package:nano_shadcn_ui/nano_shadcn_ui.dart';

NanoButton(label: 'Deploy', onPressed: deploy);
NanoDialog.show(context, builder: (_) => const NanoDialogPanel(...));
```

The package re-exports `nano_ui`, so one import exposes both core primitives and
the shadcn set. Use `nanoShadcnRegistry` for declarative/agent rendering across
both packages.

See [`apps/shadcn_gallery`](../../apps/shadcn_gallery) for every component and
the 80-combination shadcn theme customizer.
