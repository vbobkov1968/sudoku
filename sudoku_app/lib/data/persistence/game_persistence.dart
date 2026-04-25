import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/board.dart';
import '../../core/models/cell.dart';
import '../../core/models/difficulty.dart';
import '../../core/models/game_state.dart';

typedef SavedGame = ({GameState state, Difficulty difficulty});

/// Persists and restores a single active game session using shared_preferences.
///
/// Serialization format (JSON):
///   difficulty : string (Difficulty.name)
///   initial    : [81 ints] flat row-major, 0=empty
///   solution   : [81 ints] flat row-major
///   current    : [81 ints] flat row-major, 0=empty
///   notes      : [81 ints] bitmask per cell (bit b → digit b+1 present)
///   noteMode   : bool
///
/// Undo/redo history is intentionally not persisted.
class GamePersistence {
  static const _key = 'saved_game';

  static Future<void> save(GameState state, Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_encode(state, difficulty)));
  }

  static Future<SavedGame?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return null;
      return _decode(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // ---------------------------------------------------------------------------

  static Map<String, dynamic> _encode(GameState state, Difficulty difficulty) => {
    'difficulty': difficulty.name,
    'initial': _boardToFlat(state.initialBoard),
    'solution': _boardToFlat(state.solutionBoard),
    'current': _boardToFlat(state.currentBoard),
    'notes': _notesToFlat(state.currentBoard),
    'noteMode': state.noteMode,
  };

  static SavedGame _decode(Map<String, dynamic> map) {
    final difficulty = Difficulty.values.firstWhere(
      (d) => d.name == map['difficulty'],
      orElse: () => Difficulty.easy,
    );

    final initialInts = _flatToInts(map['initial'] as List);
    final solutionInts = _flatToInts(map['solution'] as List);
    final currentInts = _flatToInts(map['current'] as List);
    final notesMasks = (map['notes'] as List).cast<int>();
    final noteMode = map['noteMode'] as bool;

    final currentGrid = List.generate(
      9,
      (row) => List.generate(9, (col) {
        final val = currentInts[row][col];
        final mask = notesMasks[row * 9 + col];
        return Cell(
          row: row,
          col: col,
          value: val == 0 ? null : val,
          isGiven: initialInts[row][col] != 0,
          notes: {for (var b = 0; b < 9; b++) if (mask & (1 << b) != 0) b + 1},
        );
      }),
    );

    final state = GameState(
      initialBoard: Board.fromInts(initialInts),
      solutionBoard: Board.fromInts(solutionInts),
      currentBoard: Board(currentGrid),
      noteMode: noteMode,
    );

    return (state: state, difficulty: difficulty);
  }

  static List<int> _boardToFlat(Board board) => [
    for (var i = 0; i < 81; i++) board.getValue(i ~/ 9, i % 9) ?? 0,
  ];

  static List<int> _notesToFlat(Board board) => [
    for (var i = 0; i < 81; i++)
      board.getCell(i ~/ 9, i % 9).notes.fold(0, (m, d) => m | (1 << (d - 1))),
  ];

  static List<List<int>> _flatToInts(List<dynamic> flat) =>
    List.generate(9, (r) => List.generate(9, (c) => flat[r * 9 + c] as int));
}
