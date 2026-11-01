import 'dart:ui' show Brightness;

import 'package:flutter/animation.dart' show Curve;
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/painting.dart';

/// Status color triad (foreground / background / border) —
/// `color.status.{danger,success,warning,info}.*` tokens.
class NanoStatusColors {
  const NanoStatusColors({
    required this.foreground,
    required this.background,
    required this.border,
  });

  final Color foreground;
  final Color background;
  final Color border;

  NanoStatusColors lerp(NanoStatusColors other, double t) => NanoStatusColors(
    foreground: Color.lerp(foreground, other.foreground, t)!,
    background: Color.lerp(background, other.background, t)!,
    border: Color.lerp(border, other.border, t)!,
  );

  @override
  bool operator ==(Object other) =>
      other is NanoStatusColors &&
      other.foreground == foreground &&
      other.background == background &&
      other.border == border;

  @override
  int get hashCode => Object.hash(foreground, background, border);
}

/// Semantic color roles from the `color.*` token layer.
/// Components reference these, never primitives.
class NanoColors {
  const NanoColors({
    required this.canvas,
    required this.surface,
    required this.surfaceSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.iconPrimary,
    required this.iconSecondary,
    required this.accent,
    required this.onAccent,
    required this.actionPrimaryBackground,
    required this.actionPrimaryForeground,
    required this.actionDisabledBackground,
    required this.actionDisabledForeground,
    required this.link,
    required this.accentSecondary,
    required this.border,
    required this.borderStrong,
    required this.borderFocus,
    required this.scrim,
    required this.shadow,
    required this.danger,
    required this.success,
    required this.warning,
    required this.info,
  });

  final Color canvas;
  final Color surface;
  final Color surfaceSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color iconPrimary;
  final Color iconSecondary;
  final Color accent;
  final Color onAccent;
  final Color actionPrimaryBackground;
  final Color actionPrimaryForeground;
  final Color actionDisabledBackground;
  final Color actionDisabledForeground;
  final Color link;
  final Color accentSecondary;
  final Color border;
  final Color borderStrong;
  final Color borderFocus;
  final Color scrim;
  final Color shadow;
  final NanoStatusColors danger;
  final NanoStatusColors success;
  final NanoStatusColors warning;
  final NanoStatusColors info;

  NanoColors lerp(NanoColors other, double t) => NanoColors(
    canvas: Color.lerp(canvas, other.canvas, t)!,
    surface: Color.lerp(surface, other.surface, t)!,
    surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
    textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
    textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
    textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
    iconPrimary: Color.lerp(iconPrimary, other.iconPrimary, t)!,
    iconSecondary: Color.lerp(iconSecondary, other.iconSecondary, t)!,
    accent: Color.lerp(accent, other.accent, t)!,
    onAccent: Color.lerp(onAccent, other.onAccent, t)!,
    actionPrimaryBackground: Color.lerp(
      actionPrimaryBackground,
      other.actionPrimaryBackground,
      t,
    )!,
    actionPrimaryForeground: Color.lerp(
      actionPrimaryForeground,
      other.actionPrimaryForeground,
      t,
    )!,
    actionDisabledBackground: Color.lerp(
      actionDisabledBackground,
      other.actionDisabledBackground,
      t,
    )!,
    actionDisabledForeground: Color.lerp(
      actionDisabledForeground,
      other.actionDisabledForeground,
      t,
    )!,
    link: Color.lerp(link, other.link, t)!,
    accentSecondary: Color.lerp(accentSecondary, other.accentSecondary, t)!,
    border: Color.lerp(border, other.border, t)!,
    borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
    borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
    scrim: Color.lerp(scrim, other.scrim, t)!,
    shadow: Color.lerp(shadow, other.shadow, t)!,
    danger: danger.lerp(other.danger, t),
    success: success.lerp(other.success, t),
    warning: warning.lerp(other.warning, t),
    info: info.lerp(other.info, t),
  );

