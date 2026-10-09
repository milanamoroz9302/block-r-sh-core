import 'package:block_r_sh_core/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loader -> menu -> game -> gameover -> menu', (
    WidgetTester t,
  ) async {
    t.view.physicalSize = const Size(393, 851);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);

    await t.pumpWidget(const BlockRushCoreApp());
    await t.pump(const Duration(milliseconds: 1500));
    expect(find.text('BLOCK RUSH'), findsOneWidget, reason: 'loader visible');
    expect(find.text('PLAY'), findsNothing, reason: 'no CTA on loader');

    // Loader must hold for exactly 8000ms.
    await t.pump(const Duration(milliseconds: 6400));
    expect(find.text('BLOCK RUSH CORE'), findsNothing, reason: 'still loader');
    await t.pump(const Duration(milliseconds: 200));
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.text('BLOCK RUSH CORE'), findsOneWidget, reason: 'menu');
    expect(find.text('PLAY'), findsOneWidget);

    await t.tap(find.text('PLAY'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    expect(find.text('FLIP'), findsOneWidget, reason: 'game screen');
    expect(find.text('SWITCHES'), findsOneWidget);

    // Tutorial auto-hides so the board is what gets captured.
    await t.pump(const Duration(milliseconds: 3600));
    expect(find.text('HOW IT WORKS'), findsNothing);

    // One FLIP wins scheme 01 and starts the lift immediately.
    await t.tap(find.text('FLIP'));
    for (int i = 0; i < 40; i++) {
      await t.pump(const Duration(milliseconds: 900));
    }
    await t.pump(const Duration(milliseconds: 5000));
    await t.pumpAndSettle(const Duration(milliseconds: 200));

    expect(find.text('YOU WON!'), findsOneWidget, reason: 'result frame');
    expect(find.text('PLAY AGAIN'), findsOneWidget);

    await t.tap(find.text('MENU'));
    await t.pump();
    await t.pumpAndSettle(const Duration(milliseconds: 600));
    expect(find.text('BLOCK RUSH CORE'), findsOneWidget, reason: 'back on menu');
  });

  testWidgets('passive run reaches the result screen on its own', (
    WidgetTester t,
  ) async {
    t.view.physicalSize = const Size(393, 851);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.resetPhysicalSize);

    await t.pumpWidget(const BlockRushCoreApp());
    await t.pump(const Duration(milliseconds: 8100));
    await t.pumpAndSettle(const Duration(milliseconds: 100));
    await t.tap(find.text('PLAY'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));

    // Board still on screen well before auto-start fires.
    await t.pump(const Duration(milliseconds: 20000));
    expect(find.text('FLIP'), findsOneWidget, reason: 'board at +20s');

    for (int i = 0; i < 50; i++) {
      await t.pump(const Duration(milliseconds: 900));
    }
    await t.pump(const Duration(milliseconds: 5000));
    await t.pumpAndSettle(const Duration(milliseconds: 200));
    expect(find.text('NO LUCK!'), findsOneWidget);
  });
}
