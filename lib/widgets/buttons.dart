import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/game_config.dart';
import '../theme.dart';

/// Gradient call-to-action, 60dp tall, with the AI-rendered CTA plate behind
/// the gradient for texture.
class PrimaryCta extends StatefulWidget {
  const PrimaryCta({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.height = 60,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double height;

  @override
  State<PrimaryCta> createState() => _PrimaryCtaState();
}

class _PrimaryCtaState extends State<PrimaryCta> {
  bool _down = false;

  void _setDown(bool value) {
    if (_down == value) return;
    setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _down ? 0.96 : 1.0,
      duration: const Duration(milliseconds: GameConfig.pressMs),
      curve: Curves.easeOut,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.45),
              blurRadius: 26,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(
                AppAssets.buttonCta,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
                    const ColoredBox(color: AppColors.primary),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      AppColors.primary.withValues(alpha: 0.9),
                      AppColors.secondary.withValues(alpha: 0.9),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  onTapDown: (TapDownDetails _) => _setDown(true),
                  onTapUp: (TapUpDetails _) => _setDown(false),
                  onTapCancel: () => _setDown(false),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(widget.icon, size: 24, color: AppColors.textPrimary),
                      const SizedBox(width: 10),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 17,
                          height: 24 / 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3.0,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Flat bordered button, 48dp tall.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.accent = AppColors.textPrimary,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.textPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 24, color: accent),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 24 / 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
