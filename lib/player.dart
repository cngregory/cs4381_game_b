import 'piece.dart';

class Player {
  final String name;
  final List<Piece> pieces = [];

  Player(this.name);

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