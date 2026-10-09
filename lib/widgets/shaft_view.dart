import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../game/shaft_engine.dart';
import '../theme.dart';
import 'core_orb.dart';
import 'hud_frame.dart';
import 'magnet_platform.dart';

/// The reactor shaft: a COLS x ROWS grid with magnetic platforms, hazard
/// sections, the beacon on row 0 and the core lifting through it.
///
/// Cell size is derived integrally from the incoming constraints so the board
/// can never overflow its own frame (see `_frame`).
class ShaftView extends StatelessWidget {
  const ShaftView({
    super.key,
    required this.rows,
    required this.platformCols,
    required this.polarities,
    required this.hazardCols,
    required this.coreRow,
    required this.coreCol,
    required this.phase,
    required this.hitRow,
    required this.bottomInset,
    required this.canFlipRow,
    required this.onFlipRow,
  });

  final int rows;
  final List<int> platformCols;
  final List<Polarity> polarities;
  final List<List<int>> hazardCols;
  final int coreRow;
  final int coreCol;
  final ShaftPhase phase;
  final int hitRow;

  /// Vertical room reserved for the floating control bar.
  final double bottomInset;

  final bool Function(int row) canFlipRow;
  final void Function(int row) onFlipRow;

  /// Board padding (10) plus border (2).
  static const double _frame = 12;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxW = math.min(constraints.maxWidth - 32, 380.0);
        final double availH = constraints.maxHeight - bottomInset;

        double cell = ((maxW - 2 * _frame) ~/ GameConfig.cols).toDouble();
        final double cellByHeight =
            ((availH - 2 * _frame) ~/ rows).toDouble();
        if (cellByHeight < cell) cell = cellByHeight;
        if (cell < 14) cell = 14;

        final double boardW = cell * GameConfig.cols + 2 * _frame;
        final double boardH = cell * rows + 2 * _frame;

        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: boardW,
            height: boardH,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  width: 2,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 28,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: _buildLayers(cell, boardW, boardH),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildLayers(double cell, double boardW, double boardH) {
    final List<Widget> layers = <Widget>[
      // Shaft wall artwork, tinted down so the pieces stay readable.
      Positioned.fill(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.bgDeep,
            image: DecorationImage(
              image: AssetImage(AppAssets.bgGame),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      Positioned.fill(
        child: ColoredBox(color: AppColors.bgBase.withValues(alpha: 0.62)),
      ),
      // Static column guides.
      Positioned.fill(
        child: CustomPaint(
          painter: _GuidePainter(cell: cell, frame: _frame, rows: rows),
        ),
      ),
    ];

    // Hazard sections.
    for (int r = 1; r < rows; r++) {
      for (final int c in hazardCols[r]) {
        layers.add(Positioned(
          left: _frame + c * cell,
          top: _frame + r * cell,
          width: cell,
          height: cell,
          child: _HazardCell(cell: cell, flashing: hitRow == r),
        ));
      }
    }

    // Beacon on row 0.
    final double beaconSize = cell * 1.2;
    layers.add(Positioned(
      left: (boardW - beaconSize) / 2,
      top: _frame + (cell - beaconSize) / 2,
      width: beaconSize,
      height: beaconSize,
      child: _Beacon(size: beaconSize, lit: phase == ShaftPhase.win),
    ));

    // Magnetic platforms.
    final double pw = math.max(cell * 1.6, 48.0);
    final double ph = math.max(cell * 0.9, 48.0);
    for (int r = 1; r <= rows - 2; r++) {
      final int m = platformCols[r];
      if (m < 0) continue;
      double left = _frame + m * cell + cell / 2 - pw / 2;
      left = left.clamp(0.0, math.max(0.0, boardW - pw));
      double top = _frame + r * cell + cell / 2 - ph / 2;
      top = top.clamp(0.0, math.max(0.0, boardH - ph));
      final bool active = canFlipRow(r);
      layers.add(Positioned(
        left: left,
        top: top,
        width: pw,
        height: ph,
        child: MagnetPlatform(
          polarity: polarities[r],
          width: math.max(cell * 1.6, 40.0),
          height: math.max(cell * 0.55, 14.0),
          active: active,
          onTap: () => onFlipRow(r),
        ),
      ));
    }

    // The core itself.
    final double coreSize = cell * 0.78;
    layers.add(AnimatedPositioned(
      duration: const Duration(milliseconds: GameConfig.coreMoveMs),
      curve: Curves.easeOutCubic,
      left: _frame + coreCol * cell + (cell - coreSize) / 2,
      top: _frame + coreRow * cell + (cell - coreSize) / 2,
      width: coreSize,
      height: coreSize,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        scale: phase == ShaftPhase.lose ? 0.0 : 1.0,
        child: CoreOrb(size: coreSize),
      ),
    ));

    // Corner brackets over the whole frame.
    layers.add(Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: HudFramePainter(
            color: AppColors.info.withValues(alpha: 0.6),
            length: 18,
          ),
        ),
      ),
    ));

    if (phase == ShaftPhase.hit) {
      layers.add(Positioned.fill(
        child: IgnorePointer(
          child: ColoredBox(
            color: AppColors.signal.withValues(alpha: 0.18),
          ),
        ),
      ));
    }

    return layers;
  }
}

class _HazardCell extends StatelessWidget {
  const _HazardCell({required this.cell, required this.flashing});

  final double cell;
  final bool flashing;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ClipRect(
            child: CustomPaint(
              painter: _HatchPainter(
                color: AppColors.signal
                    .withValues(alpha: flashing ? 0.45 : 0.22),
              ),
            ),
          ),
          Center(
            child: Image.asset(
              AppAssets.spriteHazard,
              width: cell * 0.9,
              height: cell * 0.9,
              fit: BoxFit.contain,
              errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
                  DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.signal.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Beacon extends StatelessWidget {
  const _Beacon({required this.size, required this.lit});

  final double size;
  final bool lit;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.signal.withValues(alpha: lit ? 0.75 : 0.28),
              blurRadius: lit ? 40 : 18,
            ),
          ],
        ),
        child: Image.asset(
          AppAssets.spriteBeacon,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
              const DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.signal,
            ),
          ),
        ),
      ),
    );
  }
}

class _GuidePainter extends CustomPainter {
  const _GuidePainter({
    required this.cell,
    required this.frame,
    required this.rows,
  });

  final double cell;
  final double frame;
  final int rows;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.10)
      ..strokeWidth = 1;
    for (int c = 1; c < GameConfig.cols; c++) {
      final double x = frame + c * cell;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    final Paint rowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (int r = 1; r < rows; r++) {
      final double y = frame + r * cell;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rowPaint);
    }
  }

  @override
  bool shouldRepaint(_GuidePainter oldDelegate) =>
      oldDelegate.cell != cell || oldDelegate.rows != rows;
}

class _HatchPainter extends CustomPainter {
  const _HatchPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    const double gap = 7;
    for (double x = -size.height; x < size.width; x += gap) {
      canvas.drawLine(
          Offset(x, size.height), Offset(x + size.height, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_HatchPainter oldDelegate) => oldDelegate.color != color;
}