  @override
  bool operator ==(Object other) =>
      other is NanoColors &&
      other.canvas == canvas &&
      other.surface == surface &&
      other.surfaceSubtle == surfaceSubtle &&
      other.textPrimary == textPrimary &&
      other.textSecondary == textSecondary &&
      other.textDisabled == textDisabled &&
      other.iconPrimary == iconPrimary &&
      other.iconSecondary == iconSecondary &&
      other.accent == accent &&
      other.onAccent == onAccent &&
      other.actionPrimaryBackground == actionPrimaryBackground &&
      other.actionPrimaryForeground == actionPrimaryForeground &&
      other.actionDisabledBackground == actionDisabledBackground &&
      other.actionDisabledForeground == actionDisabledForeground &&
      other.link == link &&
      other.accentSecondary == accentSecondary &&
      other.border == border &&
      other.borderStrong == borderStrong &&
      other.borderFocus == borderFocus &&
      other.scrim == scrim &&
      other.shadow == shadow &&
      other.danger == danger &&
      other.success == success &&
      other.warning == warning &&
      other.info == info;

  @override
  int get hashCode => Object.hashAll([
    canvas,
    surface,
    surfaceSubtle,
    textPrimary,
    textSecondary,
    textDisabled,
    iconPrimary,
    iconSecondary,
    accent,
    onAccent,
    actionPrimaryBackground,
    actionPrimaryForeground,
    actionDisabledBackground,
    actionDisabledForeground,
    link,
    accentSecondary,
    border,
    borderStrong,
    borderFocus,
    scrim,
    shadow,
    danger,
    success,
    warning,
    info,
  ]);

  @override
  String toString() => 'NanoColors(…)';
}

/// Semantic text styles — `DTCG.Type.*` token roles. Color is applied by
/// components, not baked in.
class NanoTypeScale {
  const NanoTypeScale({
    required this.displayHero,
    required this.displayMetric,
    required this.displayCompact,
    required this.headingH1,
    required this.headingH2,
    required this.headingH3,
    required this.headingH4,
    required this.headingH5,
    required this.headingH6,
    required this.bodyDefault,
    required this.bodyReading,
    required this.bodySupporting,
    required this.labelAction,
    required this.labelMetadata,
    required this.labelNavigation,
  });

  final TextStyle displayHero;
  final TextStyle displayMetric;
  final TextStyle displayCompact;
  final TextStyle headingH1;
  final TextStyle headingH2;
  final TextStyle headingH3;
  final TextStyle headingH4;
  final TextStyle headingH5;
  final TextStyle headingH6;
  final TextStyle bodyDefault;
  final TextStyle bodyReading;
  final TextStyle bodySupporting;
  final TextStyle labelAction;
  final TextStyle labelMetadata;
  final TextStyle labelNavigation;

  NanoTypeScale lerp(NanoTypeScale other, double t) => NanoTypeScale(
    displayHero: TextStyle.lerp(displayHero, other.displayHero, t)!,
    displayMetric: TextStyle.lerp(displayMetric, other.displayMetric, t)!,
    displayCompact: TextStyle.lerp(displayCompact, other.displayCompact, t)!,
    headingH1: TextStyle.lerp(headingH1, other.headingH1, t)!,
    headingH2: TextStyle.lerp(headingH2, other.headingH2, t)!,
    headingH3: TextStyle.lerp(headingH3, other.headingH3, t)!,
    headingH4: TextStyle.lerp(headingH4, other.headingH4, t)!,
    headingH5: TextStyle.lerp(headingH5, other.headingH5, t)!,
    headingH6: TextStyle.lerp(headingH6, other.headingH6, t)!,
    bodyDefault: TextStyle.lerp(bodyDefault, other.bodyDefault, t)!,
    bodyReading: TextStyle.lerp(bodyReading, other.bodyReading, t)!,
    bodySupporting: TextStyle.lerp(bodySupporting, other.bodySupporting, t)!,
    labelAction: TextStyle.lerp(labelAction, other.labelAction, t)!,
    labelMetadata: TextStyle.lerp(labelMetadata, other.labelMetadata, t)!,
    labelNavigation: TextStyle.lerp(labelNavigation, other.labelNavigation, t)!,
  );

