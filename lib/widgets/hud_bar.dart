import 'package:flutter/material.dart';

import '../theme.dart';

/// Top strip of the game screen: back, scheme label, energy segments and the
/// remaining switch counter.
class HudBar extends StatelessWidget {
  const HudBar({
    super.key,
    required this.schemeLabel,
    required this.energy,
    required this.maxEnergy,
    required this.switchesLeft,
    required this.onBack,
  });

  final String schemeLabel;
  final int energy;
  final int maxEnergy;
  final int switchesLeft;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.hudBar,
        border: Border(
          bottom: BorderSide(color: Color(0x472F7EFF), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back,
                size: 24, color: AppColors.textSecondary),
            tooltip: 'Menu',
          ),
          Expanded(
            child: Text(
              schemeLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const Text(
                'ENERGY',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List<Widget>.generate(maxEnergy, (int i) {
                  final bool lit = i < energy;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.only(left: 3),
                    width: 10,
                    height: 14,
                    decoration: BoxDecoration(
                      color: lit
                          ? AppColors.info
                          : AppColors.textPrimary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              const Text(
                'SWITCHES',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                switchesLeft.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.signal,
                  fontFeatures: tabular,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
