import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../theme.dart';
import '../widgets/grain_painter.dart';

/// Branded splash. Deliberately darker and denser than the menu: heavy tint,
/// full-canvas grain, a centred core and no controls at all.
class LoaderScreen extends StatefulWidget {
  const LoaderScreen({super.key});

  @override
  State<LoaderScreen> createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: GameConfig.loaderAnimMs),
  );

  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    // One shot: it settles so the window can go idle for the capture agent.
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.bgDeep,
              image: DecorationImage(
                image: AssetImage(AppAssets.bgLoader),
                fit: BoxFit.cover,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  AppColors.bgDeep.withValues(alpha: 0.88),
                  AppColors.bgBase.withValues(alpha: 0.92),
                  AppColors.bgDeep.withValues(alpha: 0.95),
                ],
              ),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: GrainPainter(points: 130000, seed: 0x2F7EFF01),
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _curve,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.06),
                  end: Offset.zero,
                ).animate(_curve),
                child: _buildBody(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Spacer(),
        SizedBox(
          width: 236,
          height: 236,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned.fill(
                child: CustomPaint(painter: const _RingsPainter()),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 60,
                    ),
                  ],
                ),
                child: Image.asset(
                  AppAssets.spriteCore,
                  width: 132,
                  height: 132,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (BuildContext c, Object e, StackTrace? s) =>
                          const SizedBox(width: 132, height: 132),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 34),
        const Text(
          'BLOCK RUSH',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: 5.0,
            color: AppColors.textPrimary,
            shadows: <Shadow>[
              Shadow(color: AppColors.primary, blurRadius: 24),
            ],
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'CORE',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            letterSpacing: 10.0,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'TOWER RUSH · MAGNETIC SHAFT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.0,
            color: AppColors.textMuted,
          ),
        ),
        const Spacer(),
        // Static progress rail — no tween, nothing animates here.
        Container(
          width: 168,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 114,
              height: 4,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[AppColors.info, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'LOADING...',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 4.0,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 46),
      ],
    );
  }
}

class _RingsPainter extends CustomPainter {
  const _RingsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Offset centre = Offset(size.width / 2, size.height / 2);
    final Paint inner = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AppColors.primary.withValues(alpha: 0.55);
    final Paint outer = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AppColors.secondary.withValues(alpha: 0.35);
    canvas.drawCircle(centre, 86, inner);
    canvas.drawCircle(centre, 108, outer);

    final Paint tick = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AppColors.info.withValues(alpha: 0.7);
    for (int i = 0; i < 4; i++) {
      final double a = (i * 90 + 40) * 3.1415926535 / 180.0;
      canvas.drawArc(
        Rect.fromCircle(center: centre, radius: 108),
        a,
        0.22,
        false,
        tick,
      );
    }
  }

  @override
  bool shouldRepaint(_RingsPainter oldDelegate) => false;
}
