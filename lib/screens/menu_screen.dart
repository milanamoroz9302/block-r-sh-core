import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/schemes.dart';
import '../theme.dart';
import '../widgets/buttons.dart';
import '../widgets/hud_frame.dart';
import '../widgets/overlay_card.dart';
import '../widgets/stat_card.dart';

/// Bottom-sheet menu: shaft artwork fills the top, a frosted HUD sheet carries
/// the branding, two stat pills and the controls.
class MenuScreen extends StatefulWidget {
  const MenuScreen({
    super.key,
    required this.scheme,
    required this.best,
    required this.onPlay,
    required this.onSchemes,
  });

  final Scheme scheme;
  final int best;
  final VoidCallback onPlay;
  final VoidCallback onSchemes;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final Animation<double> _curve =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  bool _showHowTo = false;

  @override
  void initState() {
    super.initState();
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
      backgroundColor: AppColors.bgBase,
      body: Stack(
        children: <Widget>[
          // Art takes whatever the sheet leaves over, so nothing on it can
          // ever end up hidden behind the sheet on a short screen.
          Column(
            children: <Widget>[
              Expanded(child: _buildArt()),
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.12),
                  end: Offset.zero,
                ).animate(_curve),
                child: FadeTransition(opacity: _curve, child: _buildSheet()),
              ),
            ],
          ),
          if (_showHowTo) Positioned.fill(child: _buildHowTo()),
        ],
      ),
    );
  }

  Widget _buildArt() {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.bgBase,
            image: DecorationImage(
              image: AssetImage(AppAssets.bgMenu),
              fit: BoxFit.cover,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const <double>[0.0, 0.45, 1.0],
              colors: <Color>[
                AppColors.bgDeep.withValues(alpha: 0.45),
                Colors.transparent,
                AppColors.bgBase,
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: const _TrajectoryPainter()),
          ),
        ),
        Align(
          alignment: const Alignment(0, -0.68),
          child: Image.asset(
            AppAssets.spriteBeacon,
            width: 84,
            height: 84,
            fit: BoxFit.contain,
            errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
                const SizedBox(width: 84, height: 84),
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.62),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.info.withValues(alpha: 0.45),
                  blurRadius: 44,
                ),
              ],
            ),
            child: Image.asset(
              AppAssets.spriteCore,
              width: 96,
              height: 96,
              fit: BoxFit.contain,
              errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
                  const SizedBox(width: 96, height: 96),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSheet() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: HudFramePainter(
                  color: AppColors.info.withValues(alpha: 0.6),
                  length: 18,
                  bottom: false,
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      AppAssets.icon1024,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
                          const SizedBox(width: 44, height: 44),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'BLOCK RUSH CORE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.4,
                      color: AppColors.textPrimary,
                      shadows: <Shadow>[
                        Shadow(color: AppColors.primary, blurRadius: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'FLIP POLARITY · LIFT THE CORE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.2,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: StaggerFade(
                          delayMs: 90,
                          child: StatCardPill(
                            value: widget.scheme.label.replaceFirst(
                                'SCHEME ', ''),
                            label: 'scheme',
                            valueColor: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StaggerFade(
                          delayMs: 180,
                          child: StatCardPill(
                            value: widget.best > 0
                                ? widget.best.toString()
                                : '-',
                            label: 'best',
                            valueColor: AppColors.signal,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  PrimaryCta(
                    label: 'PLAY',
                    icon: Icons.bolt,
                    onTap: widget.onPlay,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: SecondaryButton(
                          label: 'SCHEMES',
                          icon: Icons.grid_view_rounded,
                          accent: AppColors.info,
                          onTap: widget.onSchemes,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SecondaryButton(
                          label: 'HOW TO',
                          icon: Icons.help_outline,
                          accent: AppColors.textSecondary,
                          onTap: () => setState(() => _showHowTo = true),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowTo() {
    return OverlayCard(
      title: 'HOW IT WORKS',
      onDismiss: () => setState(() => _showHowTo = false),
      children: <Widget>[
        const OverlayHintRow(
          icon: Icons.north,
          color: AppColors.primary,
          text: 'BLUE PLATFORM PUSHES THE CORE AWAY',
        ),
        const OverlayHintRow(
          icon: Icons.south,
          color: AppColors.secondary,
          text: 'VIOLET PLATFORM PULLS IT IN',
        ),
        const OverlayHintRow(
          icon: Icons.warning_amber_rounded,
          color: AppColors.signal,
          text: 'HAZARD SECTION COSTS ONE ENERGY',
        ),
        const SizedBox(height: 4),
        SecondaryButton(
          label: 'GOT IT',
          accent: AppColors.info,
          onTap: () => setState(() => _showHowTo = false),
        ),
      ],
    );
  }
}

/// Dashed lift trajectory drawn between the beacon and the core on the art.
class _TrajectoryPainter extends CustomPainter {
  const _TrajectoryPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.info.withValues(alpha: 0.5)
      ..strokeWidth = 1.5;
    final double x = size.width / 2;
    // Between the beacon (Alignment -0.68) and the core (Alignment 0.62).
    double y = size.height * 0.24;
    final double end = size.height * 0.74;
    const double dash = 9;
    const double gap = 8;
    while (y < end) {
      canvas.drawLine(Offset(x, y), Offset(x, y + dash), paint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_TrajectoryPainter oldDelegate) => false;
}
