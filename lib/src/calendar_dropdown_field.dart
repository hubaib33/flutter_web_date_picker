import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'web_date_picker_style.dart';

/// Signature for turning the selected value into the text shown in the field.
typedef DateTextFormatter = String Function(DateTime value);

/// A read-only date field backed by a `DateTime?` (no [TextEditingController])
/// that opens a react-datepicker-style dropdown calendar.
///
/// * Single Tab stop. On focus the icon, border and value take the accent color.
/// * Enter / Space / ArrowDown (or a click) opens the calendar — an [Overlay]
///   popup anchored under the field, not a Material dialog.
/// * In the calendar: `‹ ›` navigate, the title toggles the month / year
///   pickers, arrow keys move the day selection, PageUp / PageDown page the
///   month, Enter confirms, Esc closes.
///
/// [WebDateField] is the shorter wrapper most call sites want; use this class
/// directly when you need to place the field yourself.
class CalendarDropdownField extends StatefulWidget {
  const CalendarDropdownField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.decoration,
    this.textStyle,
    this.style,
    this.firstDate,
    this.lastDate,
    this.format,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
  });

  /// Currently selected day, or null for an empty field.
  final DateTime? value;

  /// Fires only when the user confirms a day (click, Enter, or "Today").
  final ValueChanged<DateTime> onChanged;

  /// Floating label. Uppercased unless the style says otherwise.
  final String? label;

  /// Overrides the decoration built from [style].
  final InputDecoration? decoration;

  /// Overrides `style.fieldTextStyle` for the value text.
  final TextStyle? textStyle;

  /// Defaults to [WebDatePickerStyle.of] for this context.
  final WebDatePickerStyle? style;

  /// Earliest selectable day (inclusive). Null means unbounded.
  final DateTime? firstDate;

  /// Latest selectable day (inclusive). Null means unbounded.
  final DateTime? lastDate;

  /// Defaults to `dd / MM / yyyy`.
  final DateTextFormatter? format;

  /// When false the field is greyed out and cannot be focused or opened.
  final bool enabled;
  final bool autofocus;

  /// Supply one to drive focus from outside; otherwise an internal node is used.
  final FocusNode? focusNode;

  @override
  State<CalendarDropdownField> createState() => _CalendarDropdownFieldState();
}

class _CalendarDropdownFieldState extends State<CalendarDropdownField> {
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June', //
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  static const _weekdays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  // 0 = days, 1 = months, 2 = years
  static const _viewDays = 0;
  static const _viewMonths = 1;
  static const _viewYears = 2;

  final LayerLink _link = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();

  // Shared so a tap on the field is NOT treated as "outside" the calendar
  // (otherwise the field click closes via TapRegion AND reopens via InkWell).
  final Object _tapGroupId = Object();

  FocusNode? _ownedFieldFocus;
  final FocusNode _calendarFocus = FocusNode(debugLabel: 'dateCalendar');
  OverlayEntry? _entry;

  bool _focused = false;
  int _view = _viewDays;
  late DateTime _visibleMonth; // first-of-month being displayed
  DateTime? _selected;
  late int _yearPageStart;

  FocusNode get _fieldFocus =>
      widget.focusNode ??
      (_ownedFieldFocus ??= FocusNode(debugLabel: 'dateField'));

  WebDatePickerStyle get _style =>
      widget.style ?? WebDatePickerStyle.of(context);

  @override
  void initState() {
    super.initState();
    _fieldFocus.addListener(_onFocusChange);
    _selected = widget.value;
    final base = widget.value ?? DateTime.now();
    _visibleMonth = DateTime(base.year, base.month);
    _yearPageStart = _visibleMonth.year - 5;
  }

