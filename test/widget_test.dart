import 'package:block_r_sh_core/game/schemes.dart';
import 'package:block_r_sh_core/game/shaft_engine.dart';
import 'package:block_r_sh_core/theme.dart';
import 'package:block_r_sh_core/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs one scheme to completion with the given set of flipped rows.
GameResult _run(Scheme scheme, Set<int> flips) {
  final ShaftEngine engine = ShaftEngine(scheme);
  for (final int row in flips) {
    engine.flip(row);
  }
  int guard = 0;
  while (!engine.finished && guard++ < 200) {
    engine.tick();
  }
  return engine.toResult();
}

void main() {
  group('shaft engine', () {
    test('every scheme terminates without a player input', () {
      for (final Scheme scheme in kSchemes) {
        final GameResult result = _run(scheme, const <int>{});
        expect(result.score, greaterThan(0));
      }
    });

    test('scheme 01 is won by flipping the platform above the core', () {
      final Scheme scheme = kSchemes.first;
      final ShaftEngine engine = ShaftEngine(scheme);
      final int row = engine.nearestFlipRow();

      expect(row, scheme.rows - 2);
      expect(engine.flip(row), isTrue);
      expect(engine.switchesLeft, scheme.switches - 1);

      int guard = 0;
      while (!engine.finished && guard++ < 200) {
        engine.tick();
      }
      expect(engine.phase, ShaftPhase.win);
      expect(engine.energy, scheme.maxEnergy);
    });

    test('platforms at or below the core cannot be flipped', () {
      final ShaftEngine engine = ShaftEngine(kSchemes.first);
      expect(engine.canFlip(engine.coreRow), isFalse);
      expect(engine.canFlip(engine.coreRow - 1), isTrue);
      expect(engine.canFlip(0), isFalse);
    });

    test('a hazard hit costs energy and nudges the core inwards', () {
      final Scheme scheme = kSchemes.first;
      final ShaftEngine engine = ShaftEngine(scheme);
      int guard = 0;
      while (!engine.finished && engine.energy == scheme.maxEnergy) {
        if (guard++ > 200) break;
        engine.tick();
      }
      expect(engine.energy, lessThan(scheme.maxEnergy));
      expect(engine.coreCol, inInclusiveRange(0, 4));
    });
  });

  testWidgets('stat pill renders its value and caption', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const Scaffold(
          body: Center(
            child: StatCardPill(
              value: '1240',
              label: 'score',
              valueColor: AppColors.info,
            ),
          ),
        ),
      ),
    );

    expect(find.text('1240'), findsOneWidget);
    expect(find.text('SCORE'), findsOneWidget);
  });
}
