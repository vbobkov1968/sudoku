import 'package:flutter/material.dart';
import '../core/models/game_state.dart';
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

  @override
  void initState() {
    super.initState();
    _gameState = widget.gameState;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku'),
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SudokuGrid(
            gameState: _gameState,
            onCellTap: _onCellTap,
          ),
        ),
      ),
    );
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