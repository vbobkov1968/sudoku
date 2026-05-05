import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../core/models/game_state.dart';
import '../core/models/milestone.dart';
import '../core/generator/puzzle_generator.dart';
import '../core/models/difficulty.dart';
import '../data/persistence/game_export_service.dart';
import '../data/persistence/game_persistence.dart';
import 'about_app_dialog.dart';
import 'app_settings_scope.dart';
import 'help_dialog.dart' show HelpPanel;
import 'difficulty_picker_dialog.dart';
import 'settings_screen.dart';
import 'widgets/number_pad.dart';
import 'widgets/solution_overlay.dart' show SolutionGrid;
import 'widgets/sudoku_grid.dart';
import 'widgets/victory_overlay.dart';

/// The main game screen that displays the Sudoku grid.
class GameScreen extends StatefulWidget {
  final GameState gameState;
  final Difficulty difficulty;
  final List<Milestone> milestones;
  final bool highlightSameDigit;

  const GameScreen({
    super.key,
    required this.gameState,
    required this.difficulty,
    this.milestones = const [],
    this.highlightSameDigit = false,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  static const _menuChannel = MethodChannel('com.sudoku/menu');

  late GameState _gameState;
  late Difficulty _difficulty;
  bool _showVictory = false;
  bool _showSolution = false;
  bool _highlightSameDigit = false;
  final FocusNode _focusNode = FocusNode();
  final List<Milestone> _milestones = [];

  @override
  void initState() {
    super.initState();
    _gameState = widget.gameState;
    _difficulty = widget.difficulty;
    _milestones.addAll(widget.milestones);
    _highlightSameDigit = widget.highlightSameDigit;
    WidgetsBinding.instance.addObserver(this);
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.android) WakelockPlus.enable();
    if (!kIsWeb) _menuChannel.setMethodCallHandler(_handleMenuCall);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _focusNode.requestFocus();
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) {
        final lang = Localizations.localeOf(context).languageCode;
        _menuChannel.invokeMethod<void>('setLocale', lang).catchError((_) {});
      }
      // Check if app was opened by tapping a .sudoku file (cold-start).
      if (!kIsWeb) {
        try {
          final bytes = await _menuChannel.invokeMethod<Uint8List>('getPendingFile');
          if (bytes != null && mounted) await _loadFromBytes(bytes);
        } catch (_) {}
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) {
      final lang = Localizations.localeOf(context).languageCode;
      _menuChannel.invokeMethod<void>('setLocale', lang).catchError((_) {});
    }
  }

