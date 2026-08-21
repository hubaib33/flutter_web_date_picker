import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_web_date_picker/flutter_web_date_picker.dart';

/// Pumps a single [WebDateField] and reports what it hands back.
Widget _host({
  DateTime? value,
  DateTime? firstDate,
  DateTime? lastDate,
  required ValueChanged<DateTime> onChanged,
}) {
  DateTime? current = value;
  return MaterialApp(
    home: Scaffold(
      body: StatefulBuilder(
        builder: (context, setState) => SizedBox(
          width: 320,
          child: WebDateField(
            'Date',
            value: current,
            firstDate: firstDate,
            lastDate: lastDate,
            onChanged: (d) {
              setState(() => current = d);
              onChanged(d);
            },
          ),
        ),
      ),
    ),
  );
}

/// The outline color the [InputDecorator] is currently painting.
Color _borderColor(WidgetTester tester) {
  final decorator = tester.widget<InputDecorator>(find.byType(InputDecorator));
  final d = decorator.decoration;
  if (!d.enabled) return d.disabledBorder!.borderSide.color;
  return decorator.isFocused
      ? d.focusedBorder!.borderSide.color
      : d.enabledBorder!.borderSide.color;
}

void main() {
  testWidgets('renders the label and an empty value', (tester) async {
    await tester.pumpWidget(_host(onChanged: (_) {}));

    expect(find.text('DATE'), findsOneWidget);
    expect(find.text(''), findsOneWidget);
  });

  testWidgets('formats the value as dd / MM / yyyy', (tester) async {
    await tester.pumpWidget(
      _host(value: DateTime(2026, 3, 7), onChanged: (_) {}),
    );

    expect(find.text('07 / 03 / 2026'), findsOneWidget);
  });

  testWidgets('a tap opens the calendar and a day tap reports it',
      (tester) async {
    DateTime? picked;
    await tester.pumpWidget(
      _host(value: DateTime(2026, 3, 7), onChanged: (d) => picked = d),
    );

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    expect(find.text('March 2026'), findsOneWidget);

    await tester.tap(find.text('15'));
    await tester.pumpAndSettle();

    expect(picked, DateTime(2026, 3, 15));
    expect(find.text('15 / 03 / 2026'), findsOneWidget);
    // The panel closes on selection.
    expect(find.text('March 2026'), findsNothing);
  });

  testWidgets('the header toggles the year picker', (tester) async {
    await tester.pumpWidget(
      _host(value: DateTime(2026, 3, 7), onChanged: (_) {}),
    );

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('March 2026'));
    await tester.pumpAndSettle();

    expect(find.text('2021 - 2032'), findsOneWidget);
  });

  testWidgets('days outside firstDate / lastDate are not selectable',
      (tester) async {
    DateTime? picked;
    await tester.pumpWidget(_host(
      value: DateTime(2026, 3, 10),
      firstDate: DateTime(2026, 3, 5),
      lastDate: DateTime(2026, 3, 20),
      onChanged: (d) => picked = d,
    ));

    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    expect(picked, isNull, reason: 'March 1 is before firstDate');

    await tester.tap(find.text('12'));
    await tester.pumpAndSettle();
    expect(picked, DateTime(2026, 3, 12));
  });

  testWidgets('constructor border colors apply unfocused and focused',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 320,
          child: WebDateField(
            'Date',
            value: DateTime(2026, 3, 7),
            onChanged: (_) {},
            borderColor: const Color(0xFFAABBCC),
            focusedBorderColor: const Color(0xFF00AA88),
          ),
        ),
      ),
    ));

    expect(_borderColor(tester), const Color(0xFFAABBCC));

    // Focusing (which also opens the calendar) swaps in the focus color.
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    expect(_borderColor(tester), const Color(0xFF00AA88));
  });

  testWidgets('a style supplies the border colors just as well',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: WebDatePickerTheme(
          style: const WebDatePickerStyle(
            borderColor: Color(0xFF112233),
            focusedBorderColor: Color(0xFF445566),
            borderWidth: 1.5,
          ),
          child: SizedBox(
            width: 320,
            child: WebDateField(
              'Date',
              value: DateTime(2026, 3, 7),
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    ));

    expect(_borderColor(tester), const Color(0xFF112233));
    final decorator =
        tester.widget<InputDecorator>(find.byType(InputDecorator));
    expect(decorator.decoration.enabledBorder!.borderSide.width, 1.5);
  });

  testWidgets('disabledBorderColor paints while enabled is false',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 320,
          child: WebDateField(
            'Date',
            value: DateTime(2026, 3, 7),
            onChanged: (_) {},
            enabled: false,
            borderColor: const Color(0xFFAABBCC),
            disabledBorderColor: const Color(0xFFEEEEEE),
          ),
        ),
      ),
    ));

    expect(_borderColor(tester), const Color(0xFFEEEEEE));
  });
}
