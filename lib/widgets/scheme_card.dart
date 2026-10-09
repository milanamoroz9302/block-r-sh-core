import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/schemes.dart';
import '../theme.dart';

/// Row in the scheme picker. Every scheme is unlocked.
class SchemeCard extends StatelessWidget {
  const SchemeCard({
    super.key,
    required this.scheme,
    required this.best,
    required this.selected,
    required this.height,
    required this.onTap,
  });

  final Scheme scheme;
  final int best;
  final bool selected;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color border =
        selected ? AppColors.info : AppColors.primary.withValues(alpha: 0.28);
    final double thumb = (height * 0.56).clamp(28.0, 44.0);

    return SizedBox(
      height: height,
      child: Material(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: <Widget>[
                if (selected)
                  Container(
                    width: 4,
                    height: thumb,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppColors.info,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                Image.asset(
                  AppAssets.spriteShaft,
                  width: thumb,
                  height: thumb,
                  fit: BoxFit.contain,
                  errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
                      SizedBox(width: thumb, height: thumb),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        scheme.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scheme.spec,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: List<Widget>.generate(3, (int i) {
                          final bool filled = i < scheme.difficulty;
                          return Container(
                            width: 14,
                            height: 4,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: filled
                                  ? AppColors.signal
                                  : AppColors.textPrimary
                                      .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    const Text(
                      'BEST',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      best > 0 ? best.toString() : '-',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.signal,
                        fontFeatures: tabular,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
