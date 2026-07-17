import 'piece.dart';

enum PlayerType {
  human,
  computer,
}

class Player {
  final String name;
  final PlayerType type;
  final List<Piece> pieces = [];

  Player(
    this.name, {
    this.type = PlayerType.human,
  });

  bool get isHuman => type == PlayerType.human;

  bool get isComputer => type == PlayerType.computer;

  void initializePieces() {
    if (pieces.isNotEmpty) return;

    for (int i = 0; i < 4; i++) {
      pieces.add(Piece(owner: this));
    }

    validate();
  }

  void validate() {
    if (pieces.length != 4) {
      throw StateError('Each player must always have exactly 4 pieces.');
    }

    for (final piece in pieces) {
      if (piece.owner != this) {
        throw StateError('Piece belongs to the wrong player.');
      }
    }
  }
}