  @override
  bool operator ==(Object other) =>
      other is NanoTypeScale &&
      other.displayHero == displayHero &&
      other.displayMetric == displayMetric &&
      other.displayCompact == displayCompact &&
      other.headingH1 == headingH1 &&
      other.headingH2 == headingH2 &&
      other.headingH3 == headingH3 &&
      other.headingH4 == headingH4 &&
      other.headingH5 == headingH5 &&
      other.headingH6 == headingH6 &&
      other.bodyDefault == bodyDefault &&
      other.bodyReading == bodyReading &&
      other.bodySupporting == bodySupporting &&
      other.labelAction == labelAction &&
      other.labelMetadata == labelMetadata &&
      other.labelNavigation == labelNavigation;

  @override
  int get hashCode => Object.hashAll([
    displayHero,
    displayMetric,
    displayCompact,
    headingH1,
    headingH2,
    headingH3,
    headingH4,
    headingH5,
    headingH6,
    bodyDefault,
    bodyReading,
    bodySupporting,
    labelAction,
    labelMetadata,
    labelNavigation,
  ]);
}

/// Spacing roles — `spacing.*` tokens.
class NanoSpacingScale {
  const NanoSpacingScale({
    required this.insetControl,
    required this.insetCard,
    required this.insetDialog,
    required this.insetDefault,
    required this.stackDefault,
    required this.stackLabelContent,
    required this.stackSections,
    required this.inlineActions,
    required this.inlineIconLabel,
    required this.gutterPage,
    required this.gutterGrid,
  });

  final double insetControl;
  final double insetCard;
  final double insetDialog;
  final double insetDefault;
  final double stackDefault;
  final double stackLabelContent;
  final double stackSections;
  final double inlineActions;
  final double inlineIconLabel;
  final double gutterPage;
  final double gutterGrid;

  NanoSpacingScale lerp(NanoSpacingScale other, double t) => NanoSpacingScale(
    insetControl: _lerpD(insetControl, other.insetControl, t),
    insetCard: _lerpD(insetCard, other.insetCard, t),
    insetDialog: _lerpD(insetDialog, other.insetDialog, t),
    insetDefault: _lerpD(insetDefault, other.insetDefault, t),
    stackDefault: _lerpD(stackDefault, other.stackDefault, t),
    stackLabelContent: _lerpD(stackLabelContent, other.stackLabelContent, t),
    stackSections: _lerpD(stackSections, other.stackSections, t),
    inlineActions: _lerpD(inlineActions, other.inlineActions, t),
    inlineIconLabel: _lerpD(inlineIconLabel, other.inlineIconLabel, t),
    gutterPage: _lerpD(gutterPage, other.gutterPage, t),
    gutterGrid: _lerpD(gutterGrid, other.gutterGrid, t),
  );

  @override
  bool operator ==(Object other) =>
      other is NanoSpacingScale &&
      other.insetControl == insetControl &&
      other.insetCard == insetCard &&
      other.insetDialog == insetDialog &&
      other.insetDefault == insetDefault &&
      other.stackDefault == stackDefault &&
      other.stackLabelContent == stackLabelContent &&
      other.stackSections == stackSections &&
      other.inlineActions == inlineActions &&
      other.inlineIconLabel == inlineIconLabel &&
      other.gutterPage == gutterPage &&
      other.gutterGrid == gutterGrid;

  @override
  int get hashCode => Object.hash(
    insetControl,
    insetCard,
    insetDialog,
    insetDefault,
    stackDefault,
    stackLabelContent,
    stackSections,
    inlineActions,
    inlineIconLabel,
    gutterPage,
    gutterGrid,
  );
}

/// Corner radii — `radii.*` tokens.
class NanoRadiusScale {
  const NanoRadiusScale({
    required this.controlDefault,
    required this.controlButton,
    required this.controlInput,
    required this.surfaceCard,
    required this.surfaceDialog,
    required this.surfacePopover,
    required this.pill,
    required this.avatar,
    required this.none,
  });

