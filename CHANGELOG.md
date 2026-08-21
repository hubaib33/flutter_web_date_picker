# Changelog

## 0.2.0

- Border colors are now per state and settable from the call site:
  `borderColor` (unfocused), `focusedBorderColor` (focused / open),
  `disabledBorderColor`, plus `borderWidth` / `focusedBorderWidth`. They exist
  on `WebDateField`, `CalendarDropdownField` and `WebDatePickerStyle`, so a
  host project can pass them per field or set them once via
  `WebDatePickerStyle.defaults` / `WebDatePickerTheme`.
- `focusedBorderColor` also tints the focus glow, and border colors are applied
  on top of a call-site `decoration`.
- Unchanged defaults: with no border colors passed, the field renders exactly
  as in 0.1.0.

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
