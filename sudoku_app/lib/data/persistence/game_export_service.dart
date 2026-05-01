import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

import '../../core/models/board.dart';
import '../../core/models/cell.dart';
import '../../core/models/difficulty.dart';
import '../../core/models/game_state.dart';
import '../../core/models/milestone.dart';
import 'game_persistence.dart' show SavedGame;

class GameExportService {
  static const _version = 1;

  // ---------------------------------------------------------------------------
  // Encode / decode

  static Uint8List encode(
    GameState state,
    Difficulty difficulty,
    List<Milestone> milestones,
  ) {
    final map = {
      'version': _version,
      'exportedAt': DateTime.now().toIso8601String(),
      'difficulty': difficulty.name,
      'initial': _boardToFlat(state.initialBoard),
      'solution': _boardToFlat(state.solutionBoard),
      'current': _boardToFlat(state.currentBoard),
      'notes': _notesToFlat(state.currentBoard),
      'noteMode': state.noteMode,
      'undoStack': _encodeBoards(state.undoStack),
      'redoStack': _encodeBoards(state.redoStack),
      'milestones': [
        for (final m in milestones) {
          'createdAt': m.createdAt.toIso8601String(),
          'current': _boardToFlat(m.board),
          'notes': _notesToFlat(m.board),
          'noteMode': m.noteMode,
        },
      ],
    };
    return Uint8List.fromList(GZipCodec().encode(utf8.encode(jsonEncode(map))));
  }

  static SavedGame? decode(Uint8List bytes) {
    try {
      final map = jsonDecode(utf8.decode(GZipCodec().decode(bytes)))
          as Map<String, dynamic>;

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

      final milestones = <Milestone>[];
      if (map['milestones'] case final List raw) {
        for (final entry in raw) {
          final e = entry as Map<String, dynamic>;
          milestones.add(Milestone(
            createdAt: DateTime.parse(e['createdAt'] as String),
            board: _boardFromEntry(e, initialInts),
            noteMode: e['noteMode'] as bool,
          ));
        }
      }

      final state = GameState(
        initialBoard: Board.fromInts(initialInts),
        solutionBoard: Board.fromInts(solutionInts),
        currentBoard: Board(currentGrid),
        noteMode: noteMode,
        undoStack: _decodeBoards(map['undoStack'], initialInts),
        redoStack: _decodeBoards(map['redoStack'], initialInts),
      );

      return (state: state, difficulty: difficulty, milestones: milestones);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // File I/O

  /// macOS: shows NSSavePanel, writes file.
  /// Android: writes to temp dir and opens share sheet (messengers, email, Files…).
  static Future<bool> exportToFile(
    GameState state,
    Difficulty difficulty,
    List<Milestone> milestones,
  ) async {
    final bytes = encode(state, difficulty, milestones);

    if (Platform.isAndroid) {
      const channel = MethodChannel('com.sudoku/menu');
      await channel.invokeMethod<void>('shareGameFile', bytes);
      return true;
    }

    final path = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Game',
      fileName: 'sudoku_game.sudoku',
      type: FileType.custom,
      allowedExtensions: ['sudoku'],
    );
    if (path == null) return false;
    await File(path).writeAsBytes(bytes);
    return true;
  }

  /// Shows open dialog (both platforms), returns parsed game or null on error.
  static Future<SavedGame?> importFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Open Game',
      type: FileType.custom,
      allowedExtensions: ['sudoku'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final bytes = result.files.first.bytes;
    if (bytes == null) return null;
    return decode(bytes);
  }

  // ---------------------------------------------------------------------------
  // Helpers (mirrors GamePersistence internals)

  static List<Map<String, dynamic>> _encodeBoards(List<Board> boards) => [
    for (final b in boards) {'current': _boardToFlat(b), 'notes': _notesToFlat(b)},
  ];

  static List<Board> _decodeBoards(dynamic raw, List<List<int>> initialInts) {
    if (raw is! List) return [];
    return [for (final e in raw) _boardFromEntry(e as Map<String, dynamic>, initialInts)];
  }

  static Board _boardFromEntry(Map<String, dynamic> e, List<List<int>> initialInts) {
    final ints = _flatToInts(e['current'] as List);
    final masks = (e['notes'] as List).cast<int>();
    return Board(List.generate(
      9,
      (row) => List.generate(9, (col) {
        final val = ints[row][col];
        final mask = masks[row * 9 + col];
        return Cell(
          row: row,
          col: col,
          value: val == 0 ? null : val,
          isGiven: initialInts[row][col] != 0,
          notes: {for (var b = 0; b < 9; b++) if (mask & (1 << b) != 0) b + 1},
        );
      }),
    ));
  }

  static List<int> _boardToFlat(Board board) =>
      [for (var i = 0; i < 81; i++) board.getValue(i ~/ 9, i % 9) ?? 0];

  static List<int> _notesToFlat(Board board) => [
    for (var i = 0; i < 81; i++)
      board.getCell(i ~/ 9, i % 9).notes.fold(0, (m, d) => m | (1 << (d - 1))),
  ];

  static List<List<int>> _flatToInts(List<dynamic> flat) =>
      List.generate(9, (r) => List.generate(9, (c) => flat[r * 9 + c] as int));
}
