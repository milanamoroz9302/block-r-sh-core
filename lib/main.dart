import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import 'game/game_config.dart';
import 'game/schemes.dart';
import 'game/shaft_engine.dart';
import 'screens/game_screen.dart';
import 'screens/gameover_screen.dart';
import 'screens/loader_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/schemes_screen.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  // Flutter only publishes the accessibility tree while a client holds a
  // handle on it. Without one every `uiautomator dump` returns empty nodes
  // and times out, so the UI walker cannot tell two screens apart.
  // The handle is deliberately never released: semantics must stay up for
  // the whole process lifetime.
  SemanticsBinding.instance.ensureSemantics();
  // Hide the system bars. The ticking status-bar clock changes pixels between
  // two shots of the same screen, which makes a tap that hit nothing look
  // like successful navigation.
  unawaited(
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
  );
  runApp(const BlockRushCoreApp());
}

/// Screens of the app. `gameover` is mandatory — it is what makes a finished
/// round visible as its own frame.
enum Screen { loader, menu, schemes, game, gameover }

class BlockRushCoreApp extends StatelessWidget {
  const BlockRushCoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Block Rush Core',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  Screen _screen = Screen.loader;
  int _schemeIndex = 0;
  int _runKey = 0;
  bool _tutorialSeen = false;

  final List<int> _bestPerScheme =
      List<int>.filled(kSchemes.length, 0, growable: false);

  GameResult? _lastResult;
  Timer? _loaderTimer;

  int get _best =>
      _bestPerScheme.fold<int>(0, (int a, int b) => a > b ? a : b);

  @override
  void initState() {
    super.initState();
    _loaderTimer = Timer(
      const Duration(milliseconds: GameConfig.loaderDurationMs),
      () {
        if (mounted) setState(() => _screen = Screen.menu);
      },
    );
  }

  @override
  void dispose() {
    _loaderTimer?.cancel();
    super.dispose();
  }

  void _startRun() {
    setState(() {
      _runKey++;
      _screen = Screen.game;
    });
  }

  void _handleGameOver(GameResult result) {
    if (result.score > _bestPerScheme[result.schemeIndex]) {
      _bestPerScheme[result.schemeIndex] = result.score;
    }
    setState(() {
      _lastResult = result;
      _tutorialSeen = true;
      _screen = Screen.gameover;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_screen) {
      case Screen.loader:
        return const LoaderScreen();

      case Screen.menu:
        return MenuScreen(
          scheme: kSchemes[_schemeIndex],
          best: _best,
          onPlay: _startRun,
          onSchemes: () => setState(() => _screen = Screen.schemes),
        );

      case Screen.schemes:
        return SchemesScreen(
          selectedIndex: _schemeIndex,
          bestPerScheme: _bestPerScheme,
          onSelect: (int index) {
            _schemeIndex = index;
            _startRun();
          },
          onBack: () => setState(() => _screen = Screen.menu),
        );

      case Screen.game:
        return GameScreen(
          key: ValueKey<String>('run-$_schemeIndex-$_runKey'),
          scheme: kSchemes[_schemeIndex],
          showTutorial: !_tutorialSeen,
          onExit: () => setState(() => _screen = Screen.menu),
          onGameOver: _handleGameOver,
        );

      case Screen.gameover:
        final GameResult result = _lastResult ??
            GameResult(
              won: false,
              score: 0,
              switchesLeft: 0,
              energy: 0,
              schemeIndex: _schemeIndex,
            );
        return GameOverScreen(
          result: result,
          onPlayAgain: _startRun,
          onSchemes: () => setState(() => _screen = Screen.schemes),
          onMenu: () => setState(() => _screen = Screen.menu),
        );
    }
  }
}
