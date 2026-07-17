import 'dart:math';
import 'game_settings.dart';
import 'board.dart';
import 'game_engine.dart';
import 'game_state.dart';
import 'piece.dart';
import 'player.dart';

class Game implements GameEngine {
  final Board _board = Board();
  final Random _random = Random();
  final GameSettings settings;

  static const int redXMove = -1;
  static const int _extraTurnMarker = 0;

  List<bool> lastSticks = [];

  @override
  late final GameState state;

  Game({GameSettings? gameSettings})
    : settings = gameSettings ?? GameSettings(mode: GameMode.humanVsHuman) {
    final player1 = Player("Player 1");
    final player2 = Player(
      settings.mode == GameMode.humanVsComputer ? "Computer" : "Player 2",
      type: settings.mode == GameMode.humanVsComputer
          ? PlayerType.computer
          : PlayerType.human,
    );

    player1.initializePieces();
    player2.initializePieces();

    state = GameState(players: [player1, player2]);
  }

  @override
  Player get currentPlayer => state.currentPlayer;

  @override
  int throwSticks() {
    lastSticks = List.generate(5, (_) => _random.nextBool());

    final showingCount = lastSticks.where((showing) => showing).length;
    final redXShowing = lastSticks[0];

    int moveValue;

    if (showingCount == 1 && redXShowing) {
      moveValue = redXMove;
    } else if (showingCount == 0) {
      moveValue = 5;
    } else {
      moveValue = showingCount;
    }

    state.availableThrows.add(moveValue);

    if (moveValue == 5) {
      state.availableThrows.add(_extraTurnMarker);
    }

    state.validate();
    return moveValue;
  }

  @override
  void movePiece(Piece piece, int moveValue) {
    _validateMove(piece, moveValue);

    final movingPieces = _piecesMovingWith(piece);

    for (final movingPiece in movingPieces) {
      if (moveValue == redXMove) {
        _movePieceBackward(movingPiece);
      } else {
        _movePieceForward(movingPiece, moveValue);
      }
    }

    for (final movingPiece in movingPieces) {
      _captureOpponentPieces(movingPiece);
    }

    state.availableThrows.remove(moveValue);

    if (state.availableThrows.contains(_extraTurnMarker)) {
      state.availableThrows.remove(_extraTurnMarker);
      return;
    }

    if (state.availableThrows.isEmpty) {
      _advanceTurn();
    }

    _validateAll();
  }

  List<Piece> _piecesMovingWith(Piece selectedPiece) {
    if (!selectedPiece.isActive) {
      return [selectedPiece];
    }

    return selectedPiece.owner.pieces.where((piece) {
      return piece.isActive &&
          piece.position == selectedPiece.position &&
          !piece.completed;
    }).toList();
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

  void _captureOpponentPieces(Piece movedPiece) {
    if (!movedPiece.isActive) return;

    for (final player in state.players) {
      if (player == movedPiece.owner) continue;

      for (final opponentPiece in player.pieces) {
        if (opponentPiece.position == movedPiece.position &&
            !opponentPiece.completed) {
          opponentPiece.position = null;
          opponentPiece.previousStation = null;
        }
      }
    }
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

  List<Piece> legalPiecesFor(int moveValue) {
    return currentPlayer.pieces.where((piece) {
      if (piece.completed) {
        return false;
      }

      if (moveValue == redXMove) {
        return piece.isActive && piece.previousStation != null;
      }

      return moveValue >= 1 && moveValue <= 5;
    }).toList();
  }

  bool wouldComplete(Piece piece, int moveValue) {
    if (piece.completed || moveValue == redXMove) {
      return false;
    }

    final startPosition = piece.isInactive
        ? Board.startStationId
        : piece.position!;

    final result = _board.destination(
      startId: startPosition,
      moveValue: moveValue,
    );

    return result.completed;
  }

  bool wouldCapture(Piece piece, int moveValue) {
    if (piece.completed || moveValue == redXMove) {
      return false;
    }

    final startPosition = piece.isInactive
        ? Board.startStationId
        : piece.position!;

    final result = _board.destination(
      startId: startPosition,
      moveValue: moveValue,
    );

    if (result.completed) {
      return false;
    }

    for (final player in state.players) {
      if (player == piece.owner) {
        continue;
      }

      for (final opponentPiece in player.pieces) {
        if (opponentPiece.isActive &&
            opponentPiece.position == result.destination) {
          return true;
        }
      }
    }

    return false;
  }

  int stackSize(Piece selectedPiece) {
    if (!selectedPiece.isActive) {
      return 1;
    }

    return selectedPiece.owner.pieces.where((piece) {
      return piece.isActive &&
          piece.position == selectedPiece.position &&
          !piece.completed;
    }).length;
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
