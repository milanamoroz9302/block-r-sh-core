import 'package:flutter/material.dart';

import '../assets.dart';
import '../theme.dart';

/// The glowing core sprite with a short comet tail behind it.
class CoreOrb extends StatelessWidget {
  const CoreOrb({
    super.key,
    required this.size,
    this.tail = true,
    this.dimmed = false,
  });

  final double size;
  final bool tail;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final Widget sprite = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.info.withValues(alpha: dimmed ? 0.14 : 0.55),
            blurRadius: size * 0.55,
            spreadRadius: size * 0.05,
          ),
        ],
      ),
      child: Image.asset(
        AppAssets.spriteCore,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (BuildContext c, Object e, StackTrace? s) => DecoratedBox(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.info,
          ),
        ),
      ),
    );

    if (!tail) return sprite;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(painter: const _TailPainter()),
          ),
          sprite,
        ],
      ),
    );
  }
}

class _TailPainter extends CustomPainter {
  const _TailPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const List<double> alphas = <double>[0.30, 0.18, 0.09];
    final double cx = size.width / 2;
    for (int i = 0; i < alphas.length; i++) {
      final Paint paint = Paint()
        ..color = AppColors.info.withValues(alpha: alphas[i]);
      final double r = size.width * (0.26 - i * 0.06);
      final double dy = size.height * (0.62 + i * 0.26);
      if (r <= 0) continue;
      canvas.drawCircle(Offset(cx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(_TailPainter oldDelegate) => false;
}
