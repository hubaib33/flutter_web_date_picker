import 'package:flutter/material.dart';

/// Every visual knob the date field and its dropdown calendar use.
///
/// The defaults reproduce the indigo/purple booking-form look the widget was
/// extracted from, so most call sites never pass a style at all. Override
/// globally with [WebDatePickerStyle.defaults] (or a [WebDatePickerTheme]),
/// per-field with the `style:` argument, and per-value with [copyWith].
@immutable
class WebDatePickerStyle {
  const WebDatePickerStyle({
    this.accent = const Color(0xFF312E81),
    this.accentSoft = const Color(0xFFEEF2FF),
    this.focusFill = const Color(0xFFE0E7FF),
    this.fillColor = Colors.white,
    this.idleColor = Colors.grey,
    this.fieldTextColor = Colors.black87,
    this.labelColor = Colors.black,
    this.panelColor = Colors.white,
    this.panelBorderColor = const Color(0xFFE5E7EB),
    this.dayTextColor = Colors.black87,
    this.selectedDayTextColor = Colors.white,
    this.disabledDayColor = const Color(0xFFBDBDBD),
    this.closeButtonColor = Colors.grey,
    this.labelFontSize = 13,
    this.fieldFontSize = 12,
    this.headerFontSize = 13,
    this.weekdayFontSize = 11,
    this.dayFontSize = 12,
    this.chipFontSize = 12,
    this.footerFontSize = 12,
    this.borderRadius = 6,
    this.panelRadius = 10,
    this.panelElevation = 8,
    this.panelMinWidth = 300,
    this.panelOffset = 4,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
    this.panelPadding = const EdgeInsets.all(10),
    this.prefixIcon = Icons.calendar_today,
    this.showPrefixIcon = true,
    this.showSuffixIcon = true,
    this.showFooter = true,
    this.uppercaseLabel = true,
    this.glow = true,
    this.glowRadius = 6,
  });

  // ── colors
  /// Focus / selection color: border, icons, header, selected day.
  final Color accent;

  /// Tint behind "today" and the month / year chips.
  final Color accentSoft;

  /// Field background while focused or open.
  final Color focusFill;

  /// Field background at rest.
  final Color fillColor;

  /// Icon + border color at rest.
  final Color idleColor;
  final Color fieldTextColor;
  final Color labelColor;
  final Color panelColor;
  final Color panelBorderColor;
  final Color dayTextColor;
  final Color selectedDayTextColor;

  /// Days outside `firstDate` / `lastDate`.
  final Color disabledDayColor;
  final Color closeButtonColor;

  // ── type scale
  final double labelFontSize;
  final double fieldFontSize;
  final double headerFontSize;
  final double weekdayFontSize;
  final double dayFontSize;
  final double chipFontSize;
  final double footerFontSize;

  // ── metrics
  final double borderRadius;
  final double panelRadius;
  final double panelElevation;

  /// The popup never renders narrower than this, even under a narrow field.
  final double panelMinWidth;

  /// Vertical gap between the field and the popup.
  final double panelOffset;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry panelPadding;

  // ── chrome toggles
  final IconData prefixIcon;
  final bool showPrefixIcon;
  final bool showSuffixIcon;

  /// The "Today" / "Close" row under the grid.
  final bool showFooter;
  final bool uppercaseLabel;

  /// Draw the focus halo around the field.
  final bool glow;
  final double glowRadius;

  /// Text style of the value shown inside the field.
  TextStyle get fieldTextStyle =>
      TextStyle(fontSize: fieldFontSize, color: fieldTextColor);

  /// Text style of the floating label.
  TextStyle get labelTextStyle =>
      TextStyle(fontSize: labelFontSize, color: labelColor);

