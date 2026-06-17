import 'player.dart';

class GameState {
  final List<Player> players;
  int currentPlayerIndex;
  final List<int> availableThrows;

  GameState({
    required this.players,
    this.currentPlayerIndex = 0,
    List<int>? availableThrows,
  }) : availableThrows = availableThrows ?? [] {
    validate();
  }

  Player get currentPlayer => players[currentPlayerIndex];

  void validate() {
    if (players.length != 2) {
      throw StateError('Game must have exactly two players.');
    }

    if (currentPlayerIndex < 0 ||
        currentPlayerIndex >= players.length) {
      throw StateError('Current player index is invalid.');
    }

    for (final player in players) {
      player.validate();
    }
  }
}