  final double controlDefault;
  final double controlButton;
  final double controlInput;
  final double surfaceCard;
  final double surfaceDialog;
  final double surfacePopover;
  final double pill;
  final double avatar;
  final double none;

  NanoRadiusScale lerp(NanoRadiusScale other, double t) => NanoRadiusScale(
    controlDefault: _lerpD(controlDefault, other.controlDefault, t),
    controlButton: _lerpD(controlButton, other.controlButton, t),
    controlInput: _lerpD(controlInput, other.controlInput, t),
    surfaceCard: _lerpD(surfaceCard, other.surfaceCard, t),
    surfaceDialog: _lerpD(surfaceDialog, other.surfaceDialog, t),
    surfacePopover: _lerpD(surfacePopover, other.surfacePopover, t),
    pill: _lerpD(pill, other.pill, t),
    avatar: _lerpD(avatar, other.avatar, t),
    none: _lerpD(none, other.none, t),
  );

  @override
  bool operator ==(Object other) =>
      other is NanoRadiusScale &&
      other.controlDefault == controlDefault &&
      other.controlButton == controlButton &&
      other.controlInput == controlInput &&
      other.surfaceCard == surfaceCard &&
      other.surfaceDialog == surfaceDialog &&
      other.surfacePopover == surfacePopover &&
      other.pill == pill &&
      other.avatar == avatar &&
      other.none == none;

  @override
  int get hashCode => Object.hash(
    controlDefault,
    controlButton,
    controlInput,
    surfaceCard,
    surfaceDialog,
    surfacePopover,
    pill,
    avatar,
    none,
  );
}

/// Component sizes — `size.*` tokens.
class NanoSizeScale {
  const NanoSizeScale({
    required this.controlHeightCompact,
    required this.controlHeightDefault,
    required this.controlHeightLarge,
    required this.avatarCompact,
    required this.avatarDefault,
    required this.avatarLarge,
    required this.iconDefault,
    required this.iconInline,
    required this.iconStatus,
    required this.iconAction,
    required this.iconDecorative,
    required this.iconNavigation,
    required this.indicatorDot,
    required this.targetTouchMinimum,
    required this.targetPointerMinimum,
  });

  final double controlHeightCompact;
  final double controlHeightDefault;
  final double controlHeightLarge;
  final double avatarCompact;
  final double avatarDefault;
  final double avatarLarge;
  final double iconDefault;
  final double iconInline;
  final double iconStatus;
  final double iconAction;
  final double iconDecorative;
  final double iconNavigation;
  final double indicatorDot;
  final double targetTouchMinimum;
  final double targetPointerMinimum;

  NanoSizeScale lerp(NanoSizeScale other, double t) => NanoSizeScale(
    controlHeightCompact: _lerpD(
      controlHeightCompact,
      other.controlHeightCompact,
      t,
    ),
    controlHeightDefault: _lerpD(
      controlHeightDefault,
      other.controlHeightDefault,
      t,
    ),
    controlHeightLarge: _lerpD(controlHeightLarge, other.controlHeightLarge, t),
    avatarCompact: _lerpD(avatarCompact, other.avatarCompact, t),
    avatarDefault: _lerpD(avatarDefault, other.avatarDefault, t),
    avatarLarge: _lerpD(avatarLarge, other.avatarLarge, t),
    iconDefault: _lerpD(iconDefault, other.iconDefault, t),
    iconInline: _lerpD(iconInline, other.iconInline, t),
    iconStatus: _lerpD(iconStatus, other.iconStatus, t),
    iconAction: _lerpD(iconAction, other.iconAction, t),
    iconDecorative: _lerpD(iconDecorative, other.iconDecorative, t),
    iconNavigation: _lerpD(iconNavigation, other.iconNavigation, t),
    indicatorDot: _lerpD(indicatorDot, other.indicatorDot, t),
    targetTouchMinimum: _lerpD(targetTouchMinimum, other.targetTouchMinimum, t),
    targetPointerMinimum: _lerpD(
      targetPointerMinimum,
      other.targetPointerMinimum,
      t,
    ),
  );

