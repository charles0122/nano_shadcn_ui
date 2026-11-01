/// DTCG design-token pipeline for the nano design system.
///
/// The public API covers three needs:
/// * parse W3C DTCG token files ([DtcgParser]),
/// * resolve `{group.token}` references and validate them ([DtcgResolver]),
/// * consume the generated, strongly-typed Dart constants
///   (`NanoPrimitivesColor`, `NanoSemanticColorLight`, …) produced by
///   `dart run nano_tokens:generate`.
library;

export 'src/dtcg/dtcg_parser.dart';
export 'src/dtcg/dtcg_resolver.dart';
export 'src/dtcg/dtcg_token.dart';
export 'src/generated/tokens.g.dart';
export 'src/generated/export.g.dart';
