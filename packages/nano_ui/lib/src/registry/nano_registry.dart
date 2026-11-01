import 'package:flutter/widgets.dart';

import 'standard_registry.dart';

/// A serializable UI node — the declarative twin of the widget tree.
///
/// The same [NanoComponentRegistry] renders nodes built from Dart code and
/// nodes parsed from JSON, which is what agent-driven UI (A2UI / GenUI) will
/// stream in.
class NanoNode {
  const NanoNode({
    required this.type,
    this.props = const {},
    this.children = const [],
    this.actionId,
  });

  /// Registry key, e.g. `NanoButton`.
  final String type;

  /// Visual props for this node. Values must be JSON primitives or lists of
  /// them — styles come from tokens, referenced by name.
  final Map<String, Object?> props;

  final List<NanoNode> children;

  /// Identifier of the action to dispatch when the component is activated.
  /// Actions are resolved by the host app; agents never emit code.
  final String? actionId;

  Map<String, Object?> toJson() => {
    'type': type,
    'props': props,
    if (children.isNotEmpty)
      'children': children.map((c) => c.toJson()).toList(),
    if (actionId != null) 'actionId': actionId,
  };

  static NanoNode fromJson(Map<String, Object?> json) {
    final type = json['type'];
    if (type is! String || type.isEmpty) {
      throw FormatException('NanoNode JSON requires a non-empty "type"');
    }
    return NanoNode(
      type: type,
      props: json['props'] is Map
          ? Map<String, Object?>.from(json['props'] as Map)
          : const {},
      children: json['children'] is List
          ? (json['children'] as List)
                .map(
                  (child) => NanoNode.fromJson(
                    Map<String, Object?>.from(child as Map),
                  ),
                )
                .toList()
          : const [],
      actionId: json['actionId'] as String?,
    );
  }
}

/// Renders one node. Gets the scope so nested children can be rendered
/// through the same registry without re-wrapping.
typedef NanoComponentBuilder = Widget Function(
  BuildContext context,
  NanoNode node,
  NanoRenderScopeData scope,
);

/// Machine-readable contract of a registered component. This is the surface
/// agents will read; visual props reference semantic token names.
class NanoComponentSpec {
  const NanoComponentSpec({
    required this.name,
    required this.builder,
    this.propsSchema = const {},
    this.description,
  });

  final String name;
  final NanoComponentBuilder builder;

  /// Light-weight schema, e.g.
  /// `{'label': {'type': 'string'}, 'variant': {'type': 'enum', 'values': [...]}}`.
  final Map<String, Object?> propsSchema;
  final String? description;
}

class NanoComponentRegistry {
  NanoComponentRegistry({List<NanoComponentSpec> specs = const []}) {
    for (final spec in specs) {
      register(spec);
    }
  }

  final Map<String, NanoComponentSpec> _specs = {};

  void register(NanoComponentSpec spec) {
    if (_specs.containsKey(spec.name)) {
      throw StateError('Component "${spec.name}" is already registered');
    }
    _specs[spec.name] = spec;
  }

  NanoComponentSpec? specOf(String type) => _specs[type];

  Set<String> get knownTypes => Set.unmodifiable(_specs.keys);

  Widget build(
    BuildContext context,
    NanoNode node, {
    void Function(String actionId)? onAction,
  }) {
    final scope = NanoRenderScopeData(registry: this, onAction: onAction);
    return NanoRenderScope(
      data: scope,
      child: scope.renderChild(context, node),
    );
  }
}

class NanoRenderScopeData {
  const NanoRenderScopeData({required this.registry, required this.onAction});

  final NanoComponentRegistry registry;
  final void Function(String actionId)? onAction;

  void dispatch(String actionId) => onAction?.call(actionId);

  Widget renderChild(BuildContext context, NanoNode node) {
    final spec = registry.specOf(node.type);
    if (spec == null) {
      throw NanoRegistryException(
        'Unknown component "${node.type}" — registered: '
        '${registry.knownTypes.join(', ')}',
      );
    }
    return spec.builder(context, node, this);
  }
}

/// Hands the render context down the tree. Intentionally never notifies:
/// the subtree is rebuilt by its owner (e.g. [NanoRenderer]) anyway.
class NanoRenderScope extends InheritedWidget {
  const NanoRenderScope({super.key, required this.data, required super.child});

  final NanoRenderScopeData data;

  static NanoRenderScopeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NanoRenderScope>()!.data;

  @override
  bool updateShouldNotify(NanoRenderScope oldWidget) => false;
}

class NanoRenderer extends StatelessWidget {
  const NanoRenderer({
    super.key,
    required this.node,
    this.registry,
    this.onAction,
  });

  final NanoNode node;

  /// Defaults to [nanoStandardRegistry].
  final NanoComponentRegistry? registry;
  final void Function(String actionId)? onAction;

  @override
  Widget build(BuildContext context) {
    return (registry ?? nanoStandardRegistry).build(
      context,
      node,
      onAction: onAction,
    );
  }
}

class NanoRegistryException implements Exception {
  NanoRegistryException(this.message);
  final String message;

  @override
  String toString() => 'NanoRegistryException: $message';
}
