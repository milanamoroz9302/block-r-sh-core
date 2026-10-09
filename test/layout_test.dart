import 'package:block_r_sh_core/game/schemes.dart';
import 'package:block_r_sh_core/game/shaft_engine.dart';
import 'package:block_r_sh_core/screens/game_screen.dart';
import 'package:block_r_sh_core/screens/gameover_screen.dart';
import 'package:block_r_sh_core/screens/loader_screen.dart';
import 'package:block_r_sh_core/screens/menu_screen.dart';
import 'package:block_r_sh_core/screens/schemes_screen.dart';
import 'package:block_r_sh_core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpAt(WidgetTester t, Widget child, Size size) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.resetPhysicalSize);
  await t.pumpWidget(MaterialApp(theme: buildAppTheme(), home: child));
  await t.pump(const Duration(milliseconds: 600));
}

void main() {
  for (final Size size in <Size>[
    const Size(411, 914),
    const Size(360, 640),
    const Size(320, 568),
  ]) {
    group('layout ${size.width}x${size.height}', () {
      testWidgets('loader', (WidgetTester t) async {
        await pumpAt(t, const LoaderScreen(), size);
      });
      testWidgets('menu', (WidgetTester t) async {
        await pumpAt(
            t,
            MenuScreen(
                scheme: kSchemes.first,
                best: 0,
                onPlay: () {},
                onSchemes: () {}),
            size);
      });
      testWidgets('schemes', (WidgetTester t) async {
        await pumpAt(
            t,
            SchemesScreen(
                selectedIndex: 0,
                bestPerScheme: List<int>.filled(kSchemes.length, 0),
                onSelect: (int i) {},
                onBack: () {}),
            size);
      });
      testWidgets('game', (WidgetTester t) async {
        await pumpAt(
            t,
            GameScreen(
                scheme: kSchemes.last,
                showTutorial: true,
                onExit: () {},
                onGameOver: (GameResult r) {}),
            size);
        await t.pump(const Duration(seconds: 4));
      });
      testWidgets('gameover win', (WidgetTester t) async {
        await pumpAt(
            t,
            GameOverScreen(
                result: const GameResult(
                    won: true,
                    score: 1240,
                    switchesLeft: 6,
                    energy: 3,
                    schemeIndex: 0),
                onPlayAgain: () {},
                onSchemes: () {},
                onMenu: () {}),
            size);
      });
      testWidgets('gameover lose', (WidgetTester t) async {
        await pumpAt(
            t,
            GameOverScreen(
                result: const GameResult(
                    won: false,
                    score: 200,
                    switchesLeft: 0,
                    energy: 0,
                    schemeIndex: 0),
                onPlayAgain: () {},
                onSchemes: () {},
                onMenu: () {}),
            size);
      });
    });
  }
}
