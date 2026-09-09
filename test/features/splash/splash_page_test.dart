import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/features/splash/presentation/pages/splash_page.dart';

void main() {
  testWidgets('menampilkan splash lalu membuka halaman berikutnya', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashPage(
          duration: Duration.zero,
          nextPage: Scaffold(body: Text('Beranda')),
        ),
      ),
    );

    expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
    expect(find.text('Jastip Katalog'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Beranda'), findsOneWidget);
  });
}
