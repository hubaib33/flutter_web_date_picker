/// A keyboard-driven, react-datepicker-style date field for Flutter web forms.
///
/// Public API:
///   * [WebDateField]           – the short one-liner for form rows.
///   * [CalendarDropdownField]  – the field + dropdown calendar itself.
///   * [WebDatePickerStyle]     – every color / size knob, with global defaults.
///   * [WebDatePickerTheme]     – apply one style to a whole subtree.
///   * [GlowFocus]              – the reusable focus halo.
library;

export 'src/calendar_dropdown_field.dart'
    show CalendarDropdownField, DateTextFormatter;
export 'src/glow_focus.dart' show GlowFocus;
export 'src/web_date_field.dart' show WebDateField;
export 'src/web_date_picker_style.dart'
    show WebDatePickerStyle, WebDatePickerTheme;
