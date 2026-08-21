# Changelog

## 0.1.0

First release. Extracted from the taxi-dispatch booking form as a reusable
package.

- `WebDateField` — one-line date field for form rows (label, `tab:`, value,
  `onChanged`).
- `CalendarDropdownField` — the read-only field plus its overlay dropdown
  calendar: day / month / year views, arrow-key navigation, PageUp / PageDown
  month paging, Enter to confirm, Esc to close.
- `WebDatePickerStyle` + `WebDatePickerTheme` — full theming, with a global
  `defaults` and `of(context)` resolution.
- `GlowFocus` — the reusable focus halo.
- New over the original in-form widget: optional `firstDate` / `lastDate`
  bounds, a custom `format` callback, `enabled: false`, `autofocus` and an
  external `focusNode`.
