import 'package:flutter/material.dart';

import '../theme.dart';

/// One statistics pill — accent dot, large tabular value, small caption.
/// Deliberately free of raster art so a row of pills always lines up.
/// The very same widget is used on the menu and on the game-over screen.
class StatCardPill extends StatelessWidget {
  const StatCardPill({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: valueColor.withValues(alpha: 0.33),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: valueColor,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: valueColor.withValues(alpha: 0.6),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: valueColor,
              fontFeatures: tabular,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Staggered fade + rise used for pill rows and headings. One shot — it
/// settles and never repeats, so the window can go idle.
class StaggerFade extends StatefulWidget {
  const StaggerFade({
    super.key,
    required this.delayMs,
    required this.child,
  });

  final int delayMs;
  final Widget child;

  @override
  State<StaggerFade> createState() => _StaggerFadeState();
}

class _StaggerFadeState extends State<StaggerFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _controller, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.14),
          end: Offset.zero,
        ).animate(_fade),
        child: widget.child,
      ),
    );
  }
}
