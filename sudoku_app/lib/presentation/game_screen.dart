import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/models/game_state.dart';
import '../core/generator/puzzle_generator.dart';
import '../core/models/difficulty.dart';
import '../data/persistence/game_persistence.dart';
import 'app_settings_scope.dart';
import 'difficulty_picker_dialog.dart';
import 'settings_screen.dart';
import 'widgets/number_pad.dart';
import 'widgets/sudoku_grid.dart';
import 'widgets/victory_overlay.dart';

/// The main game screen that displays the Sudoku grid.
class GameScreen extends StatefulWidget {
  final GameState gameState;
  final Difficulty difficulty;

  const GameScreen({
    super.key,
    required this.gameState,
    required this.difficulty,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const _menuChannel = MethodChannel('com.sudoku/menu');

  late GameState _gameState;
  late Difficulty _difficulty;
  bool _showVictory = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _gameState = widget.gameState;
    _difficulty = widget.difficulty;
    if (Platform.isMacOS) {
      _menuChannel.setMethodCallHandler(_handleMenuCall);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  Future<void> _handleMenuCall(MethodCall call) async {
    if (!mounted) return;
    if (call.method == 'openSettings') SettingsDialog.show(context);
  }

  @override
  void dispose() {
    if (Platform.isMacOS) _menuChannel.setMethodCallHandler(null);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        body: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                // Switch to mobile layout when window is too narrow OR when grid would be too small
                final isDesktop = !Platform.isAndroid;
                return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
              },
            ),
            if (_showVictory)
              VictoryOverlay(
                onNewGame: _newGame,
                onContinue: _dismissVictory,
              ),
          ],
        ),
      ),
    );
  }

  /// Desktop layout: grid centred, toolbar + numpad pinned to bottom centre.
  Widget _buildDesktopLayout() {
    final topPadding = Platform.isMacOS ? 52.0 : 24.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: topPadding),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: SudokuGrid(gameState: _gameState, onCellTap: _onCellTap),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildToolbar(context),
        const SizedBox(height: 12),
        SizedBox(width: 280, child: _buildNumpadCard()),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Mobile layout: grid on top, controls + numpad below
  Widget _buildMobileLayout() {
    final topPadding = Platform.isMacOS ? 52.0 : 16.0;
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, topPadding, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final gridSize = constraints.maxWidth.clamp(250.0, 400.0);
                  return SizedBox(
                    width: gridSize,
                    height: gridSize,
                    child: SudokuGrid(gameState: _gameState, onCellTap: _onCellTap),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildToolbar(context),
              const SizedBox(height: 16),
              SizedBox(
                width: 280,
                child: _buildNumpadCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _cardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xCC1C1C1E) : Colors.grey.shade50;
  }

  Widget _buildToolbar(BuildContext context) {
    return SizedBox(
      width: 280,
      child: Card(
        color: _cardColor(context),
        elevation: 1,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Theme(
          data: Theme.of(context).copyWith(
            iconTheme: IconThemeData(
              color: Theme.of(context).colorScheme.onSurface,
              size: 22,
            ),
            disabledColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    _gameState.noteMode ? Icons.edit_note_outlined : Icons.edit_off_outlined,
                    color: _gameState.noteMode ? Theme.of(context).colorScheme.primary : null,
                  ),
                  onPressed: _toggleNoteMode,
                  tooltip: _gameState.noteMode ? 'Exit Note Mode (N)' : 'Enter Note Mode (N)',
                  style: _gameState.noteMode
                      ? IconButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        )
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.undo_outlined),
                  onPressed: _gameState.canUndo ? _undo : null,
                  tooltip: 'Undo',
                ),
                IconButton(
                  icon: const Icon(Icons.redo_outlined),
                  onPressed: _gameState.canRedo ? _redo : null,
                  tooltip: 'Redo',
                ),
                IconButton(
                  icon: const Icon(Icons.backspace_outlined),
                  onPressed: _onClearPressed,
                  tooltip: 'Clear cell',
                ),
                IconButton(
                  icon: const Icon(Icons.replay_outlined),
                  onPressed: _resetPuzzle,
                  tooltip: 'Reset puzzle',
                ),
                IconButton(
                  icon: const Icon(Icons.casino_outlined),
                  onPressed: _newGame,
                  tooltip: 'New game',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumpadCard() {
    return Card(
      color: _cardColor(context),
      elevation: 1,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: NumberPad(onDigitPressed: _onDigitPressed),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.keyN) {
      _toggleNoteMode();
      return;
    }
    if (key == LogicalKeyboardKey.backspace || key == LogicalKeyboardKey.delete) {
      _onClearPressed();
      return;
    }
    final digit = _logicalKeyToDigit(key);
    if (digit != null) _onDigitPressed(digit);
  }

  int? _logicalKeyToDigit(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.digit1 || key == LogicalKeyboardKey.numpad1) return 1;
    if (key == LogicalKeyboardKey.digit2 || key == LogicalKeyboardKey.numpad2) return 2;
    if (key == LogicalKeyboardKey.digit3 || key == LogicalKeyboardKey.numpad3) return 3;
    if (key == LogicalKeyboardKey.digit4 || key == LogicalKeyboardKey.numpad4) return 4;
    if (key == LogicalKeyboardKey.digit5 || key == LogicalKeyboardKey.numpad5) return 5;
    if (key == LogicalKeyboardKey.digit6 || key == LogicalKeyboardKey.numpad6) return 6;
    if (key == LogicalKeyboardKey.digit7 || key == LogicalKeyboardKey.numpad7) return 7;
    if (key == LogicalKeyboardKey.digit8 || key == LogicalKeyboardKey.numpad8) return 8;
    if (key == LogicalKeyboardKey.digit9 || key == LogicalKeyboardKey.numpad9) return 9;
    return null;
  }

  void _autosave() => GamePersistence.save(_gameState, _difficulty);

  void _onDigitPressed(int digit) {
    setState(() {
      _gameState.applyInput(digit);
      if (_gameState.isWin) _showVictory = true;
    });
    _autosave();
  }

  void _dismissVictory() {
    setState(() => _showVictory = false);
  }

  void _onClearPressed() {
    setState(() => _gameState.clearSelected());
    _autosave();
  }

  void _onCellTap(int row, int col) {
    setState(() => _gameState.selectCell(row, col));
  }

  void _toggleNoteMode() {
    setState(() => _gameState.toggleNoteMode());
    _autosave();
  }

  void _undo() {
    setState(() => _gameState.undo());
    _autosave();
  }

  void _redo() {
    setState(() => _gameState.redo());
    _autosave();
  }

  void _resetPuzzle() {
    setState(() {
      _gameState = GameState(
        initialBoard: _gameState.initialBoard,
        solutionBoard: _gameState.solutionBoard,
      );
      _showVictory = false;
      _focusNode.requestFocus();
    });
    _autosave();
  }

  Future<void> _newGame() async {
    final notifier = AppSettingsScope.read(context);
    final chosen = await DifficultyPickerDialog.show(context, notifier.value.difficulty);
    if (chosen == null || !mounted) return;
    notifier.update(notifier.value.withDifficulty(chosen));
    setState(() {
      _difficulty = chosen;
      final puzzle = PuzzleGenerator(seed: DateTime.now().millisecondsSinceEpoch)
          .generate(_difficulty);
      _gameState = GameState(initialBoard: puzzle.puzzle, solutionBoard: puzzle.solution);
      _showVictory = false;
      _focusNode.requestFocus();
    });
    _autosave();
  }
}
