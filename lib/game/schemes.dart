import 'shaft_engine.dart';

/// A single hand-verified shaft layout.
///
/// Row 0 is the beacon row (columns 1..3), the last row is where the core
/// starts. Rows in between carry exactly one magnetic platform and up to two
/// hazard cells.
class Scheme {
  const Scheme({
    required this.index,
    required this.rows,
    required this.switches,
    required this.hazardCount,
    required this.maxEnergy,
    required this.platformCols,
    required this.basePolarities,
    required this.hazardCols,
  });

  final int index;
  final int rows;
  final int switches;
  final int hazardCount;
  final int maxEnergy;

  /// Column of the magnet per row, `-1` on the beacon and start rows.
  final List<int> platformCols;
  final List<Polarity> basePolarities;
  final List<List<int>> hazardCols;

  String get label => 'SCHEME ${(index + 1).toString().padLeft(2, '0')}';

  String get spec => 'HEIGHT $rows · SWITCHES $switches · HAZARDS $hazardCount';

  /// 1..3 — drives the three difficulty ticks on the scheme card.
  int get difficulty => index < 2 ? 1 : (index < 4 ? 2 : 3);

  bool hasPlatform(int row) => row >= 1 && row <= rows - 2;
}

/// Six fixed layouts. Each one was proven by exhaustive simulation to be
/// winnable within its switch budget without losing a single energy segment,
/// and to end in a loss when the player never touches anything.
const List<Scheme> kSchemes = <Scheme>[
  Scheme(
    index: 0,
    rows: 12,
    switches: 7,
    hazardCount: 3,
    maxEnergy: 3,
    platformCols: <int>[-1, 2, 2, 1, 3, 0, 0, 0, 2, 3, 0, -1],
    basePolarities: <Polarity>[Polarity.push, Polarity.push, Polarity.pull, Polarity.push, Polarity.pull, Polarity.pull, Polarity.push, Polarity.push, Polarity.push, Polarity.push, Polarity.push, Polarity.push],
    hazardCols: <List<int>>[<int>[], <int>[], <int>[], <int>[2], <int>[], <int>[3], <int>[2], <int>[], <int>[], <int>[], <int>[], <int>[]],
  ),
  Scheme(
    index: 1,
    rows: 12,
    switches: 6,
    hazardCount: 4,
    maxEnergy: 3,
    platformCols: <int>[-1, 1, 0, 3, 1, 4, 4, 1, 1, 0, 1, -1],
    basePolarities: <Polarity>[Polarity.push, Polarity.push, Polarity.push, Polarity.pull, Polarity.pull, Polarity.pull, Polarity.push, Polarity.push, Polarity.push, Polarity.push, Polarity.pull, Polarity.push],
    hazardCols: <List<int>>[<int>[], <int>[], <int>[], <int>[1], <int>[], <int>[0, 3], <int>[], <int>[3], <int>[], <int>[], <int>[], <int>[]],
  ),
  Scheme(
    index: 2,
    rows: 14,
    switches: 6,
    hazardCount: 5,
    maxEnergy: 3,
    platformCols: <int>[-1, 2, 3, 0, 1, 2, 0, 0, 4, 2, 3, 0, 2, -1],
    basePolarities: <Polarity>[Polarity.push, Polarity.push, Polarity.pull, Polarity.pull, Polarity.push, Polarity.pull, Polarity.push, Polarity.pull, Polarity.push, Polarity.pull, Polarity.push, Polarity.pull, Polarity.push, Polarity.push],
    hazardCols: <List<int>>[<int>[], <int>[], <int>[2], <int>[1, 2], <int>[], <int>[], <int>[], <int>[], <int>[], <int>[], <int>[0, 2], <int>[], <int>[], <int>[]],
  ),
  Scheme(
    index: 3,
    rows: 14,
    switches: 5,
    hazardCount: 6,
    maxEnergy: 3,
    platformCols: <int>[-1, 0, 1, 1, 3, 4, 0, 4, 3, 0, 4, 3, 1, -1],
    basePolarities: <Polarity>[Polarity.push, Polarity.pull, Polarity.pull, Polarity.pull, Polarity.pull, Polarity.pull, Polarity.pull, Polarity.pull, Polarity.pull, Polarity.pull, Polarity.pull, Polarity.push, Polarity.push, Polarity.push],
    hazardCols: <List<int>>[<int>[], <int>[3], <int>[2], <int>[0], <int>[], <int>[2], <int>[], <int>[3], <int>[2], <int>[], <int>[], <int>[], <int>[], <int>[]],
  ),
  Scheme(
    index: 4,
    rows: 16,
    switches: 5,
    hazardCount: 7,
    maxEnergy: 3,
    platformCols: <int>[-1, 0, 1, 3, 2, 0, 1, 2, 3, 0, 2, 3, 0, 1, 0, -1],
    basePolarities: <Polarity>[Polarity.push, Polarity.pull, Polarity.pull, Polarity.pull, Polarity.push, Polarity.pull, Polarity.push, Polarity.push, Polarity.push, Polarity.push, Polarity.push, Polarity.push, Polarity.pull, Polarity.push, Polarity.pull, Polarity.push],
    hazardCols: <List<int>>[<int>[], <int>[], <int>[3], <int>[], <int>[], <int>[1, 4], <int>[2, 4], <int>[], <int>[], <int>[2], <int>[], <int>[], <int>[2], <int>[], <int>[], <int>[]],
  ),
  Scheme(
    index: 5,
    rows: 16,
    switches: 4,
    hazardCount: 8,
    maxEnergy: 3,
    platformCols: <int>[-1, 2, 4, 0, 1, 2, 3, 1, 0, 2, 3, 1, 2, 4, 0, -1],
    basePolarities: <Polarity>[Polarity.push, Polarity.push, Polarity.pull, Polarity.push, Polarity.push, Polarity.push, Polarity.push, Polarity.pull, Polarity.pull, Polarity.pull, Polarity.pull, Polarity.push, Polarity.push, Polarity.push, Polarity.pull, Polarity.push],
    hazardCols: <List<int>>[<int>[], <int>[3], <int>[], <int>[], <int>[0], <int>[1], <int>[4], <int>[0], <int>[], <int>[4], <int>[1], <int>[], <int>[], <int>[1], <int>[], <int>[]],
  ),
];
