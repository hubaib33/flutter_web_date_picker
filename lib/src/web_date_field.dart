import 'package:flutter/material.dart';

import 'calendar_dropdown_field.dart';
import 'glow_focus.dart';
import 'web_date_picker_style.dart';

/// One-liner date field for dense forms: label + value + onChanged.
///
/// Wraps [CalendarDropdownField] with the focus glow, the Tab-order slot and
/// the default decoration already wired, so a form row reads:
///
/// ```dart
/// WebDateField(
///   'Date',
///   tab: 12,
///   value: controller.pickUpDate,
///   onChanged: (d) => setState(() => controller.pickUpDate = d),
/// )
/// ```
///
/// Styling comes from [WebDatePickerStyle.of] — set
/// [WebDatePickerStyle.defaults] once, or wrap the form in a
/// [WebDatePickerTheme], and no call site needs colors or font sizes.
///
/// The outline is the one thing forms tend to vary per screen, so it is also
/// available straight on the constructor:
///
/// ```dart
/// WebDateField(
///   'Date',
///   value: date,
///   onChanged: onChanged,
///   borderColor: Colors.grey.shade300,   // unfocused
///   focusedBorderColor: Colors.teal,     // focused / open (also the glow)
/// )
/// ```
class WebDateField extends StatelessWidget {
  const WebDateField(
    this.label, {
    super.key,
    required this.value,
    required this.onChanged,
    this.tab,
    this.style,
    this.borderColor,
    this.focusedBorderColor,
    this.disabledBorderColor,
    this.borderWidth,
    this.focusedBorderWidth,
    this.decoration,
    this.textStyle,
    this.firstDate,
    this.lastDate,
    this.format,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.topGap = 4,
  });

  /// Floating label, uppercased by the style.
  final String label;

  /// Currently selected day, or null for an empty field.
  final DateTime? value;

  /// Fires only when the user confirms a day.
  final ValueChanged<DateTime> onChanged;

  /// Tab order within the enclosing [FocusTraversalGroup]. Null leaves the
  /// field in natural (widget-tree) order.
  final num? tab;

  final WebDatePickerStyle? style;

  /// Outline color while the field is unfocused. Overrides
  /// [WebDatePickerStyle.borderColor], so a call site can restyle just the
  /// border without building a whole style.
  final Color? borderColor;

  /// Outline color while the field is focused or the calendar is open. Also
  /// tints the focus glow. Overrides [WebDatePickerStyle.focusedBorderColor].
  final Color? focusedBorderColor;

  /// Outline color while `enabled: false`.
  final Color? disabledBorderColor;

  /// Outline thickness while unfocused / disabled.
  final double? borderWidth;

  /// Outline thickness while focused or open.
  final double? focusedBorderWidth;

  final InputDecoration? decoration;
  final TextStyle? textStyle;

  /// Earliest / latest selectable day, inclusive. Null means unbounded.
  final DateTime? firstDate;
  final DateTime? lastDate;

  /// Defaults to `dd / MM / yyyy`.
  final DateTextFormatter? format;

  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;

  /// Space above the field, so rows of fields line up with labelled siblings.
  final double topGap;

  @override
  Widget build(BuildContext context) {
    var s = style ?? WebDatePickerStyle.of(context);
    if (borderColor != null ||
        focusedBorderColor != null ||
        disabledBorderColor != null ||
        borderWidth != null ||
        focusedBorderWidth != null) {
      s = s.copyWith(
        borderColor: borderColor,
        focusedBorderColor: focusedBorderColor,
        disabledBorderColor: disabledBorderColor,
        borderWidth: borderWidth,
        focusedBorderWidth: focusedBorderWidth,
      );
    }

    Widget field = CalendarDropdownField(
      label: label,
      value: value,
      onChanged: onChanged,
      style: s,
      decoration: decoration,
      textStyle: textStyle,
      firstDate: firstDate,
      lastDate: lastDate,
      format: format,
      enabled: enabled,
      autofocus: autofocus,
      focusNode: focusNode,
    );

    if (s.glow) {
      field = GlowFocus(
        radius: s.glowRadius,
        accent: s.effectiveFocusedBorderColor,
        child: field,
      );
    }
    if (tab != null) {
      field = FocusTraversalOrder(
        order: NumericFocusOrder(tab!.toDouble()),
        child: field,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topGap > 0) SizedBox(height: topGap),
        field,
      ],
    );
  }
}
