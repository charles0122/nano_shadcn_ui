import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_ui/nano_ui.dart';

import 'token_fixture.dart';

Widget wrap(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: NanoTheme(data: fixtureTheme(), child: child),
);

const demoNodeJson = <String, Object?>{
  'type': 'NanoCard',
  'props': <String, Object?>{},
  'children': <Object?>[
    {
      'type': 'NanoText',
      'props': {'text': 'From JSON', 'role': 'h2'},
    },
    {
      'type': 'NanoStatusBanner',
      'props': {'message': 'status banner', 'status': 'success'},
    },
    {
      'type': 'NanoButton',
      'props': {'label': 'JSON action', 'variant': 'secondary'},
      'actionId': 'demo.ping',
    },
  ],
};

void main() {
  testWidgets('renders a JSON node tree through the standard registry', (
    tester,
  ) async {
    final actions = <String>[];
    await tester.pumpWidget(
      wrap(
        NanoRenderer(
          node: NanoNode.fromJson(demoNodeJson),
          onAction: actions.add,
        ),
      ),
    );

    expect(find.text('From JSON'), findsOneWidget);
    expect(find.text('JSON action'), findsOneWidget);
    expect(find.text('status banner'), findsOneWidget);

    await tester.tap(find.text('JSON action'));
    await tester.pump();
    expect(actions, ['demo.ping']);
  });

  testWidgets('NanoNode round-trips through JSON', (tester) async {
    final node = NanoNode.fromJson(demoNodeJson);
    final restored = NanoNode.fromJson(
      Map<String, Object?>.from(node.toJson()),
    );
    expect(restored.type, node.type);
    expect(restored.children.length, node.children.length);
    expect(restored.children[2].actionId, 'demo.ping');
  });

  testWidgets('unknown component type throws a registry exception', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(NanoRenderer(node: const NanoNode(type: 'NanoNoSuchThing'))),
    );
    expect(tester.takeException(), isA<NanoRegistryException>());
  });

  testWidgets('input accepts text and reports changes', (tester) async {
    final changed = <String>[];
    await tester.pumpWidget(
      wrap(NanoInput(label: '昵称', placeholder: '请输入', onChanged: changed.add)),
    );
    await tester.enterText(find.byType(EditableText), 'hello');
    await tester.pump();
    expect(changed, ['hello']);
    expect(find.text('hello'), findsOneWidget);
  });

  test('registry exposes machine-readable specs', () {
    expect(
      nanoStandardRegistry.knownTypes,
      containsAll([
        'NanoButton',
        'NanoCard',
        'NanoText',
        'NanoInput',
        'NanoStatusBanner',
        'NanoAvatar',
      ]),
    );
    final schema = nanoStandardRegistry.specOf('NanoStatusBanner')!.propsSchema;
    expect((schema['status'] as Map)['values'], contains('warning'));
  });
}
