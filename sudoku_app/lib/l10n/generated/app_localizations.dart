import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Sudoku'**
  String get appTitle;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// No description provided for @continueGame.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueGame;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @difficultyExpert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get difficultyExpert;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @enterNoteMode.
  ///
  /// In en, this message translates to:
  /// **'Enter Note Mode (N)'**
  String get enterNoteMode;

  /// No description provided for @exitNoteMode.
  ///
  /// In en, this message translates to:
  /// **'Exit Note Mode (N)'**
  String get exitNoteMode;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @clearCell.
  ///
  /// In en, this message translates to:
  /// **'Clear cell'**
  String get clearCell;

  /// No description provided for @resetPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Reset puzzle'**
  String get resetPuzzle;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @erase.
  ///
  /// In en, this message translates to:
  /// **'Erase'**
  String get erase;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @puzzleComplete.
  ///
  /// In en, this message translates to:
  /// **'Puzzle Complete!'**
  String get puzzleComplete;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @mistakes.
  ///
  /// In en, this message translates to:
  /// **'Mistakes'**
  String get mistakes;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussian;

  /// No description provided for @showConflicts.
  ///
  /// In en, this message translates to:
  /// **'Show Conflicts'**
  String get showConflicts;

  /// No description provided for @autoSave.
  ///
  /// In en, this message translates to:
  /// **'Auto Save'**
  String get autoSave;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @invalidMove.
  ///
  /// In en, this message translates to:
  /// **'Invalid move'**
  String get invalidMove;

  /// No description provided for @noMoreHints.
  ///
  /// In en, this message translates to:
  /// **'No more hints available'**
  String get noMoreHints;

  /// No description provided for @puzzleSaved.
  ///
  /// In en, this message translates to:
  /// **'Puzzle saved'**
  String get puzzleSaved;

  /// No description provided for @resetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get resetProgress;

  /// No description provided for @resetProgressConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset your progress?'**
  String get resetProgressConfirm;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @gamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Games Played'**
  String get gamesPlayed;

  /// No description provided for @gamesWon.
  ///
  /// In en, this message translates to:
  /// **'Games Won'**
  String get gamesWon;

  /// No description provided for @winRate.
  ///
  /// In en, this message translates to:
  /// **'Win Rate'**
  String get winRate;

  /// No description provided for @bestTime.
  ///
  /// In en, this message translates to:
  /// **'Best Time'**
  String get bestTime;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get longestStreak;

  /// No description provided for @saveMilestone.
  ///
  /// In en, this message translates to:
  /// **'Save checkpoint'**
  String get saveMilestone;

  /// No description provided for @restoreMilestone.
  ///
  /// In en, this message translates to:
  /// **'Restore checkpoint'**
  String get restoreMilestone;

  /// No description provided for @highlightSameDigit.
  ///
  /// In en, this message translates to:
  /// **'Highlight matching digits'**
  String get highlightSameDigit;

  /// No description provided for @exitHighlightSameDigit.
  ///
  /// In en, this message translates to:
  /// **'Turn off digit highlight'**
  String get exitHighlightSameDigit;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @helpRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get helpRulesTitle;

  /// No description provided for @helpRulesText.
  ///
  /// In en, this message translates to:
  /// **'Fill every row, column, and 3×3 box with the digits 1–9 so that each digit appears exactly once in each row, column, and box.'**
  String get helpRulesText;

  /// No description provided for @helpHowFormedTitle.
  ///
  /// In en, this message translates to:
  /// **'How the puzzle is formed'**
  String get helpHowFormedTitle;

  /// No description provided for @helpHowFormedText.
  ///
  /// In en, this message translates to:
  /// **'The app first generates a fully solved grid, then removes some cells to create the puzzle. The remaining filled cells are the given clues — shown in a different colour and not editable. Every puzzle has exactly one correct solution.'**
  String get helpHowFormedText;

  /// No description provided for @helpDifficultyTitle.
  ///
  /// In en, this message translates to:
  /// **'Difficulty levels'**
  String get helpDifficultyTitle;

  /// No description provided for @helpDifficultyText.
  ///
  /// In en, this message translates to:
  /// **'Difficulty is controlled by the number of given clues:\n  • Easy — ~51 clues\n  • Medium — ~41 clues\n  • Hard — ~33 clues\n  • Expert — ~27 clues\nFewer clues mean more cells to fill in and harder logical deductions required.'**
  String get helpDifficultyText;

  /// No description provided for @helpToolbarTitle.
  ///
  /// In en, this message translates to:
  /// **'Toolbar'**
  String get helpToolbarTitle;

  /// No description provided for @helpToolbarNotesDesc.
  ///
  /// In en, this message translates to:
  /// **'Toggle note mode — pencil candidate digits into cells instead of entering answers. Press N.'**
  String get helpToolbarNotesDesc;

  /// No description provided for @helpToolbarHighlightDesc.
  ///
  /// In en, this message translates to:
  /// **'Highlight all cells that contain the same digit as the selected cell.'**
  String get helpToolbarHighlightDesc;

  /// No description provided for @helpToolbarUndoDesc.
  ///
  /// In en, this message translates to:
  /// **'Undo / Redo your last moves.'**
  String get helpToolbarUndoDesc;

  /// No description provided for @helpToolbarClearDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear the digit or notes from the selected cell.'**
  String get helpToolbarClearDesc;

  /// No description provided for @helpToolbarResetDesc.
  ///
  /// In en, this message translates to:
  /// **'Reset the puzzle to its original state, clearing all your moves and checkpoints.'**
  String get helpToolbarResetDesc;

  /// No description provided for @helpToolbarNewGameDesc.
  ///
  /// In en, this message translates to:
  /// **'Start a new puzzle. You will be asked to choose a difficulty.'**
  String get helpToolbarNewGameDesc;

  /// No description provided for @helpToolbarCheckpointSaveDesc.
  ///
  /// In en, this message translates to:
  /// **'Save the current board state as a checkpoint.'**
  String get helpToolbarCheckpointSaveDesc;

  /// No description provided for @helpToolbarCheckpointRestoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Restore a previously saved checkpoint from the list.'**
  String get helpToolbarCheckpointRestoreDesc;

  /// No description provided for @helpKeyboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Keyboard shortcuts'**
  String get helpKeyboardTitle;

  /// No description provided for @helpKeyboardDigitsDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter a digit in the selected cell'**
  String get helpKeyboardDigitsDesc;

  /// No description provided for @helpKeyboardNDesc.
  ///
  /// In en, this message translates to:
  /// **'Toggle note mode'**
  String get helpKeyboardNDesc;

  /// No description provided for @helpKeyboardArrowsDesc.
  ///
  /// In en, this message translates to:
  /// **'Move selection (wraps within row / column)'**
  String get helpKeyboardArrowsDesc;

  /// No description provided for @helpKeyboardBackspaceDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear selected cell'**
  String get helpKeyboardBackspaceDesc;

  /// No description provided for @helpKeyboardUndoDesc.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get helpKeyboardUndoDesc;

  /// No description provided for @helpKeyboardRedoDesc.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get helpKeyboardRedoDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
