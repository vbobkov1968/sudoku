import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku_app/core/generator/puzzle_generator.dart';
import 'package:sudoku_app/core/models/difficulty.dart';
import 'package:sudoku_app/core/models/game_state.dart';
import 'package:sudoku_app/data/persistence/game_persistence.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('GamePersistence', () {
    late GameState gameState;

    setUp(() {
      final puzzle = PuzzleGenerator(seed: 42).generate(Difficulty.medium);
      gameState = GameState(
        initialBoard: puzzle.puzzle,
        solutionBoard: puzzle.solution,
      );
    });

    test('load returns null when nothing saved', () async {
      final result = await GamePersistence.load();
      expect(result, isNull);
    });

    test('save and load roundtrip preserves difficulty', () async {
      await GamePersistence.save(gameState, Difficulty.hard);
      final loaded = await GamePersistence.load();

      expect(loaded, isNotNull);
      expect(loaded!.difficulty, Difficulty.hard);
    });

    test('save and load roundtrip preserves initial board', () async {
      await GamePersistence.save(gameState, Difficulty.easy);
      final loaded = await GamePersistence.load();

      expect(
        loaded!.state.initialBoard.toInts(),
        gameState.initialBoard.toInts(),
      );
    });

    test('save and load roundtrip preserves solution board', () async {
      await GamePersistence.save(gameState, Difficulty.easy);
      final loaded = await GamePersistence.load();

      expect(
        loaded!.state.solutionBoard.toInts(),
        gameState.solutionBoard.toInts(),
      );
    });

    test('save and load roundtrip preserves current board with user moves', () async {
      final emptyInts = gameState.currentBoard.toInts();
      int? targetRow, targetCol;
      for (var r = 0; r < 9; r++) {
        for (var c = 0; c < 9; c++) {
          if (emptyInts[r][c] == 0) {
            targetRow = r;
            targetCol = c;
            break;
          }
        }
        if (targetRow != null) break;
      }
      gameState.setValue(targetRow!, targetCol!, 3);

      await GamePersistence.save(gameState, Difficulty.easy);
      final loaded = await GamePersistence.load();

      expect(
        loaded!.state.currentBoard.toInts(),
        gameState.currentBoard.toInts(),
      );
    });

    test('save and load roundtrip preserves notes', () async {
      final emptyInts = gameState.currentBoard.toInts();
      int? targetRow, targetCol;
      for (var r = 0; r < 9; r++) {
        for (var c = 0; c < 9; c++) {
          if (emptyInts[r][c] == 0) {
            targetRow = r;
            targetCol = c;
            break;
          }
        }
        if (targetRow != null) break;
      }
      gameState.toggleNote(targetRow!, targetCol!, 4);
      gameState.toggleNote(targetRow, targetCol, 7);

      await GamePersistence.save(gameState, Difficulty.easy);
      final loaded = await GamePersistence.load();

      final cell = loaded!.state.currentBoard.getCell(targetRow, targetCol);
      expect(cell.notes, containsAll([4, 7]));
    });

    test('save and load roundtrip preserves noteMode', () async {
      gameState.toggleNoteMode();
      expect(gameState.noteMode, isTrue);

      await GamePersistence.save(gameState, Difficulty.easy);
      final loaded = await GamePersistence.load();

      expect(loaded!.state.noteMode, isTrue);
    });

    test('clear removes saved game', () async {
      await GamePersistence.save(gameState, Difficulty.easy);
      await GamePersistence.clear();
      final loaded = await GamePersistence.load();

      expect(loaded, isNull);
    });

    test('given cells are restored as given', () async {
      await GamePersistence.save(gameState, Difficulty.easy);
      final loaded = await GamePersistence.load();

      final originalGivens = gameState.initialBoard.allCells
          .where((c) => c.isGiven)
          .map((c) => (c.row, c.col))
          .toSet();

      for (final cell in loaded!.state.currentBoard.allCells) {
        if (originalGivens.contains((cell.row, cell.col))) {
          expect(cell.isGiven, isTrue,
              reason: 'Cell (${cell.row},${cell.col}) should be given');
        }
      }
    });
  });
}
