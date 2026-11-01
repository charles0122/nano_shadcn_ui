import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:nano_ui/nano_ui.dart';

void main() => runApp(const NanoGalleryApp());

/// Loads every resolved token combination from assets and drives the theme
/// entirely from them — the same JSON files agents consume.
class NanoGalleryApp extends StatefulWidget {
  const NanoGalleryApp({super.key});

  @override
  State<NanoGalleryApp> createState() => _NanoGalleryAppState();
}

class _NanoGalleryAppState extends State<NanoGalleryApp> {
  final Map<String, Map<String, Object?>> _combos = {};
  Map<String, Object?>? _manifest;
  Object? _loadError;

  ({String brand, String colorMode, String density}) _selection = (
    brand: 'Default',
    colorMode: 'Light',
    density: 'Compact',
  );

  @override
  void initState() {
    super.initState();
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    try {
      final manifest =
          jsonDecode(await rootBundle.loadString('assets/tokens/themes.manifest.json'))
              as Map<String, Object?>;
      final combinations = (manifest['combinations'] as List).cast<Map>();
      for (final combo in combinations) {
        final name = combo['name'] as String;
        final file = 'assets/tokens/tokens.combo.'
            '${name.replaceAll('+', '-')}.json';
        _combos[name] =
            jsonDecode(await rootBundle.loadString(file)) as Map<String, Object?>;
      }
      setState(() => _manifest = manifest);
    } catch (e) {
      setState(() => _loadError = e);
    }
  }

  /// Combo name for the current selection, assembled from the manifest's
  /// dimension groups (data-driven — no hardcoded group order here).
  String? get _selectedCombo {
    final groups = _manifest?['groups'];
    if (groups is! Map) return null;
    final byGroup = {
      'Brand': _selection.brand,
      'SemanticColor': _selection.colorMode,
      'SemanticSpacing': _selection.density,
    };
    final parts = <String>[];
    for (final group in groups.keys) {
      final names = (groups[group] as List).cast<String>();
      parts.add(byGroup[group] ?? names.first);
    }
    final name = parts.join('+');
    return _combos.containsKey(name) ? name : null;
  }

