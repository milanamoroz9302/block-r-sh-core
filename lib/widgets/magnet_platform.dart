import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/shaft_engine.dart';
import '../theme.dart';

/// A single magnetic platform. Blue pushes, violet pulls.
/// The tap target is padded out to at least 48x48 regardless of cell size.
class MagnetPlatform extends StatelessWidget {
  const MagnetPlatform({
    super.key,
    required this.polarity,
    required this.width,
    required this.height,
    required this.active,
    required this.onTap,
  });

  final Polarity polarity;
  final double width;
  final double height;

  /// Platforms below the core are dimmed and inert.
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool push = polarity == Polarity.push;
    final Color accent = push ? AppColors.primary : AppColors.secondary;
    final String sprite =
        push ? AppAssets.spritePlatformPush : AppAssets.spritePlatformPull;

    final Widget bar = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: active ? 0.5 : 0.14),
            blurRadius: 16,
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Image.asset(
          sprite,
          key: ValueKey<Polarity>(polarity),
          width: width,
          height: height,
          fit: BoxFit.contain,
          color: active ? null : AppColors.bgBase.withValues(alpha: 0.55),
          colorBlendMode: active ? null : BlendMode.srcATop,
          errorBuilder: (BuildContext c, Object e, StackTrace? s) =>
              DecoratedBox(
            decoration: BoxDecoration(
              color: accent.withValues(alpha: active ? 0.9 : 0.35),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: active ? onTap : null,
      child: Center(child: bar),
    );
  }
}
