import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jastip_katalog_generator/core/widgets/double_back_exit_scope.dart';

void main() {
  testWidgets('percobaan back pertama memberi pesan dan kedua keluar', (
    tester,
  ) async {
    var exitCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: DoubleBackExitScope(
          onExit: () async => exitCount++,
          child: const Scaffold(body: Text('Beranda')),
        ),
      ),
    );

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(exitCount, 0);
    expect(find.text('Tekan kembali sekali lagi untuk keluar'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(exitCount, 1);
  });
}
