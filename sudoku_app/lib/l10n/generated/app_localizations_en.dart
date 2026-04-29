// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sudoku';

  @override
  String get newGame => 'New Game';

  @override
  String get continueGame => 'Continue';

  @override
  String get settings => 'Settings';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultyExpert => 'Expert';

  @override
  String get notes => 'Notes';

  @override
  String get enterNoteMode => 'Enter Note Mode (N)';

  @override
  String get exitNoteMode => 'Exit Note Mode (N)';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get clearCell => 'Clear cell';

  @override
  String get resetPuzzle => 'Reset puzzle';

  @override
  String get check => 'Check';

  @override
  String get hint => 'Hint';

  @override
  String get erase => 'Erase';

  @override
  String get clearAll => 'Clear All';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get puzzleComplete => 'Puzzle Complete!';

  @override
  String get playAgain => 'Play Again';

  @override
  String get time => 'Time';

  @override
  String get mistakes => 'Mistakes';

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Russian';

  @override
  String get showConflicts => 'Show Conflicts';

  @override
  String get autoSave => 'Auto Save';

  @override
  String get sound => 'Sound';

  @override
  String get vibration => 'Vibration';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get invalidMove => 'Invalid move';

  @override
  String get noMoreHints => 'No more hints available';

  @override
  String get puzzleSaved => 'Puzzle saved';

  @override
  String get resetProgress => 'Reset Progress';

  @override
  String get resetProgressConfirm =>
      'Are you sure you want to reset your progress?';

  @override
  String get statistics => 'Statistics';

  @override
  String get gamesPlayed => 'Games Played';

  @override
  String get gamesWon => 'Games Won';

  @override
  String get winRate => 'Win Rate';

  @override
  String get bestTime => 'Best Time';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get longestStreak => 'Longest Streak';

  @override
  String get saveMilestone => 'Save checkpoint';

  @override
  String get restoreMilestone => 'Restore checkpoint';

  @override
  String get highlightSameDigit => 'Highlight matching digits';

  @override
  String get exitHighlightSameDigit => 'Turn off digit highlight';

  @override
  String get showSolution => 'Show Solution';

  @override
  String get tapToClose => 'Tap to close';

  @override
  String get help => 'Help';

  @override
  String get helpRulesTitle => 'Rules';

  @override
  String get helpRulesText =>
      'Fill every row, column, and 3×3 box with the digits 1–9 so that each digit appears exactly once in each row, column, and box.';

  @override
  String get helpHowFormedTitle => 'How the puzzle is formed';

  @override
  String get helpHowFormedText =>
      'The app first generates a fully solved grid, then removes some cells to create the puzzle. The remaining filled cells are the given clues — shown in a different colour and not editable. Every puzzle has exactly one correct solution.';

  @override
  String get helpDifficultyTitle => 'Difficulty levels';

  @override
  String get helpDifficultyText =>
      'Difficulty is controlled by the number of given clues:\n  • Easy — ~51 clues\n  • Medium — ~41 clues\n  • Hard — ~33 clues\n  • Expert — ~27 clues\nFewer clues mean more cells to fill in and harder logical deductions required.';

  @override
  String get helpToolbarTitle => 'Toolbar';

  @override
  String get helpToolbarNotesDesc =>
      'Toggle note mode — pencil candidate digits into cells instead of entering answers. Press N.';

  @override
  String get helpToolbarHighlightDesc =>
      'Highlight all cells that contain the same digit as the selected cell.';

  @override
  String get helpToolbarUndoDesc => 'Undo / Redo your last moves.';

  @override
  String get helpToolbarClearDesc =>
      'Clear the digit or notes from the selected cell.';

  @override
  String get helpToolbarResetDesc =>
      'Reset the puzzle to its original state, clearing all your moves and checkpoints.';

  @override
  String get helpToolbarNewGameDesc =>
      'Start a new puzzle. You will be asked to choose a difficulty.';

  @override
  String get helpToolbarCheckpointSaveDesc =>
      'Save the current board state as a checkpoint.';

  @override
  String get helpToolbarCheckpointRestoreDesc =>
      'Restore a previously saved checkpoint from the list.';

  @override
  String get helpKeyboardTitle => 'Keyboard shortcuts';

  @override
  String get helpKeyboardDigitsDesc => 'Enter a digit in the selected cell';

  @override
  String get helpKeyboardNDesc => 'Toggle note mode';

  @override
  String get helpKeyboardArrowsDesc =>
      'Move selection (wraps within row / column)';

  @override
  String get helpKeyboardBackspaceDesc => 'Clear selected cell';

  @override
  String get helpKeyboardUndoDesc => 'Undo';

  @override
  String get helpKeyboardRedoDesc => 'Redo';
}
