/// Tunable timings for the shaft puzzle. Every value here is deliberate —
/// see the design document before changing one.
class GameConfig {
  const GameConfig._();

  /// Branded splash duration. Must stay exactly 8000ms.
  static const int loaderDurationMs = 8000;

  /// One-shot loader entrance animation (kept short so the window goes idle).
  static const int loaderAnimMs = 1200;

  /// Shaft columns. Rows vary per scheme.
  static const int cols = 5;

  /// One lift step of the core.
  static const int tickMs = 900;

  /// Core move interpolation between two rows.
  static const int coreMoveMs = 260;

  /// The rise starts by itself after this delay if the player never taps.
  /// Armed once in initState, never re-armed.
  static const int autoStartMs = 26000;

  /// Hold between the final tick and the result screen.
  static const int resultHoldMs = 4600;

  /// Hazard flash duration.
  static const int hitFlashMs = 320;

  /// Tutorial card auto-dismiss so the board is visible when capture happens.
  static const int tutorialAutoHideMs = 3500;

  /// Button press feedback.
  static const int pressMs = 110;
}
