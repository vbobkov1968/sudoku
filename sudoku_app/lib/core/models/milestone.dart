import 'board.dart';

class Milestone {
  final DateTime createdAt;
  final Board board;
  final bool noteMode;

  Milestone({
    required this.createdAt,
    required this.board,
    required this.noteMode,
  });
}