  Future<void> _handleMenuCall(MethodCall call) async {
    if (!mounted) return;
    switch (call.method) {
      case 'openSettings':  SettingsDialog.show(context);
      case 'openAbout':     AboutAppDialog.show(context);
      case 'openHelp':      HelpPanel.show(context);
      case 'showSolution':  _revealSolution();
      case 'exportGame':    _exportGame();
      case 'importGame':    _importGame();
      case 'openGameFile':
        final bytes = call.arguments as Uint8List;
        await _loadFromBytes(bytes);
    }
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!kIsWeb && defaultTargetPlatform != TargetPlatform.android) return;
    if (state == AppLifecycleState.resumed) {
      WakelockPlus.enable();
      if (!kIsWeb) {
        // Check if app was brought to foreground by opening a .sudoku file
        // (singleTask: onNewIntent sets pendingFileBytes, then app resumes).
        _menuChannel.invokeMethod<Uint8List>('getPendingFile').then((bytes) {
          if (bytes != null && mounted) _loadFromBytes(bytes);
        }).catchError((_) {});
      }
    } else if (state == AppLifecycleState.paused ||
               state == AppLifecycleState.inactive) {
      WakelockPlus.disable();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.android) WakelockPlus.disable();
    if (!kIsWeb) _menuChannel.setMethodCallHandler(null);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: !_showSolution,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _showSolution) _dismissSolution();
      },
      child: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Scaffold(
          backgroundColor: (kIsWeb || defaultTargetPlatform == TargetPlatform.android)
              ? Theme.of(context).colorScheme.surface
              : null,
          appBar: (kIsWeb || defaultTargetPlatform == TargetPlatform.android)
              ? AppBar(
                  centerTitle: false,
                  title: GestureDetector(
                    onLongPress: _revealSolution,
                    child: Text(l10n.appTitle),
                  ),
                  actions: [
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) => _handleAndroidMenu(value, context),
                      itemBuilder: (ctx) => [
                        PopupMenuItem(value: 'settings', child: Text(l10n.settings)),
                        PopupMenuItem(value: 'about', child: Text(l10n.about)),
                        PopupMenuItem(value: 'help', child: Text(l10n.help)),
                        const PopupMenuDivider(),
                        PopupMenuItem(value: 'export', child: Text(l10n.exportGame)),
                      ],
                    ),
                  ],
                )
              : null,
          body: Stack(
            children: [
              if (_showSolution)
                Positioned.fill(
                  child: ColoredBox(color: Colors.black.withValues(alpha: 0.85)),
                ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = !kIsWeb && defaultTargetPlatform != TargetPlatform.android;
                  return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
                },
              ),
              if (_showVictory && !_showSolution)
                VictoryOverlay(
                  onNewGame: _newGame,
                  onContinue: _dismissVictory,
                ),
              if (_showSolution) ...[
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _dismissSolution,
                    behavior: HitTestBehavior.opaque,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 20,
                  child: IgnorePointer(
                    child: Text(
                      l10n.tapToClose,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white38,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleAndroidMenu(String value, BuildContext context) {
    if (value == 'settings') {
      SettingsDialog.show(context);
    } else if (value == 'about') {
      AboutAppDialog.show(context);
    } else if (value == 'help') {
      HelpPanel.show(context);
    } else if (value == 'export') {
      _exportGame();
    } else if (value == 'load') {
      _importGame();
    }
  }

  /// Desktop layout: grid centred, toolbar + numpad pinned to bottom centre.
  Widget _buildDesktopLayout() {
    final topPadding = (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS) ? 52.0 : 24.0;
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
                child: Stack(
                  children: [
                    SudokuGrid(
                      gameState: _gameState,
                      onCellTap: _onCellTap,
                      highlightSameDigit: _highlightSameDigit,
                    ),
                    if (_showSolution)
                      Positioned.fill(child: SolutionGrid(gameState: _gameState)),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Visibility(
          visible: !_showSolution,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: _buildToolbar(context),
        ),
        const SizedBox(height: 12),
        Visibility(
          visible: !_showSolution,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: SizedBox(width: 280, child: _buildNumpadCard()),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Mobile / web layout: grid fills remaining space, controls pinned below.
  Widget _buildMobileLayout() {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final aw = constraints.maxWidth;
          final ah = constraints.maxHeight;

          // Cap at 320 so numpad buttons stay ~60px tall (comfortable tap target).
          final controlsWidth = (aw - 32).clamp(200.0, 320.0);

          // Numpad height: GridView with childAspectRatio 1.6, 3 rows.
          // buttonWidth = (controlsWidth − 28) / 3  (28 = card+gridview+cross-spacing)
          // numpadCardHeight = 3 × (buttonWidth/1.6) + spacing + padding
          //                  = (controlsWidth − 28) × 0.625 + 28
          final numpadH = (controlsWidth - 28) * 0.625 + 28;
          // Toolbar: 2 rows × 32px + 2px gap + 8px card padding = 74px
          const toolbarH = 74.0;
          const innerGap = 8.0; // between toolbar and numpad
          const bottomPad = 12.0; // breathing room below numpad
          final controlsH = toolbarH + innerGap + numpadH + bottomPad;

          const gap = 8.0; // above grid, between grid and controls, below controls
          // Grid: remaining height, min = controlsWidth (stops at toolbar width),
          // max = full viewport width with side padding.
          final gridSize = (ah - controlsH - gap * 3).clamp(controlsWidth, aw - 32.0);
          final totalH = gridSize + controlsH + gap * 3;

          final gridWidget = SizedBox(
            width: gridSize,
            height: gridSize,
            child: Stack(children: [
              SudokuGrid(
                gameState: _gameState,
                onCellTap: _onCellTap,
                highlightSameDigit: _highlightSameDigit,
              ),
              if (_showSolution)
                Positioned.fill(child: SolutionGrid(gameState: _gameState)),
            ]),
          );

          final controlsWidget = Visibility(
            visible: !_showSolution,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: SizedBox(
              width: controlsWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToolbar(context, width: null),
                  const SizedBox(height: innerGap),
                  _buildNumpadCard(),
                  const SizedBox(height: bottomPad),
                ],
              ),
            ),
          );

          // Content overflows: allow scrolling.
          if (totalH > ah) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: gap),
                  Center(child: gridWidget),
                  const SizedBox(height: gap),
                  Center(child: controlsWidget),
                  const SizedBox(height: gap),
                ],
              ),
            );
          }

          // Content fits: distribute extra space evenly above/between/below.
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Center(child: gridWidget),
              Center(child: controlsWidget),
            ],
          );
        },
      ),
    );
  }

  Color _cardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xCC1C1C1E) : Colors.grey.shade50;
  }

  Widget _buildToolbar(BuildContext context, {double? width = 280}) {
    final l10n = AppLocalizations.of(context)!;
    final isMac = !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
    final undoShortcut = isMac ? '⌘Z' : 'Ctrl+Z';
    final redoShortcut = isMac ? '⇧⌘Z' : 'Shift+Ctrl+Z';
    final timeFmt = DateFormat('HH:mm:ss');

    // Square constraints keep the ripple circular and prevent overflow for 8 buttons.
    const btnSize = BoxConstraints.tightFor(width: 32, height: 32);

    final card = Card(
      color: _cardColor(context),
      elevation: 1,
      shadowColor: Colors.black26,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Theme(
        data: Theme.of(context).copyWith(
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
          disabledColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
              padding: WidgetStateProperty.all(EdgeInsets.zero),
              minimumSize: WidgetStateProperty.all(Size.zero),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    constraints: btnSize,
                    icon: Icon(
                      _gameState.noteMode ? Icons.edit_note_outlined : Icons.edit_off_outlined,
                      color: _gameState.noteMode ? Theme.of(context).colorScheme.primary : null,
                    ),
                    onPressed: _toggleNoteMode,
                    tooltip: _gameState.noteMode ? l10n.exitNoteMode : l10n.enterNoteMode,
                    style: _gameState.noteMode
                        ? IconButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          )
                        : null,
                  ),
                  IconButton(
                    constraints: btnSize,
                    icon: Icon(
                      Icons.highlight,
                      color: _highlightSameDigit ? const Color(0xFFFF9800) : null,
                    ),
                    onPressed: _toggleHighlightSameDigit,
                    tooltip: _highlightSameDigit
                        ? l10n.exitHighlightSameDigit
                        : l10n.highlightSameDigit,
                    style: _highlightSameDigit
                        ? IconButton.styleFrom(
                            backgroundColor: const Color(0xFFFF9800).withValues(alpha: 0.15),
                          )
                        : null,
                  ),
                  IconButton(
                    constraints: btnSize,
                    icon: const Icon(Icons.undo_outlined),
                    onPressed: _gameState.canUndo ? _undo : null,
                    tooltip: '${l10n.undo} ($undoShortcut)',
                  ),
                  IconButton(
                    constraints: btnSize,
                    icon: const Icon(Icons.redo_outlined),
                    onPressed: _gameState.canRedo ? _redo : null,
                    tooltip: '${l10n.redo} ($redoShortcut)',
                  ),
                  IconButton(
                    constraints: btnSize,
                    icon: const Icon(Icons.backspace_outlined),
                    onPressed: _onClearPressed,
                    tooltip: l10n.clearCell,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(width: 32, height: 32),
                  IconButton(
                    constraints: btnSize,
                    icon: const Icon(Icons.replay_outlined),
                    onPressed: _resetPuzzle,
                    tooltip: l10n.resetPuzzle,
                  ),
                  IconButton(
                    constraints: btnSize,
                    icon: const Icon(Icons.casino_outlined),
                    onPressed: _newGame,
                    tooltip: l10n.newGame,
                  ),
                  IconButton(
                    constraints: btnSize,
                    icon: const Icon(Icons.flag_outlined),
                    onPressed: _canSaveMilestone ? _saveMilestone : null,
                    tooltip: l10n.saveMilestone,
                  ),
                  SizedBox.fromSize(
                    size: const Size(32, 32),
                    child: PopupMenuButton<int>(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.history,
                        color: _milestones.isEmpty
                            ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25)
                            : null,
                      ),
                      tooltip: l10n.restoreMilestone,
                      enabled: _milestones.isNotEmpty,
                      onSelected: _restoreMilestone,
                      itemBuilder: (_) => [
                        for (var i = _milestones.length - 1; i >= 0; i--)
                          PopupMenuItem<int>(
                            value: i,
                            child: Text('${i + 1}. ${timeFmt.format(_milestones[i].createdAt)}'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return width != null ? SizedBox(width: width, child: card) : card;
  }

  Widget _buildNumpadCard() {
    return Card(
      color: _cardColor(context),
      elevation: 1,
      shadowColor: Colors.black26,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: NumberPad(onDigitPressed: _onDigitPressed),
      ),
    );
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.escape) {
      if (_showSolution) { _dismissSolution(); return; }
    }

    final isCmd = (!kIsWeb && defaultTargetPlatform == TargetPlatform.macOS)
        ? HardwareKeyboard.instance.isMetaPressed
        : HardwareKeyboard.instance.isControlPressed;
    final isShift = HardwareKeyboard.instance.isShiftPressed;

    if (isCmd && key == LogicalKeyboardKey.keyZ) {
      if (isShift) {
        if (_gameState.canRedo) _redo();
      } else {
        if (_gameState.canUndo) _undo();
      }
      return;
    }

    if (key == LogicalKeyboardKey.keyN) {
      _toggleNoteMode();
      return;
    }
    if (key == LogicalKeyboardKey.backspace || key == LogicalKeyboardKey.delete) {
      _onClearPressed();
      return;
    }
    if (_handleArrowKey(key)) return;
    final digit = _logicalKeyToDigit(key);
    if (digit != null) _onDigitPressed(digit);
  }

  bool _handleArrowKey(LogicalKeyboardKey key) {
    final sel = _gameState.selectedCell;
    final int row;
    final int col;
    if (sel != null) {
      (row, col) = sel;
    } else {
      // No selection — arrow key picks the first cell
      if (key == LogicalKeyboardKey.arrowRight ||
          key == LogicalKeyboardKey.arrowLeft ||
          key == LogicalKeyboardKey.arrowUp ||
          key == LogicalKeyboardKey.arrowDown) {
        setState(() => _gameState.selectCell(0, 0));
        return true;
      }
      return false;
    }

    int newRow = row;
    int newCol = col;
    if (key == LogicalKeyboardKey.arrowRight) {
      newCol = (col + 1) % 9;
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      newCol = (col + 8) % 9;
    } else if (key == LogicalKeyboardKey.arrowDown) {
      newRow = (row + 1) % 9;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      newRow = (row + 8) % 9;
    } else {
      return false;
    }

    setState(() => _gameState.selectCell(newRow, newCol));
    return true;
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

  bool get _canSaveMilestone =>
      _gameState.hasProgress &&
      (_milestones.isEmpty ||
       _gameState.currentBoard != _milestones.last.board);

  void _saveMilestone() {
    setState(() {
      _milestones.add(Milestone(
        createdAt: DateTime.now(),
        board: _gameState.currentBoard.copy(),
        noteMode: _gameState.noteMode,
      ));
    });
    _autosave();
  }

  void _restoreMilestone(int index) {
    final m = _milestones[index];
    setState(() {
      _milestones.removeRange(index + 1, _milestones.length);
      _gameState = GameState(
        initialBoard: _gameState.initialBoard,
        solutionBoard: _gameState.solutionBoard,
        currentBoard: m.board.copy(),
        noteMode: m.noteMode,
      );
      _showVictory = false;
      _focusNode.requestFocus();
    });
    _autosave();
  }

  void _autosave() => GamePersistence.save(_gameState, _difficulty, _milestones, highlightSameDigit: _highlightSameDigit);

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

  void _toggleHighlightSameDigit() {
    setState(() => _highlightSameDigit = !_highlightSameDigit);
    _autosave();
  }

  // ---------------------------------------------------------------------------
  // Export / import

  Future<void> _exportGame() async {
    await GameExportService.exportToFile(_gameState, _difficulty, _milestones);
  }

  Future<void> _importGame() async {
    final saved = await GameExportService.importFromFile();
    if (!mounted) return;
    if (saved == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.importError)),
      );
      return;
    }
    _applyLoadedGame(saved);
  }

  Future<void> _loadFromBytes(Uint8List bytes) async {
    final saved = GameExportService.decode(bytes);
    if (!mounted) return;
    if (saved == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.importError)),
      );
      return;
    }
    _applyLoadedGame(saved);
  }

  void _applyLoadedGame(SavedGame saved) {
    final notifier = AppSettingsScope.read(context);
    notifier.update(notifier.value.withDifficulty(saved.difficulty));
    setState(() {
      _gameState = saved.state;
      _difficulty = saved.difficulty;
      _milestones
        ..clear()
        ..addAll(saved.milestones);
      _showVictory = false;
      _showSolution = false;
      _focusNode.requestFocus();
    });
    _autosave();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.importSuccess)),
    );
  }

  void _revealSolution() {
    setState(() => _showSolution = true);
  }

  void _dismissSolution() {
    setState(() => _showSolution = false);
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
      _milestones.clear();
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
      _milestones.clear();
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
