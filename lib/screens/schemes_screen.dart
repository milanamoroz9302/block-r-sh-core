import 'package:flutter/material.dart';

import '../assets.dart';
import '../game/schemes.dart';
import '../theme.dart';
import '../widgets/app_shell.dart';
import '../widgets/scheme_card.dart';

/// Optional scheme picker. It is never on the critical path — the menu CTA
/// jumps straight into the shaft with the currently selected scheme.
class SchemesScreen extends StatelessWidget {
  const SchemesScreen({
    super.key,
    required this.selectedIndex,
    required this.bestPerScheme,
    required this.onSelect,
    required this.onBack,
  });

  final int selectedIndex;
  final List<int> bestPerScheme;
  final void Function(int index) onSelect;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      background: const AssetImage(AppAssets.bgGame),
      overlay: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          AppColors.bgDeep.withValues(alpha: 0.9),
          AppColors.bgBase.withValues(alpha: 0.94),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back,
                      size: 24, color: AppColors.textSecondary),
                  tooltip: 'Back',
                ),
                const SizedBox(width: 4),
                // Scales down instead of overflowing the row on narrow
                // handsets — the wide letter spacing makes this title long.
                const Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'SELECT SCHEME',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3.0,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  const double gap = 10;
                  final int count = kSchemes.length;
                  final double raw =
                      (constraints.maxHeight - gap * (count - 1)) / count;
                  final double cardH = raw.clamp(58.0, 86.0);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      for (int i = 0; i < count; i++) ...<Widget>[
                        if (i > 0) const SizedBox(height: gap),
                        SchemeCard(
                          scheme: kSchemes[i],
                          best: bestPerScheme[i],
                          selected: i == selectedIndex,
                          height: cardH,
                          onTap: () => onSelect(i),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
