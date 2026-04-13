import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/models/game_state.dart';
import 'widgets/number_pad.dart';
import 'widgets/sudoku_grid.dart';

/// The main game screen that displays the Sudoku grid.
class GameScreen extends StatefulWidget {
  final GameState gameState;

  const GameScreen({
    super.key,
    required this.gameState,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _gameState = widget.gameState;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
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
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(_gameState.noteMode ? Icons.edit : Icons.edit_off),
              onPressed: _toggleNoteMode,
              tooltip: _gameState.noteMode ? 'Exit Note Mode' : 'Enter Note Mode',
            ),
            if (_gameState.canUndo)
              IconButton(
                icon: const Icon(Icons.undo),
                onPressed: _undo,
                tooltip: 'Undo',
              ),
            if (_gameState.canRedo)
              IconButton(
                icon: const Icon(Icons.redo),
                onPressed: _redo,
                tooltip: 'Redo',
              ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 600;

            if (isDesktop) {
              return _buildDesktopLayout();
            } else {
              return _buildMobileLayout();
            }
          },
        ),
      ),
    );
  }

  /// Desktop layout: grid on the left, numpad on the right
  Widget _buildDesktopLayout() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Sudoku grid - flexible size
          Flexible(
            flex: 5,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: SudokuGrid(
                gameState: _gameState,
                onCellTap: _onCellTap,
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Right panel with numpad - FIXED size, not flexible
          Center(
            child: NumberPad(
              onDigitPressed: _onDigitPressed,
              onClearPressed: _onClearPressed,
              compact: true,
            ),
          ),
        ],
      ),
    );
  }

  /// Mobile layout: grid on top, numpad below
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sudoku grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final gridSize = constraints.maxWidth.clamp(250.0, 400.0);
                  return SizedBox(
                    width: gridSize,
                    height: gridSize,
                    child: SudokuGrid(
                      gameState: _gameState,
                      onCellTap: _onCellTap,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Mode indicator
              Text(
                _gameState.noteMode ? 'Note mode enabled' : 'Number mode enabled',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              // Number pad
              SizedBox(
                width: 280,
                child: NumberPad(
                  onDigitPressed: _onDigitPressed,
                  onClearPressed: _onClearPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.backspace || key == LogicalKeyboardKey.delete) {
      _onClearPressed();
      return;
    }

    final digit = _logicalKeyToDigit(key);
    if (digit != null) {
      _onDigitPressed(digit);
    }
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

  void _onDigitPressed(int digit) {
    setState(() {
      _gameState.applyInput(digit);
    });
  }

  void _onClearPressed() {
    setState(() {
      _gameState.clearSelected();
    });
  }

  void _onCellTap(int row, int col) {
    setState(() {
      _gameState.selectCell(row, col);
    });
  }

  void _toggleNoteMode() {
    setState(() {
      _gameState.toggleNoteMode();
    });
  }

  void _undo() {
    setState(() {
      _gameState.undo();
    });
  }

  void _redo() {
    setState(() {
      _gameState.redo();
    });
  }
}