  /// The outlined, focus-tinted decoration the field uses when the call site
  /// does not pass a `decoration` of its own.
  InputDecoration inputDecoration() => InputDecoration(
        isDense: true,
        contentPadding: contentPadding,
        // Resolved against the InputDecorator state set, so the focus tint
        // lands without any extra plumbing.
        filled: true,
        fillColor: WidgetStateColor.resolveWith((states) =>
            states.contains(WidgetState.focused) ? focusFill : fillColor),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius)),
        enabledBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: accent, width: 2),
        ),
      );

  /// Set once (e.g. in `main()`) to restyle every field in the app.
  static WebDatePickerStyle defaults = const WebDatePickerStyle();

  /// Nearest [WebDatePickerTheme] style, or [defaults].
  static WebDatePickerStyle of(BuildContext context) =>
      WebDatePickerTheme.maybeOf(context) ?? defaults;

  WebDatePickerStyle copyWith({
    Color? accent,
    Color? accentSoft,
    Color? focusFill,
    Color? fillColor,
    Color? idleColor,
    Color? fieldTextColor,
    Color? labelColor,
    Color? panelColor,
    Color? panelBorderColor,
    Color? dayTextColor,
    Color? selectedDayTextColor,
    Color? disabledDayColor,
    Color? closeButtonColor,
    double? labelFontSize,
    double? fieldFontSize,
    double? headerFontSize,
    double? weekdayFontSize,
    double? dayFontSize,
    double? chipFontSize,
    double? footerFontSize,
    double? borderRadius,
    double? panelRadius,
    double? panelElevation,
    double? panelMinWidth,
    double? panelOffset,
    EdgeInsetsGeometry? contentPadding,
    EdgeInsetsGeometry? panelPadding,
    IconData? prefixIcon,
    bool? showPrefixIcon,
    bool? showSuffixIcon,
    bool? showFooter,
    bool? uppercaseLabel,
    bool? glow,
    double? glowRadius,
  }) =>
      WebDatePickerStyle(
        accent: accent ?? this.accent,
        accentSoft: accentSoft ?? this.accentSoft,
        focusFill: focusFill ?? this.focusFill,
        fillColor: fillColor ?? this.fillColor,
        idleColor: idleColor ?? this.idleColor,
        fieldTextColor: fieldTextColor ?? this.fieldTextColor,
        labelColor: labelColor ?? this.labelColor,
        panelColor: panelColor ?? this.panelColor,
        panelBorderColor: panelBorderColor ?? this.panelBorderColor,
        dayTextColor: dayTextColor ?? this.dayTextColor,
        selectedDayTextColor: selectedDayTextColor ?? this.selectedDayTextColor,
        disabledDayColor: disabledDayColor ?? this.disabledDayColor,
        closeButtonColor: closeButtonColor ?? this.closeButtonColor,
        labelFontSize: labelFontSize ?? this.labelFontSize,
        fieldFontSize: fieldFontSize ?? this.fieldFontSize,
        headerFontSize: headerFontSize ?? this.headerFontSize,
        weekdayFontSize: weekdayFontSize ?? this.weekdayFontSize,
        dayFontSize: dayFontSize ?? this.dayFontSize,
        chipFontSize: chipFontSize ?? this.chipFontSize,
        footerFontSize: footerFontSize ?? this.footerFontSize,
        borderRadius: borderRadius ?? this.borderRadius,
        panelRadius: panelRadius ?? this.panelRadius,
        panelElevation: panelElevation ?? this.panelElevation,
        panelMinWidth: panelMinWidth ?? this.panelMinWidth,
        panelOffset: panelOffset ?? this.panelOffset,
        contentPadding: contentPadding ?? this.contentPadding,
        panelPadding: panelPadding ?? this.panelPadding,
        prefixIcon: prefixIcon ?? this.prefixIcon,
        showPrefixIcon: showPrefixIcon ?? this.showPrefixIcon,
        showSuffixIcon: showSuffixIcon ?? this.showSuffixIcon,
        showFooter: showFooter ?? this.showFooter,
        uppercaseLabel: uppercaseLabel ?? this.uppercaseLabel,
        glow: glow ?? this.glow,
        glowRadius: glowRadius ?? this.glowRadius,
      );
}

/// Wrap a subtree to give every [WebDateField] inside it the same style.
class WebDatePickerTheme extends InheritedWidget {
  const WebDatePickerTheme({
    super.key,
    required this.style,
    required super.child,
  });

  final WebDatePickerStyle style;

  static WebDatePickerStyle? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<WebDatePickerTheme>()?.style;

  static WebDatePickerStyle of(BuildContext context) =>
      maybeOf(context) ?? WebDatePickerStyle.defaults;

  @override
  bool updateShouldNotify(WebDatePickerTheme oldWidget) =>
      oldWidget.style != style;
}
