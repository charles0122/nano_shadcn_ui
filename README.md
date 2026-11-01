# nano_ui

**Nano-scale tokens, macro-scale interfaces.**

nano_ui is a token-first design system for Flutter — a compact core built directly on
`flutter_widgets`, where every color, radius, spacing, and motion curve originates from a
single W3C DTCG token source. No `ThemeData`, no baked-in look: your tokens are the design,
and components are their renderers.

## Positioning

- **Tokens are the constitution.** The single source of truth is a W3C
  [DTCG](https://tr.designtokens.org/format/) token tree (`primitive → semantic → component`).
  Components never contain bare colors or magic numbers — changing the theme means changing
  token files, nothing else.
- **Peer of `material_ui` / `cupertino_ui`.** Built on the Flutter core widget layer,
  independent of both design packages, sharing the core `WidgetState` abstraction.
  Can coexist with them and replace them page by page.
- **Agent-ready by construction.** Components are registered in a declarative registry
  (`name + props schema + renderer`). UI trees can be built from Dart code *or* rendered
  from JSON, so agent-driven UI protocols (A2UI, GenUI) map onto the same renderer instead
  of a parallel one. Props schemas reference semantic token names, so generation is
  constrained to valid design decisions by construction.
- **Engineering promises.** Independent release cadence (design rhythm, not SDK rhythm);
  semver where token structure changes are major; accessibility (focus, keyboard, semantics)
  built into the shared interactive base, not per component.

## Layout

```
packages/nano_tokens       DTCG pipeline: token JSON + parser/resolver + typed Dart codegen
packages/nano_ui           Cross-platform core: theme, foundations, registry and universal primitives
packages/nano_shadcn_ui    shadcn-flavored desktop/admin component set built on nano_ui
apps/example               Core nano_ui demo — no Material, includes JSON rendering
apps/shadcn_gallery        Full nano_shadcn_ui docs gallery + theme customizer
```

## Quickstart

```bash
fvm install            # uses .fvmrc → Flutter 3.47.9
dart pub get           # pub workspace — resolves all packages at once

# Regenerate typed tokens after editing packages/nano_tokens/tokens/*.json
dart run nano_tokens:generate

dart test              # in packages/nano_tokens (pure Dart)
flutter test           # in packages/nano_ui and packages/nano_shadcn_ui
flutter analyze
```

## Authoring tokens

Tokens live in `packages/nano_tokens/tokens/` as W3C DTCG JSON:

- `primitives.color.json`, `typography.json`, `spacing.json`, `radius.json`, `motion.json`
  are mode-independent.
- Modes are expressed as parallel files: `semantic.color.light.json` / `semantic.color.dark.json`.
  The generator validates that all modes define the same token paths — drift fails the build.
- `{group.token}` references are resolved across files with cycle detection.
- Generated output: `packages/nano_tokens/lib/src/generated/tokens.g.dart`
  (typed constants) and `packages/nano_tokens/dist/tokens.<mode>.json`
  (resolved, machine-readable — this is what agents and runtime tooling consume).

## Registry & agent UI

Every component registers a spec: `name`, a `propsSchema` (machine-readable, token-name
constrained) and a renderer. `NanoRenderer` turns a `NanoNode` JSON tree into widgets using
the same registry — the path A2UI messages will take. Component authors only implement the
widget; the JSON surface comes for free.

## shadcn/ui package and gallery

`packages/nano_shadcn_ui` re-expresses the shadcn/ui component set on the
nano token contract. It intentionally targets dense, pointer/keyboard-driven
B2B, dashboard and back-office UI: overlays, menus, data grids, calendars,
command palettes, resizable panes and a collapsible sidebar.

The split is deliberate:

- `nano_ui` stays the cross-platform constitution: theme, foundations,
  registry and universal primitives.
- `nano_shadcn_ui` is an opinionated desktop/admin component vocabulary built
  on that core and can version independently.
- A future mobile-oriented set can use the same tokens and primitives without
  inheriting desktop interaction density or navigation patterns.

`apps/shadcn_gallery` documents the shadcn package and dogfoods its own sidebar,
overlay stack and command palette.

The shadcn themes are token combinations, not code: a multi-set DTCG export
(`apps/shadcn_gallery/tokens/export/`) crosses Brand (Zinc + 7 base colors)
× SemanticColor (Light/Dark) × SemanticRadii (0–1rem) into 80 resolved
combo files. Regenerate with:

```bash
fvm dart run nano_tokens:generate --source apps/shadcn_gallery/tokens/export --no-dart
```

The app loads one combo JSON at a time and drives `NanoAnimatedTheme` with
it — theme switching (sidebar footer, or `?brand=Violet&mode=Dark&radius=R075`
deep links) morphs every token value frame by frame.

## Roadmap

- [ ] Mobile-oriented component package on the nano_ui core (touch density,
      bottom navigation, native-feeling pickers and sheets)
- [ ] `nano_a2ui` — A2UI protocol renderer on top of the registries
- [ ] Runtime DTCG resolver for remote theming / white-labeling
- [ ] Contrast (WCAG) validation in CI via token `$extensions` pairs
- [ ] Composite `typography` tokens emitted as typed styles
