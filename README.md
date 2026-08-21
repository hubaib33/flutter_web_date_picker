# flutter_web_date_picker

A keyboard-driven, react-datepicker-style **date field** for dense Flutter web
forms. The field is read-only and backed by a plain `DateTime?` — no
`TextEditingController`, no Material dialog. Clicking it (or pressing
Enter / Space / ↓) opens a dropdown calendar in an `Overlay`, anchored under the
field.

```dart
WebDateField(
  'Date',
  tab: 12,
  value: controller.pickUpDate,
  onChanged: (d) => setState(() => controller.pickUpDate = d),
)
```

That is the whole call site. Colors, font sizes, the outlined decoration, the
focus glow and the Tab-order slot are all handled by the widget.

## Features

- **One Tab stop.** On focus the icon, border and value text take the accent
  color and the field background tints.
- **Full keyboard control.** Enter / Space / ↓ opens; arrow keys move the day
  (±1 / ±7); PageUp / PageDown page the month; Enter confirms; Esc closes.
- **Month & year pickers.** The header title toggles between the day grid, the
  12-month grid and a 12-year page; `‹ ›` navigate whichever view is showing.
- **Dropdown, not a dialog.** A `CompositedTransformFollower` overlay that
  follows the field and closes on an outside tap, so it works inside scrolling
  forms and dialogs.
- **Optional bounds.** `firstDate` / `lastDate` grey out and block days outside
  the range (both are optional; omit for an unbounded calendar).
- **Themable end to end.** One `WebDatePickerStyle` object carries every color,
  font size and metric.
- **`Today` / `Close` footer**, `enabled: false` state, and a custom `format`
  callback.

## Install

Add it as a git dependency in the host app's `pubspec.yaml`:

```yaml
dependencies:
  flutter_web_date_picker:
    git:
      url: https://github.com/<your-account>/flutter_web_date_picker.git
      ref: main            # or a tag, e.g. v0.1.0
```

Or, while developing side by side:

```yaml
dependencies:
  flutter_web_date_picker:
    path: ../../flutter_web_date_picker
```

Then:

```dart
import 'package:flutter_web_date_picker/flutter_web_date_picker.dart';
```

## Styling

The defaults are an indigo palette (`#312E81`). To restyle everything at once,
set the global default before `runApp`:

```dart
void main() {
  WebDatePickerStyle.defaults = const WebDatePickerStyle(
    accent: Color(0xFF0F766E),
    accentSoft: Color(0xFFCCFBF1),
    focusFill: Color(0xFFE6FFFA),
  );
  runApp(const MyApp());
}
```

Or scope it to one screen:

```dart
WebDatePickerTheme(
  style: WebDatePickerStyle.defaults.copyWith(fieldFontSize: 14),
  child: myForm,
)
```

Or per field: `WebDateField('Date', style: ..., ...)`.

Resolution order is **`style:` argument → nearest `WebDatePickerTheme` →
`WebDatePickerStyle.defaults`**.

## API

| Symbol | Purpose |
| --- | --- |
| `WebDateField` | The short form-row wrapper: label, `tab:`, glow, decoration, layout. |
| `CalendarDropdownField` | The field + dropdown calendar itself, when you want to place it yourself. |
| `WebDatePickerStyle` | Every color / size knob, plus `defaults` and `of(context)`. |
| `WebDatePickerTheme` | `InheritedWidget` that applies one style to a subtree. |
| `GlowFocus` | The reusable focus halo (works around any control). |

### `WebDateField`

| Argument | Default | Notes |
| --- | --- | --- |
| `label` (positional) | required | Uppercased unless `style.uppercaseLabel` is false. |
| `value` | required | `DateTime?`; null renders an empty field. |
| `onChanged` | required | Fires only on a confirmed pick, never on navigation. |
| `tab` | `null` | `NumericFocusOrder` slot; needs an `OrderedTraversalPolicy` ancestor. |
| `firstDate` / `lastDate` | `null` | Inclusive bounds; null is unbounded. |
| `format` | `dd / MM / yyyy` | `String Function(DateTime)`. |
| `enabled` | `true` | False greys the field out and removes it from traversal. |
| `style` / `decoration` / `textStyle` | `null` | Per-field overrides. |
| `autofocus` / `focusNode` | `false` / `null` | Standard focus plumbing. |
| `topGap` | `4` | Space above the field, to line up with labelled siblings. |

`tab:` only matters inside an ordered traversal group:

```dart
FocusTraversalGroup(
  policy: OrderedTraversalPolicy(),
  child: myForm,
)
```

## Demo

`lib/main.dart` is a runnable showcase — default and bounded fields, a
per-field restyle and a disabled field:

```
flutter run -d chrome
```

## Tests

```
flutter test
```
