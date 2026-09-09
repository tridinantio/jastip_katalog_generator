import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/features/trip/domain/entities/trip.dart';
import 'package:jastip_katalog_generator/features/trip/presentation/widgets/trip_create_dialog.dart';

void main() {
  const currencies = [
    CurrencyOption(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
    CurrencyOption(code: 'KRW', name: 'South Korean Won', symbol: '₩'),
  ];

  testWidgets('dialog tambah trip aman saat disimpan', (tester) async {
    TripCreateDraft? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                result = await showDialog<TripCreateDraft>(
                  context: context,
                  builder: (_) => const TripCreateDialog(
                    currencies: currencies,
                    initialCurrencyCode: 'JPY',
                  ),
                );
              },
              child: const Text('Buka'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    final dialog = find.byType(AlertDialog);
    await tester.enterText(
      find.descendant(of: dialog, matching: find.byType(TextFormField)).first,
      'Korea Trip',
    );
    await tester.tap(find.text('Buat trip'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(result?.name, 'Korea Trip');
    expect(result?.currency.code, 'JPY');
    expect(tester.takeException(), isNull);
  });

  testWidgets('dialog tambah trip aman saat dibatalkan', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => const TripCreateDialog(
                  currencies: currencies,
                  initialCurrencyCode: 'JPY',
                ),
              ),
              child: const Text('Buka'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Batal'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull);
  });

  testWidgets('mata uang trip baru dapat dicari berdasarkan nama atau kode', (
    tester,
  ) async {
    TripCreateDraft? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () async {
                result = await showDialog<TripCreateDraft>(
                  context: context,
                  builder: (_) => const TripCreateDialog(
                    currencies: currencies,
                    initialCurrencyCode: 'JPY',
                  ),
                );
              },
              child: const Text('Buka'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka'));
    await tester.pumpAndSettle();
    final dialog = find.byType(AlertDialog);
    await tester.tap(find.text('JPY · Japanese Yen'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(TextField),
      ),
      'won',
    );
    await tester.pump();
    expect(find.text('South Korean Won'), findsOneWidget);
    expect(find.text('Japanese Yen'), findsNothing);

    await tester.tap(find.text('South Korean Won'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(of: dialog, matching: find.byType(TextFormField)).first,
      'Korea Trip',
    );
    await tester.tap(find.text('Buat trip'));
    await tester.pumpAndSettle();

    expect(result?.currency.code, 'KRW');
  });
}
