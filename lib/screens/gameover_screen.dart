import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/shaft_engine.dart';
import '../theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/buttons.dart';
import '../widgets/stat_card.dart';

/// Result screen. Named `GameOverScreen` on purpose — the capture agent names
/// screenshots after the screen class.
class GameOverScreen extends StatefulWidget {
  const GameOverScreen({
    super.key,
    required this.result,
    required this.onPlayAgain,
    required this.onSchemes,
    required this.onMenu,
  });

  final GameResult result;
  final VoidCallback onPlayAgain;
  final VoidCallback onSchemes;
  final VoidCallback onMenu;

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 0.86,
    end: 1.0,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

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
    final bool won = widget.result.won;

    return AppShell(
      background: const AssetImage(AppAssets.bgGame),
      overlay: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: won
            ? <Color>[
                AppColors.bgDeep.withValues(alpha: 0.88),
                const Color(0xFF1A1440).withValues(alpha: 0.80),
              ]
            : <Color>[
                AppColors.bgDeep.withValues(alpha: 0.92),
                AppColors.bgBase.withValues(alpha: 0.88),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Spacer(),
            Center(child: _buildSprite(won)),
            const SizedBox(height: 24),
            ScaleTransition(
              scale: _scale,
              child: Text(
                won ? 'YOU WON!' : 'NO LUCK!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3.0,
                  color: won ? AppColors.signal : AppColors.secondary,
                  shadows: <Shadow>[
                    Shadow(
                      color: won ? AppColors.signal : AppColors.secondary,
                      blurRadius: 26,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              won ? 'BEACON ONLINE' : 'CORE LOST IN THE SHAFT',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 3.0,
                color: AppColors.textPrimary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 26),
            _buildStats(),
            const Spacer(),
            PrimaryCta(
              label: 'PLAY AGAIN',
              icon: Icons.refresh,
              onTap: widget.onPlayAgain,
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: SecondaryButton(
                    label: 'NEW SCHEME',
                    icon: Icons.grid_view_rounded,
                    accent: AppColors.info,
                    onTap: widget.onSchemes,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SecondaryButton(
                    label: 'MENU',
                    icon: Icons.home_outlined,
                    accent: AppColors.textSecondary,
                    onTap: widget.onMenu,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSprite(bool won) {
    final Widget image = Image.asset(
      AppAssets.spriteBeacon,
      width: 120,
      height: 120,
      fit: BoxFit.contain,
      errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
          const SizedBox(width: 120, height: 120),
    );

    if (!won) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: image,
      );
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.signal.withValues(alpha: 0.55),
            blurRadius: 40,
          ),
        ],
      ),
      child: image,
    );
  }

  Widget _buildStats() {
    final GameResult r = widget.result;
    final List<Widget> pills = <Widget>[];

    if (r.score > 0) {
      pills.add(StatCardPill(
        value: r.score.toString(),
        label: 'score',
        valueColor: AppColors.info,
      ));
    }
    if (r.switchesLeft > 0) {
      pills.add(StatCardPill(
        value: r.switchesLeft.toString(),
        label: 'switches',
        valueColor: AppColors.primary,
      ));
    }
    if (r.energy > 0) {
      pills.add(StatCardPill(
        value: r.energy.toString(),
        label: 'energy',
        valueColor: AppColors.signal,
      ));
    }

    // A lone pill looks orphaned — drop the whole row instead.
    if (pills.length < 2) return const SizedBox.shrink();

    final List<Widget> row = <Widget>[];
    for (int i = 0; i < pills.length; i++) {
      if (i > 0) row.add(const SizedBox(width: 12));
      row.add(Expanded(
        child: StaggerFade(delayMs: i * 80, child: pills[i]),
      ));
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: row,
      ),
    );
  }
}
