import 'board.dart';
import 'player.dart';

class Piece {
  final Player owner;

  int? position;
  int? previousStation;
  bool completed;

  Piece({
    required this.owner,
    this.position,
    this.previousStation,
    this.completed = false,
  });

  bool get isInactive => position == null && !completed;
  bool get isActive => position != null && !completed;

  void validate(Board board) {
    if (completed && position != null) {
      throw StateError('A completed piece cannot still be on the board.');
    }

    if (position != null && !board.isValidStation(position!)) {
      throw StateError('Piece position is not a valid station.');
    }

    if (previousStation != null && !board.isValidStation(previousStation!)) {
      throw StateError('Piece previous station is not valid.');
    }
  }
}
