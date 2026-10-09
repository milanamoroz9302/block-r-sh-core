import 'package:flutter/material.dart';

import '../theme.dart';
import 'hud_frame.dart';

/// Dimmed backdrop plus a bordered HUD card. Used for the tutorial and pause.
class OverlayCard extends StatelessWidget {
  const OverlayCard({
    super.key,
    required this.title,
    required this.children,
    required this.onDismiss,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onDismiss,
      child: ColoredBox(
        color: AppColors.bgDeep.withValues(alpha: 0.86),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.55),
                  width: 1.5,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 32,
                  ),
                ],
              ),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: HudFramePainter(
                          color: AppColors.info.withValues(alpha: 0.5),
                          length: 14,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.6,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      ...children,
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One explanation line inside [OverlayCard].
class OverlayHintRow extends StatelessWidget {
  const OverlayHintRow({
    super.key,
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
