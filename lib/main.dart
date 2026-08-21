// Demo app for the flutter_web_date_picker package.
// Run with:  flutter run -d chrome
import 'package:flutter/material.dart';

import 'flutter_web_date_picker.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'flutter_web_date_picker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF312E81)),
          scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        ),
        home: const DemoPage(),
      );
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  DateTime? pickUpDate = DateTime.now();
  DateTime? returnDate;
  DateTime? limited;
  DateTime? teal;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text('flutter_web_date_picker')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(24),
                // One traversal group, so the `tab:` numbers below decide the
                // Tab order regardless of widget-tree position.
                child: FocusTraversalGroup(
                  policy: OrderedTraversalPolicy(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Tab to focus • Enter / Space / ↓ opens • arrows move • Esc closes',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: WebDateField(
                              'Date',
                              tab: 1,
                              value: pickUpDate,
                              onChanged: (d) => setState(() => pickUpDate = d),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: WebDateField(
                              'R/Date',
                              tab: 2,
                              value: returnDate,
                              onChanged: (d) => setState(() => returnDate = d),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Bounded range + a custom text format.
                          Expanded(
                            child: WebDateField(
                              'Within 30 days',
                              tab: 3,
                              value: limited,
                              firstDate: now,
                              lastDate: now.add(const Duration(days: 30)),
                              format: (d) => '${d.day}-${d.month}-${d.year}',
                              onChanged: (d) => setState(() => limited = d),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Restyled per field; a WebDatePickerTheme would do
                          // the same for a whole subtree.
                          Expanded(
                            child: WebDateField(
                              'Teal',
                              tab: 4,
                              value: teal,
                              style: const WebDatePickerStyle(
                                accent: Color(0xFF0F766E),
                                accentSoft: Color(0xFFCCFBF1),
                                focusFill: Color(0xFFE6FFFA),
                              ),
                              onChanged: (d) => setState(() => teal = d),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      WebDateField(
                        'Disabled',
                        tab: 5,
                        enabled: false,
                        value: DateTime(2026, 1, 1),
                        onChanged: (_) {},
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Date: $pickUpDate\nR/Date: $returnDate\n'
                        'Limited: $limited\nTeal: $teal',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54, height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