  @override
  bool operator ==(Object other) =>
      other is NanoSizeScale &&
      other.controlHeightCompact == controlHeightCompact &&
      other.controlHeightDefault == controlHeightDefault &&
      other.controlHeightLarge == controlHeightLarge &&
      other.avatarCompact == avatarCompact &&
      other.avatarDefault == avatarDefault &&
      other.avatarLarge == avatarLarge &&
      other.iconDefault == iconDefault &&
      other.iconInline == iconInline &&
      other.iconStatus == iconStatus &&
      other.iconAction == iconAction &&
      other.iconDecorative == iconDecorative &&
      other.iconNavigation == iconNavigation &&
      other.indicatorDot == indicatorDot &&
      other.targetTouchMinimum == targetTouchMinimum &&
      other.targetPointerMinimum == targetPointerMinimum;

  @override
  int get hashCode => Object.hash(
    controlHeightCompact,
    controlHeightDefault,
    controlHeightLarge,
    avatarCompact,
    avatarDefault,
    avatarLarge,
    iconDefault,
    iconInline,
    iconStatus,
    iconAction,
    iconDecorative,
    iconNavigation,
    indicatorDot,
    targetTouchMinimum,
    targetPointerMinimum,
  );
}

/// Stroke widths — `border.width.*` tokens (border color lives in NanoColors).
class NanoBorders {
  const NanoBorders({
    required this.controlWidth,
    required this.controlFocusWidth,
    required this.dividerWidth,
    required this.surfaceCardWidth,
  });

  final double controlWidth;
  final double controlFocusWidth;
  final double dividerWidth;
  final double surfaceCardWidth;

  NanoBorders lerp(NanoBorders other, double t) => NanoBorders(
    controlWidth: _lerpD(controlWidth, other.controlWidth, t),
    controlFocusWidth: _lerpD(controlFocusWidth, other.controlFocusWidth, t),
    dividerWidth: _lerpD(dividerWidth, other.dividerWidth, t),
    surfaceCardWidth: _lerpD(surfaceCardWidth, other.surfaceCardWidth, t),
  );

  @override
  bool operator ==(Object other) =>
      other is NanoBorders &&
      other.controlWidth == controlWidth &&
      other.controlFocusWidth == controlFocusWidth &&
      other.dividerWidth == dividerWidth &&
      other.surfaceCardWidth == surfaceCardWidth;

  @override
  int get hashCode => Object.hash(
    controlWidth,
    controlFocusWidth,
    dividerWidth,
    surfaceCardWidth,
  );
}

/// Elevation levels — `Elevation.shadow.*` composites as shadow lists.
class NanoElevationScale {
  const NanoElevationScale({
    required this.raised,
    required this.floating,
    required this.overlay,
  });

  final List<BoxShadow> raised;
  final List<BoxShadow> floating;
  final List<BoxShadow> overlay;

  NanoElevationScale lerp(NanoElevationScale other, double t) =>
      NanoElevationScale(
        raised: BoxShadow.lerpList(raised, other.raised, t)!,
        floating: BoxShadow.lerpList(floating, other.floating, t)!,
        overlay: BoxShadow.lerpList(overlay, other.overlay, t)!,
      );

  @override
  bool operator ==(Object other) =>
      other is NanoElevationScale &&
      listEquals(other.raised, raised) &&
      listEquals(other.floating, floating) &&
      listEquals(other.overlay, overlay);

  @override
  int get hashCode => Object.hashAll([...raised, ...floating, ...overlay]);
}

/// Interaction-state opacities — `opacity.state.*` tokens.
class NanoOpacityScale {
  const NanoOpacityScale({
    required this.stateDefault,
    required this.stateDisabled,
    required this.stateDragging,
    required this.stateLoading,
    required this.stateHidden,
  });

  final double stateDefault;
  final double stateDisabled;
  final double stateDragging;
  final double stateLoading;
  final double stateHidden;

