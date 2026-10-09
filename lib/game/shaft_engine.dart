import 'game_config.dart';
import 'schemes.dart';

/// Blue platforms push the core away, violet platforms pull it in.
enum Polarity { push, pull }

/// Lifecycle of one run through the shaft.
enum ShaftPhase { armed, rising, hit, win, lose }

/// Result handed to the game-over screen.
class GameResult {
  const GameResult({
    required this.won,
    required this.score,
    required this.switchesLeft,
    required this.energy,
    required this.schemeIndex,
  });

  final bool won;
  final int score;
  final int switchesLeft;
  final int energy;
  final int schemeIndex;
}

/// Pure, deterministic simulation of one shaft run. No randomness, no timers —
/// the screen owns the clock and calls [tick].
class ShaftEngine {
  ShaftEngine(this.scheme) {
    reset();
  }

  final Scheme scheme;

  late List<Polarity> polarities;
  late int coreRow;
  late int coreCol;
  late int energy;
  late int switchesLeft;
  late ShaftPhase phase;

  /// Row that triggered the most recent hazard hit, `-1` when none.
  int hitRow = -1;

  int get rows => scheme.rows;
  int get maxEnergy => scheme.maxEnergy;
  bool get finished => phase == ShaftPhase.win || phase == ShaftPhase.lose;

  void reset() {
    polarities = List<Polarity>.of(scheme.basePolarities);
    coreRow = scheme.rows - 1;
    coreCol = 2;
    energy = scheme.maxEnergy;
    switchesLeft = scheme.switches;
    phase = ShaftPhase.armed;
    hitRow = -1;
  }

  bool isHazard(int row, int col) => scheme.hazardCols[row].contains(col);

  /// Only platforms strictly above the core can still be re-polarised.
  bool canFlip(int row) =>
      !finished &&
      switchesLeft > 0 &&
      scheme.hasPlatform(row) &&
      row < coreRow;

  /// Nearest flippable platform above the core — the target of the FLIP button.
  int nearestFlipRow() {
    for (int r = coreRow - 1; r >= 1; r--) {
      if (scheme.hasPlatform(r)) return r;
    }
    return -1;
  }

  bool flip(int row) {
    if (!canFlip(row)) return false;
    polarities[row] =
        polarities[row] == Polarity.push ? Polarity.pull : Polarity.push;
    switchesLeft--;
    return true;
  }

  /// Advance the core by one row and apply the magnetism of the row it enters.
  void tick() {
    if (finished) return;
    hitRow = -1;
    coreRow--;

    if (coreRow <= 0) {
      coreRow = 0;
      phase = (coreCol >= 1 && coreCol <= 3 && energy > 0)
          ? ShaftPhase.win
          : ShaftPhase.lose;
      return;
    }

    final int magnet = scheme.platformCols[coreRow];
    if (magnet >= 0) {
      coreCol = _applyMagnet(coreCol, magnet, polarities[coreRow]);
    }

    if (isHazard(coreRow, coreCol)) {
      energy--;
      hitRow = coreRow;
      if (coreCol < 2) {
        coreCol++;
      } else if (coreCol > 2) {
        coreCol--;
      }
      if (energy <= 0) {
        energy = 0;
        phase = ShaftPhase.lose;
        return;
      }
      phase = ShaftPhase.hit;
      return;
    }

    phase = ShaftPhase.rising;
  }

  static int _applyMagnet(int col, int magnet, Polarity polarity) {
    int next = col;
    if (polarity == Polarity.pull) {
      if (col < magnet) {
        next++;
      } else if (col > magnet) {
        next--;
      }
    } else {
      if (col < magnet) {
        next--;
      } else if (col > magnet) {
        next++;
      }
    }
    if (next < 0) next = 0;
    if (next > GameConfig.cols - 1) next = GameConfig.cols - 1;
    return next;
  }

  int get score =>
      energy * 120 + switchesLeft * 80 + (scheme.index + 1) * 200;

  GameResult toResult() => GameResult(
        won: phase == ShaftPhase.win,
        score: score,
        switchesLeft: switchesLeft,
        energy: energy,
        schemeIndex: scheme.index,
      );
}