  @override
  Widget build(BuildContext context) {
    final comboName = _selectedCombo;
    if (_loadError != null) {
      return _shell(
        Center(
          child: Text(
            'Token assets failed to load:\n$_loadError',
            style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (comboName == null) {
      return _shell(const Center(child: Text('Loading tokens…')));
    }
    final tokens = _combos[comboName]!;
    return NanoAnimatedTheme(
      data: nanoThemeFromTokens(
        tokens,
        brightness:
            _selection.colorMode == 'Dark' ? Brightness.dark : Brightness.light,
      ),
      child: WidgetsApp(
        title: 'nano_ui — DTCG gallery',
        color: const Color(0xFF6750A4),
        // Without material_ui we must tell WidgetsApp how to build pages —
        // a plain fade transition from the core library.
        pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
        home: _GalleryPage(
          comboName: comboName,
          manifest: _manifest!,
          selection: _selection,
          tokens: tokens,
          onSelectionChanged: (selection) =>
              setState(() => _selection = selection),
        ),
      ),
    );
  }

  Widget _shell(Widget child) => WidgetsApp(
        color: const Color(0xFF6750A4),
        builder: (context, _) => DefaultTextStyle(
          style: const TextStyle(fontSize: 14, color: Color(0xFF17212D)),
          child: child,
        ),
      );
}

class _GalleryPage extends StatelessWidget {
  _GalleryPage({
    required this.comboName,
    required this.manifest,
    required this.selection,
    required this.tokens,
    required this.onSelectionChanged,
  });

  final String comboName;
  final Map<String, Object?> manifest;
  final ({String brand, String colorMode, String density}) selection;
  final Map<String, Object?> tokens;
  final void Function(({String brand, String colorMode, String density}))
      onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    final groups = manifest['groups'] as Map;

    Widget gap(double h) => SizedBox(height: h);

    return Container(
      color: theme.colors.canvas,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(theme.spacing.gutterPage),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const NanoText('nano_ui', role: NanoTextRole.displayCompact),
            NanoText('DTCG gallery — $comboName',
                role: NanoTextRole.bodySupporting),
            gap(theme.spacing.stackSections),

            // --- dimension switchers (driven by the theme manifest) ---
            _dimensionPicker(
              context,
              label: 'Brand',
              group: 'Brand',
              groups: groups,
              selected: selection.brand,
              onSelected: (v) => onSelectionChanged((
                brand: v,
                colorMode: selection.colorMode,
                density: selection.density,
              )),
            ),
            gap(theme.spacing.stackDefault),
            _dimensionPicker(
              context,
              label: 'Color mode',
              group: 'SemanticColor',
              groups: groups,
              selected: selection.colorMode,
              onSelected: (v) => onSelectionChanged((
                brand: selection.brand,
                colorMode: v,
                density: selection.density,
              )),
            ),
            gap(theme.spacing.stackDefault),
            _dimensionPicker(
              context,
              label: 'Spacing density',
              group: 'SemanticSpacing',
              groups: groups,
              selected: selection.density,
              onSelected: (v) => onSelectionChanged((
                brand: selection.brand,
                colorMode: selection.colorMode,
                density: v,
              )),
            ),
            gap(theme.spacing.stackSections),

            // --- typography specimen ---
            _section(context, 'Typography — DTCG.Type.*', [
              const NanoText('Display Hero', role: NanoTextRole.displayHero),
              const NanoText('Display Metric', role: NanoTextRole.displayMetric),
              const NanoText('H1 — 一级标题', role: NanoTextRole.h1),
              const NanoText('H2 — 二级标题', role: NanoTextRole.h2),
              const NanoText('H3 — 三级标题', role: NanoTextRole.h3),
              const NanoText('H4 — 四级标题', role: NanoTextRole.h4),
              const NanoText('H5 — 五级标题', role: NanoTextRole.h5),
              const NanoText('H6 — 六级标题', role: NanoTextRole.h6),
              gap(theme.spacing.stackDefault),
              const NanoText(
                'Body Default — 每个 token 都有来源,每个像素都有出处。',
                role: NanoTextRole.body,
              ),
              const NanoText(
                'Body Reading — 长文阅读字号 (17pt) 与舒适行高。',
                role: NanoTextRole.bodyReading,
              ),
              const NanoText(
                'Body Supporting — 辅助说明文字,次级颜色由角色决定。',
                role: NanoTextRole.bodySupporting,
              ),
              const NanoText('Label Action', role: NanoTextRole.labelAction),
              const NanoText('Label Metadata', role: NanoTextRole.labelMetadata),
              const NanoText('Label Navigation', role: NanoTextRole.labelNavigation),
            ]),
            gap(theme.spacing.stackSections),

            // --- buttons ---
            _section(context, 'Buttons — action.* / radii.control.button', [
              Wrap(
                spacing: theme.spacing.inlineActions,
                runSpacing: theme.spacing.stackDefault,
                children: [
                  NanoButton(label: 'Primary', onPressed: () {}),
                  NanoButton(
                    label: 'Secondary',
                    variant: NanoButtonVariant.secondary,
                    onPressed: () {},
                  ),
                  NanoButton(
                    label: 'Ghost',
                    variant: NanoButtonVariant.ghost,
                    onPressed: () {},
                  ),
                  const NanoButton(label: 'Disabled', enabled: false),
                ],
              ),
              gap(theme.spacing.stackDefault),
              Wrap(
                spacing: theme.spacing.inlineActions,
                runSpacing: theme.spacing.stackDefault,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  NanoButton(
                    label: 'Compact',
                    size: NanoButtonSize.compact,
                    onPressed: () {},
                  ),
                  NanoButton(label: 'Medium', onPressed: () {}),
                  NanoButton(
                    label: 'Large',
                    size: NanoButtonSize.large,
                    onPressed: () {},
                  ),
                ],
              ),
            ]),
            gap(theme.spacing.stackSections),

            // --- inputs ---
            _section(context, 'Inputs — border.focus / radii.control.input', [
              const NanoInput(label: '昵称', placeholder: '点击试试 focus ring…'),
              gap(theme.spacing.stackDefault),
              const NanoInput(
                label: '禁用状态',
                placeholder: 'action.disabled.*',
                enabled: false,
              ),
            ]),
            gap(theme.spacing.stackSections),

            // --- cards ---
            _section(context, 'Cards — surface / elevation', [
              NanoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const NanoText('卡片标题', role: NanoTextRole.h4),
                    gap(theme.spacing.stackLabelContent),
                    const NanoText(
                      'radii.surface.card = 24,border.width.surface.card = 1,'
                      'spacing.inset.card = 16。',
                      role: NanoTextRole.bodySupporting,
                    ),
                    gap(theme.spacing.stackDefault),
                    Wrap(
                      spacing: theme.spacing.inlineActions,
                      children: [
                        NanoButton(
                          label: '确认',
                          onPressed: () {},
                        ),
                        NanoButton(
                          label: '取消',
                          variant: NanoButtonVariant.secondary,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              gap(theme.spacing.stackDefault),
              const NanoCard(
                elevated: true,
                child: NanoText(
                  'Elevated — Elevation.shadow.raised (y2 blur8)',
                  role: NanoTextRole.bodySupporting,
                ),
              ),
            ]),
            gap(theme.spacing.stackSections),

            // --- status banners ---
            _section(context, 'Status — color.status.* triads', [
              const NanoStatusBanner(
                title: '发布失败',
                message: 'color.status.danger — fg / bg / border 三件套。',
                status: NanoStatusType.danger,
              ),
              gap(theme.spacing.stackDefault),
              const NanoStatusBanner(
                message: '同步完成,所有更改已保存。',
                status: NanoStatusType.success,
              ),
              gap(theme.spacing.stackDefault),
              const NanoStatusBanner(
                message: '配额即将用尽,请注意清理。',
                status: NanoStatusType.warning,
              ),
              gap(theme.spacing.stackDefault),
              const NanoStatusBanner(
                message: '新版本 3.47.9 已发布。',
                status: NanoStatusType.info,
              ),
            ]),
            gap(theme.spacing.stackSections),

            // --- avatars ---
            _section(context, 'Avatars — size.avatar.* / radii.shape.avatar', [
              const Row(
                children: [
                  NanoAvatar('D', size: NanoAvatarSize.compact),
                  SizedBox(width: 8),
                  NanoAvatar('DT', size: NanoAvatarSize.medium),
                  SizedBox(width: 8),
                  NanoAvatar('DTCG', size: NanoAvatarSize.large),
                ],
              ),
            ]),
            gap(theme.spacing.stackSections),

            // --- localization tokens ---
            _section(context, 'Localization — Localizations/*.json', [
              _tokenText(context, 'keySleepText1'),
              _tokenText(context, 'keyHealthAlertCause'),
            ]),
            gap(theme.spacing.stackSections),

            // --- registry: JSON-driven rendering ---
            _section(context, 'Rendered from JSON — component registry', [
              NanoRenderer(
                node: NanoNode.fromJson(_demoNodeJson),
                onAction: (actionId) => _lastAction.value = actionId,
              ),
              gap(theme.spacing.stackDefault),
              ValueListenableBuilder<String>(
                valueListenable: _lastAction,
                builder: (context, value, _) => NanoText(
                  'last action: $value',
                  role: NanoTextRole.labelMetadata,
                ),
              ),
            ]),
          ],
        ),
      ),
      ),
    );
  }

  final ValueNotifier<String> _lastAction = ValueNotifier('none');

  static const _demoNodeJson = <String, Object?>{
    'type': 'NanoCard',
    'props': <String, Object?>{'elevated': true},
    'children': <Object?>[
      {
        'type': 'NanoText',
        'props': {'text': 'Agent-rendered banner', 'role': 'h4'},
      },
      {
        'type': 'NanoStatusBanner',
        'props': {
          'message': 'Same registry, same renderer — the A2UI path.',
          'status': 'warning',
        },
      },
      {
        'type': 'NanoButton',
        'props': {'label': 'JSON action', 'variant': 'secondary'},
        'actionId': 'demo.ping',
      },
    ],
  };

  Widget _section(BuildContext context, String title, List<Widget> children) {
    final theme = NanoTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NanoText(title, role: NanoTextRole.h3),
        SizedBox(height: theme.spacing.stackDefault),
        ...children,
      ],
    );
  }

  Widget _dimensionPicker(
    BuildContext context, {
    required String label,
    required String group,
    required Map groups,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    final theme = NanoTheme.of(context);
    final options = (groups[group] as List).cast<String>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 110,
          child: NanoText(label, role: NanoTextRole.labelMetadata),
        ),
        Expanded(
          child: Wrap(
            spacing: theme.spacing.stackDefault,
            children: [
              for (final option in options)
                _DimensionChip(
                  label: option,
                  selected: option == selected,
                  onTap: () => onSelected(option),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tokenText(BuildContext context, String key) {
    final token = tokens[key];
    final value = token is Map ? token['value']?.toString() ?? '' : '(missing)';
    final theme = NanoTheme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: theme.spacing.stackDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NanoText(value, role: NanoTextRole.body),
          NanoText(key, role: NanoTextRole.labelMetadata),
        ],
      ),
    );
  }
}

/// Segmented chip built on the shared interactive base — an example of
/// composing your own controls with tokens instead of Material widgets.
class _DimensionChip extends StatelessWidget {
  const _DimensionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = NanoTheme.of(context);
    return NanoInteractive(
      onTap: onTap,
      builder: (context, states) {
        final focused = states.contains(WidgetState.focused);
        return AnimatedContainer(
          duration: theme.motion.durationFast,
          padding: EdgeInsets.symmetric(
            horizontal: theme.spacing.insetControl + 4,
            vertical: theme.spacing.insetControl,
          ),
          decoration: BoxDecoration(
            color: selected ? theme.colors.accent : theme.colors.surface,
            borderRadius: BorderRadius.circular(theme.radius.pill),
            border: Border.all(
              color: focused
                  ? theme.colors.borderFocus
                  : selected
                      ? theme.colors.accent
                      : theme.colors.border,
              width: focused
                  ? theme.borders.controlFocusWidth
                  : theme.borders.controlWidth,
            ),
          ),
          child: Text(
            label,
            style: theme.type.labelAction.copyWith(
              color: selected ? theme.colors.onAccent : theme.colors.textPrimary,
            ),
          ),
        );
      },
    );
  }
}