  NanoOpacityScale lerp(NanoOpacityScale other, double t) => NanoOpacityScale(
    stateDefault: _lerpD(stateDefault, other.stateDefault, t),
    stateDisabled: _lerpD(stateDisabled, other.stateDisabled, t),
    stateDragging: _lerpD(stateDragging, other.stateDragging, t),
    stateLoading: _lerpD(stateLoading, other.stateLoading, t),
    stateHidden: _lerpD(stateHidden, other.stateHidden, t),
  );

  @override
  bool operator ==(Object other) =>
      other is NanoOpacityScale &&
      other.stateDefault == stateDefault &&
      other.stateDisabled == stateDisabled &&
      other.stateDragging == stateDragging &&
      other.stateLoading == stateLoading &&
      other.stateHidden == stateHidden;

  @override
  int get hashCode => Object.hash(
    stateDefault,
    stateDisabled,
    stateDragging,
    stateLoading,
    stateHidden,
  );
}

/// Durations and curves. The current export carries no motion dimension —
/// these defaults stand in until `motion.*` tokens exist.
class NanoMotionScale {
  const NanoMotionScale({
    required this.durationFast,
    required this.durationBase,
    required this.durationSlow,
    required this.curveStandard,
    required this.curveExit,
  });

  final Duration durationFast;
  final Duration durationBase;
  final Duration durationSlow;
  final Curve curveStandard;
  final Curve curveExit;

  @override
  bool operator ==(Object other) =>
      other is NanoMotionScale &&
      other.durationFast == durationFast &&
      other.durationBase == durationBase &&
      other.durationSlow == durationSlow &&
      other.curveStandard == curveStandard &&
      other.curveExit == curveExit;

  @override
  int get hashCode => Object.hash(
    durationFast,
    durationBase,
    durationSlow,
    curveStandard,
    curveExit,
  );
}

/// The complete, immutable theme for one token combination.
class NanoThemeData {
  const NanoThemeData({
    required this.brightness,
    required this.colors,
    required this.type,
    required this.spacing,
    required this.radius,
    required this.size,
    required this.borders,
    required this.elevation,
    required this.opacity,
    required this.motion,
  });

  final Brightness brightness;
  final NanoColors colors;
  final NanoTypeScale type;
  final NanoSpacingScale spacing;
  final NanoRadiusScale radius;
  final NanoSizeScale size;
  final NanoBorders borders;
  final NanoElevationScale elevation;
  final NanoOpacityScale opacity;
  final NanoMotionScale motion;

  /// Linearly interpolates between two themes.
  ///
  /// [NanoMotionScale] is not interpolated — motion describes *how* to
  /// animate, so the target's motion wins. [brightness] is discrete and
  /// switches at t = 0.5.
  static NanoThemeData lerp(NanoThemeData a, NanoThemeData b, double t) =>
      NanoThemeData(
        brightness: t < 0.5 ? a.brightness : b.brightness,
        colors: a.colors.lerp(b.colors, t),
        type: a.type.lerp(b.type, t),
        spacing: a.spacing.lerp(b.spacing, t),
        radius: a.radius.lerp(b.radius, t),
        size: a.size.lerp(b.size, t),
        borders: a.borders.lerp(b.borders, t),
        elevation: a.elevation.lerp(b.elevation, t),
        opacity: a.opacity.lerp(b.opacity, t),
        motion: b.motion,
      );

  @override
  bool operator ==(Object other) =>
      other is NanoThemeData &&
      other.brightness == brightness &&
      other.colors == colors &&
      other.type == type &&
      other.spacing == spacing &&
      other.radius == radius &&
      other.size == size &&
      other.borders == borders &&
      other.elevation == elevation &&
      other.opacity == opacity &&
      other.motion == motion;

  @override
  int get hashCode => Object.hash(
    brightness,
    colors,
    type,
    spacing,
    radius,
    size,
    borders,
    elevation,
    opacity,
    motion,
  );
}

double _lerpD(double a, double b, double t) => a + (b - a) * t;
