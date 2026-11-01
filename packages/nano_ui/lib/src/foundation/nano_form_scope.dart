/// Read-write form error state shared by field compositions.
///
/// A [NanoFormItem]-style wrapper publishes whether its field currently has
/// an error; controls ([NanoInput] and friends) read it to switch their
/// border to the danger color without a dedicated prop per widget.
library;

import 'package:flutter/widgets.dart';

class NanoFormFieldScope extends InheritedWidget {
  const NanoFormFieldScope({
    super.key,
    required this.hasError,
    required super.child,
  });

  final bool hasError;

  static NanoFormFieldScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<NanoFormFieldScope>();

  @override
  bool updateShouldNotify(NanoFormFieldScope oldWidget) =>
      oldWidget.hasError != hasError;
}
