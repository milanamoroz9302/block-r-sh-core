import 'dart:async';

import 'package:flutter/material.dart';

import '../game/game_config.dart';
import '../game/schemes.dart';
import '../game/shaft_engine.dart';
import '../theme.dart';
import '../widgets/buttons.dart';
import '../widgets/hud_bar.dart';
import '../widgets/overlay_card.dart';
import '../widgets/shaft_view.dart';

/// The puzzle itself. Named `GameScreen` on purpose — the capture agent names
/// screenshots after the screen class.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.scheme,
    required this.showTutorial,
    required this.onExit,
    required this.onGameOver,
  });

  final Scheme scheme;

  /// Shown once, on the first run of a session.
  final bool showTutorial;
  final VoidCallback onExit;
  final void Function(GameResult result) onGameOver;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ShaftEngine _engine;

  Timer? _autoStartTimer;
  Timer? _tickTimer;
  Timer? _resultTimer;
  Timer? _hitTimer;
  Timer? _tutorialTimer;

  bool _rising = false;
  bool _tutorial = false;
  bool _paused = false;

  /// Reserved height for the floating control bar (64 bar + 24 inset + gap).
  static const double _bottomInset = 104;

  @override
  void initState() {
    super.initState();
    _engine = ShaftEngine(widget.scheme);
    _tutorial = widget.showTutorial;

    if (_tutorial) {
      // Auto-hide so the board — not the card — is what gets captured.
      _tutorialTimer = Timer(
        const Duration(milliseconds: GameConfig.tutorialAutoHideMs),
        () {
          if (mounted) setState(() => _tutorial = false);
        },
      );
    }

    // Armed exactly once. Never re-armed by a tap: a tap starts the lift
    // immediately instead, so the board is on screen for the whole window
    // between mount and auto-start.
    _autoStartTimer = Timer(
      const Duration(milliseconds: GameConfig.autoStartMs),
      _beginLift,
    );
  }

  @override
  void dispose() {
    _autoStartTimer?.cancel();
    _tickTimer?.cancel();
    _resultTimer?.cancel();
    _hitTimer?.cancel();
    _tutorialTimer?.cancel();
    super.dispose();
  }

  void _beginLift() {
    if (_rising || _engine.finished || !mounted) return;
    _autoStartTimer?.cancel();
    _rising = true;
    _tickTimer = Timer.periodic(
      const Duration(milliseconds: GameConfig.tickMs),
      (Timer _) => _onTick(),
    );
    setState(() {});
  }

  void _onTick() {
    if (!mounted || _paused) return;
    setState(_engine.tick);

    if (_engine.phase == ShaftPhase.hit) {
      _hitTimer?.cancel();
      _hitTimer = Timer(
        const Duration(milliseconds: GameConfig.hitFlashMs),
        () {
          if (mounted && _engine.phase == ShaftPhase.hit) {
            setState(() => _engine.phase = ShaftPhase.rising);
          }
        },
      );
    }

    if (_engine.finished) {
      _tickTimer?.cancel();
      _resultTimer = Timer(
        const Duration(milliseconds: GameConfig.resultHoldMs),
        () {
          if (mounted) widget.onGameOver(_engine.toResult());
        },
      );
    }
  }

  void _handleFlipRow(int row) {
    if (_paused || _engine.finished) return;
    if (_tutorial) setState(() => _tutorial = false);
    final bool flipped = _engine.flip(row);
    if (flipped) setState(() {});
    _beginLift();
  }

  void _handleFlipButton() {
    if (_paused || _engine.finished) return;
    final int row = _engine.nearestFlipRow();
    if (row >= 0) {
      _handleFlipRow(row);
    } else {
      _beginLift();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ShaftEngine e = _engine;

    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            HudBar(
              schemeLabel: widget.scheme.label,
              energy: e.energy,
              maxEnergy: e.maxEnergy,
              switchesLeft: e.switchesLeft,
              onBack: widget.onExit,
            ),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ShaftView(
                        rows: e.rows,
                        platformCols: widget.scheme.platformCols,
                        polarities: e.polarities,
                        hazardCols: widget.scheme.hazardCols,
                        coreRow: e.coreRow,
                        coreCol: e.coreCol,
                        phase: e.phase,
                        hitRow: e.hitRow,
                        bottomInset: _bottomInset,
                        canFlipRow: e.canFlip,
                        onFlipRow: _handleFlipRow,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 24,
                    child: _buildControlBar(),
                  ),
                  if (_tutorial)
                    Positioned.fill(child: _buildTutorial()),
                  if (_paused)
                    Positioned.fill(child: _buildPause()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.32),
          width: 1.5,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.bgDeep.withValues(alpha: 0.7),
            blurRadius: 24,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => setState(() => _paused = true),
            icon: const Icon(Icons.pause,
                size: 24, color: AppColors.textSecondary),
            tooltip: 'Pause',
          ),
          const SizedBox(width: 4),
          Expanded(
            child: PrimaryCta(
              label: 'FLIP',
              icon: Icons.swap_vert,
              height: 52,
              onTap: _handleFlipButton,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildTutorial() {
    return OverlayCard(
      title: 'HOW IT WORKS',
      onDismiss: () => setState(() => _tutorial = false),
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
          onTap: () => setState(() => _tutorial = false),
        ),
      ],
    );
  }

  Widget _buildPause() {
    return OverlayCard(
      title: 'PAUSED',
      onDismiss: () => setState(() => _paused = false),
      children: <Widget>[
        SecondaryButton(
          label: 'RESUME',
          icon: Icons.play_arrow,
          accent: AppColors.info,
          onTap: () => setState(() => _paused = false),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          label: 'MENU',
          icon: Icons.home_outlined,
          accent: AppColors.textSecondary,
          onTap: widget.onExit,
        ),
      ],
    );
  }
}
