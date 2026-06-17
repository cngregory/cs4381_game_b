import 'dart:math';

import 'board.dart';
import 'game_engine.dart';
import 'game_state.dart';
import 'piece.dart';
import 'player.dart';

class Game implements GameEngine {
  final Board _board = Board();
  final Random _random = Random();
  static const int redXMove = -1;
  static const int _extraTurnMarker = 0;

  @override
  late final GameState state;

  Game() {
    final player1 = Player("Player 1");
    final player2 = Player("Player 2");

    player1.initializePieces();
    player2.initializePieces();

    state = GameState(players: [player1, player2]);
  }

  @override
  Player get currentPlayer => state.currentPlayer;

  @override
  int throwSticks() {
    final flatSticks = _random.nextInt(5);

    int moveValue;

    if (flatSticks == 0) {
      moveValue = 5;
    } else {
      moveValue = flatSticks;
    }

    state.availableThrows.add(moveValue);

    if (flatSticks == 0 || flatSticks == 4) {
      state.availableThrows.add(_extraTurnMarker);
    }

    state.validate();
    return moveValue;
  }

  @override
  void movePiece(Piece piece, int moveValue) {
    _validateMove(piece, moveValue);

    if (moveValue == redXMove) {
      _movePieceBackward(piece);
    } else {
      _movePieceForward(piece, moveValue);
    }

    state.availableThrows.remove(moveValue);

    state.availableThrows.remove(_extraTurnMarker);

    if (state.availableThrows.isEmpty) {
      _advanceTurn();
    }

    _validateAll();
  }

  void _movePieceForward(Piece piece, int moveValue) {
    if (piece.isInactive) {
      piece.position = Board.startStationId;
    }

    final result = _board.destination(
      startId: piece.position!,
      moveValue: moveValue,
    );

    piece.previousStation = result.previousStation;

    if (result.completed) {
      piece.position = null;
      piece.completed = true;
    } else {
      piece.position = result.destination;
    }
  }

  void _movePieceBackward(Piece piece) {
    if (!piece.isActive) {
      throw StateError('Only an active piece can move backward.');
    }

    if (piece.previousStation == null) {
      throw StateError('Cannot move backward without a previous station.');
    }

    final destination = _board.moveBackward(
      currentStation: piece.position!,
      previousStation: piece.previousStation!,
    );

    piece.position = destination;
  }

  void _validateMove(Piece piece, int moveValue) {
    if (piece.owner != currentPlayer) {
      throw ArgumentError('This piece does not belong to the current player.');
    }

    if (piece.completed) {
      throw StateError('Cannot move a completed piece.');
    }

    if (!state.availableThrows.contains(moveValue)) {
      throw ArgumentError('That move value is not available.');
    }

    final isForwardMove = moveValue >= 1 && moveValue <= 5;
    final isBackwardMove = moveValue == redXMove;

    if (!isForwardMove && !isBackwardMove) {
      throw ArgumentError('Move value must be 1-5 or red-X.');
    }
  }

  void _advanceTurn() {
    state.currentPlayerIndex =
        (state.currentPlayerIndex + 1) % state.players.length;
  }

  void _validateAll() {
    _board.validate();
    state.validate();

    for (final player in state.players) {
      for (final piece in player.pieces) {
        piece.validate(_board);
      }
    }
  }
}