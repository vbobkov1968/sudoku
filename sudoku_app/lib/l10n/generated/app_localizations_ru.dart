// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Судоку';

  @override
  String get newGame => 'Новая игра';

  @override
  String get continueGame => 'Продолжить';

  @override
  String get settings => 'Настройки';

  @override
  String get difficulty => 'Сложность';

  @override
  String get difficultyEasy => 'Лёгкий';

  @override
  String get difficultyMedium => 'Средний';

  @override
  String get difficultyHard => 'Сложный';

  @override
  String get difficultyExpert => 'Эксперт';

  @override
  String get notes => 'Заметки';

  @override
  String get enterNoteMode => 'Режим заметок (N)';

  @override
  String get exitNoteMode => 'Выйти из режима заметок (N)';

  @override
  String get undo => 'Отменить';

  @override
  String get redo => 'Повторить';

  @override
  String get clearCell => 'Стереть ячейку';

  @override
  String get resetPuzzle => 'Сбросить головоломку';

  @override
  String get check => 'Проверить';

  @override
  String get hint => 'Подсказка';

  @override
  String get erase => 'Стереть';

  @override
  String get clearAll => 'Очистить всё';

  @override
  String get congratulations => 'Поздравляем!';

  @override
  String get puzzleComplete => 'Головоломка решена!';

  @override
  String get playAgain => 'Играть снова';

  @override
  String get time => 'Время';

  @override
  String get mistakes => 'Ошибки';

  @override
  String get back => 'Назад';

  @override
  String get cancel => 'Отмена';

  @override
  String get done => 'Готово';

  @override
  String get close => 'Закрыть';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get theme => 'Тема';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeSystem => 'Системная';

  @override
  String get language => 'Язык';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Русский';

  @override
  String get showConflicts => 'Показывать конфликты';

  @override
  String get autoSave => 'Автосохранение';

  @override
  String get sound => 'Звук';

  @override
  String get vibration => 'Вибрация';

  @override
  String get about => 'О приложении';

  @override
  String get version => 'Версия';

  @override
  String get invalidMove => 'Неверный ход';

  @override
  String get noMoreHints => 'Подсказок больше нет';

  @override
  String get puzzleSaved => 'Головоломка сохранена';

  @override
  String get resetProgress => 'Сбросить прогресс';

  @override
  String get resetProgressConfirm =>
      'Вы уверены, что хотите сбросить прогресс?';

  @override
  String get statistics => 'Статистика';

  @override
  String get gamesPlayed => 'Сыграно игр';

  @override
  String get gamesWon => 'Выиграно';

  @override
  String get winRate => 'Процент побед';

  @override
  String get bestTime => 'Лучшее время';

  @override
  String get currentStreak => 'Текущая серия';

  @override
  String get longestStreak => 'Лучшая серия';

  @override
  String get saveMilestone => 'Сохранить закладку';

  @override
  String get restoreMilestone => 'Восстановить закладку';

  @override
  String get highlightSameDigit => 'Подсветка одинаковых цифр';

  @override
  String get exitHighlightSameDigit => 'Выключить подсветку цифр';

  @override
  String get hintAvailableDigits => 'Подсказка доступных цифр';

  @override
  String get exitHintAvailableDigits => 'Выключить подсказку цифр';

  @override
  String get showSolution => 'Показать решение';

  @override
  String get tapToClose => 'Нажмите, чтобы закрыть';

  @override
  String get help => 'Справка';

  @override
  String get helpRulesTitle => 'Правила';

  @override
  String get helpRulesText =>
      'Заполните каждую строку, столбец и блок 3×3 цифрами от 1 до 9 так, чтобы каждая цифра встречалась ровно один раз в каждой строке, столбце и блоке.';

  @override
  String get helpHowFormedTitle => 'Как формируется головоломка';

  @override
  String get helpHowFormedText =>
      'Приложение генерирует полностью решённую сетку, затем убирает часть цифр. Оставшиеся заполненные ячейки — это подсказки: они отображаются другим цветом и недоступны для редактирования. У каждой головоломки есть единственное верное решение.';

  @override
  String get helpDifficultyTitle => 'Уровни сложности';

  @override
  String get helpDifficultyText =>
      'Сложность определяется количеством подсказок:\n  • Лёгкий — ~51 подсказка\n  • Средний — ~41 подсказка\n  • Сложный — ~33 подсказки\n  • Эксперт — ~27 подсказок\nЧем меньше подсказок, тем больше ячеек нужно заполнить и тем сложнее логические выводы.';

  @override
  String get helpToolbarTitle => 'Панель инструментов';

  @override
  String get helpToolbarNotesDesc =>
      'Режим заметок — вводит кандидатов в ячейку вместо окончательного ответа. Нажмите N.';

  @override
  String get helpToolbarHighlightDesc =>
      'Подсвечивает все ячейки с той же цифрой, что и выбранная.';

  @override
  String get helpToolbarHintDesc =>
      'Показывает, какие цифры доступны для выбранной ячейки: зелёный фон — валидная цифра, ещё не внесённая в заметки; зелёная обводка — валидная цифра, уже отмеченная в заметках.';

  @override
  String get helpToolbarUndoDesc => 'Отменить / Повторить последние ходы.';

  @override
  String get helpToolbarClearDesc =>
      'Стереть цифру или заметки из выбранной ячейки.';

  @override
  String get helpToolbarResetDesc =>
      'Сбросить головоломку к исходному состоянию, очистив все ходы и закладки.';

  @override
  String get helpToolbarNewGameDesc =>
      'Начать новую игру. Будет предложено выбрать уровень сложности.';

  @override
  String get helpToolbarCheckpointSaveDesc =>
      'Сохранить текущее состояние доски как закладку.';

  @override
  String get helpToolbarCheckpointRestoreDesc =>
      'Восстановить ранее сохранённую закладку из списка.';

  @override
  String get helpKeyboardTitle => 'Клавиатура';

  @override
  String get helpKeyboardDigitsDesc => 'Ввод цифры в выбранную ячейку';

  @override
  String get helpKeyboardNDesc => 'Переключить режим заметок';

  @override
  String get helpKeyboardArrowsDesc =>
      'Перемещение по сетке (зацикленное по строке / столбцу)';

  @override
  String get helpKeyboardBackspaceDesc => 'Очистить выбранную ячейку';

  @override
  String get helpKeyboardUndoDesc => 'Отменить';

  @override
  String get helpKeyboardRedoDesc => 'Повторить';

  @override
  String get exportGame => 'Экспортировать';

  @override
  String get loadGame => 'Открыть игру';

  @override
  String get importSuccess => 'Игра загружена';

  @override
  String get importError => 'Неверный файл игры';
}
