import 'package:test/test.dart';
import 'package:cs4381_game_b/game.dart';
import 'package:cs4381_game_b/board.dart';

void main() {
  group('Game initialization', () {
    test('game starts with two players', () {
      final game = Game();

      expect(game.state.players.length, 2);
      expect(game.currentPlayer.name, 'Player 1');
    });

    test('each player starts with exactly four pieces', () {
      final game = Game();

      for (final player in game.state.players) {
        expect(player.pieces.length, 4);
      }
    });

    test('all pieces start inactive and not completed', () {
      final game = Game();

      for (final player in game.state.players) {
        for (final piece in player.pieces) {
          expect(piece.position, isNull);
          expect(piece.completed, isFalse);
          expect(piece.isInactive, isTrue);
        }
      }
    });
  });

  group('Throw logic', () {
    test('throwSticks creates a move value between 1 and 5', () {
      final game = Game();

      final moveValue = game.throwSticks();

      expect(moveValue >= 1 && moveValue <= 5, isTrue);
      expect(game.state.availableThrows.contains(moveValue), isTrue);
    });
  });

  group('Piece movement', () {
    test('inactive piece enters board and moves from start', () {
      final game = Game();
      final piece = game.currentPlayer.pieces.first;

      game.state.availableThrows.add(1);
      game.movePiece(piece, 1);

      expect(piece.position, 1);
      expect(piece.completed, isFalse);
    });

    test('used throw is removed after movement', () {
      final game = Game();
      final piece = game.currentPlayer.pieces.first;

      game.state.availableThrows.add(2);
      game.movePiece(piece, 2);

      expect(game.state.availableThrows.contains(2), isFalse);
    });

    test('turn advances when no throws remain', () {
      final game = Game();
      final piece = game.currentPlayer.pieces.first;

      game.state.availableThrows.add(1);
      game.movePiece(piece, 1);

      expect(game.currentPlayer.name, 'Player 2');
    });

    test('turn does not advance if another throw remains', () {
      final game = Game();
      final piece = game.currentPlayer.pieces.first;

      game.state.availableThrows.addAll([1, 2]);
      game.movePiece(piece, 1);

      expect(game.currentPlayer.name, 'Player 1');
      expect(game.state.availableThrows, [2]);
    });
  });

  group('Invalid moves', () {
    test('cannot move opponent piece', () {
      final game = Game();
      final opponentPiece = game.state.players[1].pieces.first;

      game.state.availableThrows.add(1);

      expect(
        () => game.movePiece(opponentPiece, 1),
        throwsArgumentError,
      );
    });

    test('cannot move without available throw', () {
      final game = Game();
      final piece = game.currentPlayer.pieces.first;

      expect(
        () => game.movePiece(piece, 1),
        throwsArgumentError,
      );
    });

    test('cannot move completed piece', () {
      final game = Game();
      final piece = game.currentPlayer.pieces.first;

      piece.completed = true;
      game.state.availableThrows.add(1);

      expect(
        () => game.movePiece(piece, 1),
        throwsStateError,
      );
    });
  });

  group('Invariant validation', () {
    test('player invariant rejects wrong number of pieces', () {
      final game = Game();
      final player = game.currentPlayer;

      player.pieces.removeLast();

      expect(
        () => player.validate(),
        throwsStateError,
      );
    });

    test('piece invariant rejects invalid station', () {
      final game = Game();
      final piece = game.currentPlayer.pieces.first;
      final board = Board();

      piece.position = 99;

      expect(
        () => piece.validate(board),
        throwsStateError,
      );
    });
  });
}