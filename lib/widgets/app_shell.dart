import 'package:flutter/material.dart';

import '../theme.dart';

/// Scaffold + full-bleed background image + readability overlay.
/// Every screen goes through this so nothing ever renders on a flat colour.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.background,
    required this.overlay,
    required this.child,
    this.safeArea = true,
  });

  /// Background artwork provider (an [AssetImage] from `AppAssets`).
  final ImageProvider background;

  /// Tint painted on top of the artwork so UI stays readable.
  final Gradient overlay;

  final Widget child;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final Widget body = Stack(
      fit: StackFit.expand,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.bgBase,
            image: DecorationImage(image: background, fit: BoxFit.cover),
          ),
        ),
        DecoratedBox(decoration: BoxDecoration(gradient: overlay)),
        if (safeArea) SafeArea(child: child) else child,
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: body,
    );
  }
}