  @override
  void didUpdateWidget(covariant CalendarDropdownField old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      old.focusNode?.removeListener(_onFocusChange);
      _ownedFieldFocus?.removeListener(_onFocusChange);
      _fieldFocus.addListener(_onFocusChange);
    }
    if (old.value != widget.value) {
      _selected = widget.value;
      if (widget.value != null) {
        _visibleMonth = DateTime(widget.value!.year, widget.value!.month);
      }
    }
    if (!widget.enabled && _isOpen) _closeCalendar(notify: false);
  }

  @override
  void dispose() {
    _closeCalendar(notify: false);
    widget.focusNode?.removeListener(_onFocusChange);
    _ownedFieldFocus
      ?..removeListener(_onFocusChange)
      ..dispose();
    _calendarFocus.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focused != _fieldFocus.hasFocus) {
      setState(() => _focused = _fieldFocus.hasFocus);
    }
  }

  bool get _isOpen => _entry != null;

  void _toggleCalendar() => _isOpen ? _closeCalendar() : _openCalendar();

  void _openCalendar() {
    if (_isOpen || !widget.enabled) return;
    _view = _viewDays;
    final base = _selected ?? _clamp(DateTime.now());
    _visibleMonth = DateTime(base.year, base.month);
    _yearPageStart = _visibleMonth.year - 5;
    _entry = OverlayEntry(builder: _buildCalendarPanel);
    Overlay.of(context).insert(_entry!);
    setState(() {}); // refresh field chrome (arrow / accent)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _calendarFocus.requestFocus();
    });
  }

  void _closeCalendar({bool notify = true}) {
    _entry?.remove();
    _entry = null;
    if (notify && mounted) setState(() {});
  }

  void _rebuildPanel() => _entry?.markNeedsBuild();

  void _setView(int v) {
    if (v == _viewYears) _yearPageStart = _visibleMonth.year - 5;
    _view = v;
    _rebuildPanel();
  }

  void _navPrev() {
    if (_view == _viewDays) {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    } else if (_view == _viewMonths) {
      _visibleMonth = DateTime(_visibleMonth.year - 1, _visibleMonth.month);
    } else {
      _yearPageStart -= 12;
    }
    _rebuildPanel();
  }

  void _navNext() {
    if (_view == _viewDays) {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    } else if (_view == _viewMonths) {
      _visibleMonth = DateTime(_visibleMonth.year + 1, _visibleMonth.month);
    } else {
      _yearPageStart += 12;
    }
    _rebuildPanel();
  }

  void _pick(DateTime day) {
    if (!_selectable(day)) return;
    _selected = DateTime(day.year, day.month, day.day);
    widget.onChanged(_selected!);
    _closeCalendar();
    _fieldFocus.requestFocus();
  }

  void _moveSelection(int days) {
    final base = _selected ?? _visibleMonth;
    final next = _clamp(DateTime(base.year, base.month, base.day + days));
    _selected = next;
    _visibleMonth = DateTime(next.year, next.month);
    _view = _viewDays;
    _rebuildPanel();
  }

  // ── range helpers (both bounds are optional; null = unbounded)
  bool _selectable(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final first = widget.firstDate;
    final last = widget.lastDate;
    if (first != null &&
        d.isBefore(DateTime(first.year, first.month, first.day))) {
      return false;
    }
    if (last != null && d.isAfter(DateTime(last.year, last.month, last.day))) {
      return false;
    }
    return true;
  }

  DateTime _clamp(DateTime day) {
    final first = widget.firstDate;
    final last = widget.lastDate;
    if (first != null && day.isBefore(first)) {
      return DateTime(first.year, first.month, first.day);
    }
    if (last != null && day.isAfter(last)) {
      return DateTime(last.year, last.month, last.day);
    }
    return DateTime(day.year, day.month, day.day);
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _format(DateTime? v) {
    if (v == null) return '';
    if (widget.format != null) return widget.format!(v);
    final d = v.day.toString().padLeft(2, '0');
    final m = v.month.toString().padLeft(2, '0');
    return '$d / $m / ${v.year}';
  }

  // ── field key handling: open the calendar
  KeyEventResult _onFieldKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.enter ||
        k == LogicalKeyboardKey.numpadEnter ||
        k == LogicalKeyboardKey.space ||
        k == LogicalKeyboardKey.arrowDown) {
      _openCalendar();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // ── calendar key handling: navigate / confirm / close
  KeyEventResult _onCalendarKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.arrowLeft) {
      _moveSelection(-1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowRight) {
      _moveSelection(1);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowUp) {
      _moveSelection(-7);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowDown) {
      _moveSelection(7);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.pageUp) {
      _navPrev();
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.pageDown) {
      _navNext();
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) {
      _pick(_selected ?? _visibleMonth);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.escape) {
      _closeCalendar();
      _fieldFocus.requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  // ──────────────────────────────── field
  @override
  Widget build(BuildContext context) {
    final s = _style;
    final highlight = widget.enabled && (_focused || _isOpen);
    final baseTextStyle = widget.textStyle ?? s.fieldTextStyle;
    final chromeColor = widget.enabled
        ? (highlight ? s.accent : s.idleColor)
        : s.disabledDayColor;

    var decoration = (widget.decoration ?? s.inputDecoration()).copyWith(
      enabled: widget.enabled,
    );
    if (widget.label != null) {
      decoration = decoration.copyWith(
        label: Text(
          s.uppercaseLabel ? widget.label!.toUpperCase() : widget.label!,
        ),
        labelStyle: s.labelTextStyle,
      );
    }
    if (s.showPrefixIcon) {
      decoration = decoration.copyWith(
        prefixIconConstraints:
            const BoxConstraints(minWidth: 28, minHeight: 0),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 8, right: 4),
          child: Icon(s.prefixIcon, size: 15, color: chromeColor),
        ),
      );
    }
    if (s.showSuffixIcon) {
      decoration = decoration.copyWith(
        suffixIconConstraints:
            const BoxConstraints(minWidth: 28, minHeight: 0),
        suffixIcon: Icon(
          _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          size: 20,
          color: chromeColor,
        ),
      );
    }

    return TapRegion(
      groupId: _tapGroupId,
      child: CompositedTransformTarget(
        link: _link,
        child: Focus(
          focusNode: _fieldFocus,
          autofocus: widget.autofocus,
          canRequestFocus: widget.enabled,
          skipTraversal: !widget.enabled,
          onKeyEvent: _onFieldKey,
          child: InkWell(
            key: _fieldKey,
            canRequestFocus: false,
            borderRadius: BorderRadius.circular(s.borderRadius),
            onTap: widget.enabled
                ? () {
                    _fieldFocus.requestFocus();
                    _toggleCalendar();
                  }
                : null,
            child: InputDecorator(
              isFocused: highlight,
              decoration: decoration,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                decoration: highlight
                    ? BoxDecoration(
                        color: s.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3),
                      )
                    : null,
                child: Text(
                  _format(widget.value),
                  style: baseTextStyle.copyWith(
                    color: highlight
                        ? s.accent
                        : (widget.enabled
                            ? baseTextStyle.color
                            : s.disabledDayColor),
                    fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────── calendar popup
  Widget _buildCalendarPanel(BuildContext context) {
    final s = _style;
    final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    final fieldWidth = box?.size.width ?? 280.0;
    final fieldHeight = box?.size.height ?? 40.0;
    final panelWidth =
        fieldWidth < s.panelMinWidth ? s.panelMinWidth : fieldWidth;

    return Positioned(
      width: panelWidth,
      child: CompositedTransformFollower(
        link: _link,
        showWhenUnlinked: false,
        offset: Offset(0, fieldHeight + s.panelOffset),
        child: TapRegion(
          groupId: _tapGroupId,
          onTapOutside: (_) => _closeCalendar(),
          child: Focus(
            focusNode: _calendarFocus,
            onKeyEvent: _onCalendarKey,
            child: Material(
              elevation: s.panelElevation,
              borderRadius: BorderRadius.circular(s.panelRadius),
              child: Container(
                padding: s.panelPadding,
                decoration: BoxDecoration(
                  color: s.panelColor,
                  borderRadius: BorderRadius.circular(s.panelRadius),
                  border: Border.all(color: s.panelBorderColor),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _header(s),
                    const SizedBox(height: 8),
                    if (_view == _viewDays) ...[
                      _weekdayRow(s),
                      const SizedBox(height: 4),
                      _daysGrid(s),
                    ] else if (_view == _viewMonths)
                      _monthsGrid(s)
                    else
                      _yearsGrid(s),
                    if (s.showFooter) ...[
                      const SizedBox(height: 6),
                      _footer(s),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(WebDatePickerStyle s) {
    final String title = _view == _viewYears
        ? '$_yearPageStart - ${_yearPageStart + 11}'
        : '${_months[_visibleMonth.month - 1]} ${_visibleMonth.year}';
    return Row(
      children: [
        _navButton(s, Icons.chevron_left, _navPrev),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => _setView(_view == _viewDays ? _viewYears : _viewDays),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: s.headerFontSize,
                    fontWeight: FontWeight.w700,
                    color: s.accent,
                  ),
                ),
              ),
            ),
          ),
        ),
        _navButton(s, Icons.chevron_right, _navNext),
      ],
    );
  }

  Widget _navButton(
    WebDatePickerStyle s,
    IconData icon,
    VoidCallback onTap,
  ) =>
      InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: s.accent),
        ),
      );

  Widget _weekdayRow(WebDatePickerStyle s) => Row(
        children: [
          for (final w in _weekdays)
            Expanded(
              child: Center(
                child: Text(
                  w,
                  style: TextStyle(
                    fontSize: s.weekdayFontSize,
                    fontWeight: FontWeight.w700,
                    color: s.accent.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
        ],
      );

  Widget _daysGrid(WebDatePickerStyle s) {
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday % 7; // Sunday = 0
    final today = DateTime.now();

    final cells = <Widget>[];
    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var d = 1; d <= daysInMonth; d++) {
      final day = DateTime(_visibleMonth.year, _visibleMonth.month, d);
      final isSelected = _selected != null && _sameDay(_selected!, day);
      final isToday = _sameDay(today, day);
      cells.add(_dayCell(s, d, isSelected, isToday, _selectable(day),
          () => _pick(day)));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      childAspectRatio: 1.1,
      children: cells,
    );
  }

  Widget _dayCell(
    WebDatePickerStyle s,
    int day,
    bool selected,
    bool today,
    bool selectable,
    VoidCallback onTap,
  ) {
    Color bg = Colors.transparent;
    Color fg = s.dayTextColor;
    if (!selectable) {
      fg = s.disabledDayColor;
    } else if (selected) {
      bg = s.accent;
      fg = s.selectedDayTextColor;
    } else if (today) {
      bg = s.accentSoft;
      fg = s.accent;
    }
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: selectable ? onTap : null,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: today && !selected && selectable
              ? Border.all(color: s.accent, width: 1)
              : null,
        ),
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: s.dayFontSize,
            color: fg,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _monthsGrid(WebDatePickerStyle s) => GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.8,
        children: [
          for (var m = 1; m <= 12; m++)
            _chip(
              s,
              _months[m - 1].substring(0, 3),
              m == _visibleMonth.month,
              () {
                _visibleMonth = DateTime(_visibleMonth.year, m);
                _setView(_viewDays);
              },
            ),
        ],
      );

  Widget _yearsGrid(WebDatePickerStyle s) => GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1.8,
        children: [
          for (var i = 0; i < 12; i++)
            _chip(
              s,
              '${_yearPageStart + i}',
              (_yearPageStart + i) == _visibleMonth.year,
              () {
                _visibleMonth =
                    DateTime(_yearPageStart + i, _visibleMonth.month);
                _setView(_viewMonths);
              },
            ),
        ],
      );

  Widget _chip(
    WebDatePickerStyle s,
    String label,
    bool selected,
    VoidCallback onTap,
  ) =>
      InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? s.accent : s.accentSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: s.chipFontSize,
              color: selected ? s.selectedDayTextColor : s.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

  Widget _footer(WebDatePickerStyle s) {
    final todayEnabled = _selectable(DateTime.now());
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: todayEnabled ? () => _pick(DateTime.now()) : null,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Today',
            style: TextStyle(
              color: todayEnabled ? s.accent : s.disabledDayColor,
              fontSize: s.footerFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            _closeCalendar();
            _fieldFocus.requestFocus();
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Close',
            style: TextStyle(
              color: s.closeButtonColor,
              fontSize: s.footerFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
