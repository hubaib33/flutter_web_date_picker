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
class WebDateField extends StatelessWidget {
  const WebDateField(
    this.label, {
    super.key,
    required this.value,
    required this.onChanged,
    this.tab,
    this.style,
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
    final s = style ?? WebDatePickerStyle.of(context);

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
      field = GlowFocus(radius: s.glowRadius, accent: s.accent, child: field);
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
