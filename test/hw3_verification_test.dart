import 'package:flutter_test/flutter_test.dart';
import 'package:cs4381_game_b_flutter/board.dart';
import 'package:cs4381_game_b_flutter/game.dart';
import 'package:cs4381_game_b_flutter/game_engine.dart';
import 'package:cs4381_game_b_flutter/piece.dart';

void main() {
  group('Category 1 — Functional Behavior', () {
    test('valid move executes and produces the expected state', () {
      // A current-player piece uses an available move of 2.
      final game = Game();
      final piece = game.currentPlayer.pieces.first;
      game.state.availableThrows.add(2);

      game.movePiece(piece, 2);

      expect(piece.position, 2);
      expect(piece.completed, isFalse);
      expect(game.state.availableThrows, isEmpty);
      expect(game.currentPlayer.name, 'Player 2');
    });

    test('invalid move value is rejected and does not change state', () {
      // Even if an invalid value reaches availableThrows, movePiece must reject it.
      final game = Game();
      final piece = game.currentPlayer.pieces.first;
      game.state.availableThrows.add(6);

      final oldPosition = piece.position;
      final oldCompleted = piece.completed;
      final oldPlayerIndex = game.state.currentPlayerIndex;
      final oldThrows = List<int>.from(game.state.availableThrows);

      expect(() => game.movePiece(piece, 6), throwsArgumentError);
      expect(piece.position, oldPosition);
      expect(piece.completed, oldCompleted);
      expect(game.state.currentPlayerIndex, oldPlayerIndex);
      expect(game.state.availableThrows, oldThrows);
    });

    test('opponent piece is rejected rather than silently ignored', () {
      final game = Game();
      final opponentPiece = game.state.players[1].pieces.first;
      game.state.availableThrows.add(1);

      expect(() => game.movePiece(opponentPiece, 1), throwsArgumentError);
      expect(opponentPiece.isInactive, isTrue);
      expect(game.state.availableThrows, [1]);
      expect(game.currentPlayer, isNotNull);
      expect(game.currentPlayer!.name, 'Player 1');
    });

    test('throw then move then turn change follows the state transition', () {
      // This isolates the transition from one available throw to the next player.
      final game = Game();
      final piece = game.currentPlayer.pieces.first;
      game.state.availableThrows.add(1);

      game.movePiece(piece, 1);

      expect(piece.position, 1);
      expect(game.state.availableThrows, isEmpty);
      expect(game.currentPlayer.name, 'Player 2');
    });

    test(
      'NON-OBVIOUS FAILURE: using one of two equal throws preserves the other',
      () {
        // Two independent throws can have the same value. Using one must remove
        // exactly one occurrence, not both occurrences.
        final game = Game();
        final piece = game.currentPlayer.pieces.first;
        game.state.availableThrows.addAll([2, 2]);

        game.movePiece(piece, 2);

        expect(piece.position, 2);
        expect(game.state.availableThrows, [2]);
        expect(game.currentPlayer, isNotNull);
      expect(game.currentPlayer!.name, 'Player 1');
      },
    );

    test('a result of 4 grants an extra turn after its move is used', () {
      // README rule: four flat sticks means move 4 and receive an extra throw.
      // Repeated throwing is used because Game does not inject a Random source.
      final game = Game();
      int? result;

      for (var attempt = 0; attempt < 10000; attempt++) {
        game.state.availableThrows.clear();
        result = game.throwSticks();
        if (result == 4) break;
      }

      expect(result, 4, reason: 'Could not observe a result of 4.');
      final piece = game.currentPlayer.pieces.first;
      game.movePiece(piece, 4);

      expect(piece.position, 4);
      expect(
        game.currentPlayer.name,
        'Player 1',
        reason: 'A result of 4 must preserve the current player for an extra turn.',
      );
    });

    test('throwSticks models the four physical sticks in the rules', () {
      // The project README specifies that each turn throws four sticks.
      final game = Game();

      game.throwSticks();

      expect(game.lastSticks, hasLength(4));
    });
  });

  group('Category 2 — Edge Cases', () {
    test('station 0 is a valid landing position and does not complete a piece', () {
      final board = Board();

      final result = board.destination(startId: 19, moveValue: 1);

      expect(result.destination, Board.startStationId);
      expect(result.completed, isFalse);
      expect(result.previousStation, 19);
    });

    test('station 28 exits according to the path used to enter the center', () {
      final board = Board();

      expect(board.destination(startId: 21, moveValue: 2).destination, 27);
      expect(board.destination(startId: 23, moveValue: 2).destination, 25);
    });

    test('five consecutive extra-turn results do not change player', () {
      // Rotate among pieces so the test measures turn behavior without
      // accidentally completing one piece during the sequence.
      final game = Game();
      final pieces = game.currentPlayer.pieces;
      final sequence = [pieces[0], pieces[1], pieces[2], pieces[3], pieces[0]];

      for (final piece in sequence) {
        game.state.availableThrows.addAll([5, 0]);
        game.movePiece(piece, 5);

        expect(game.currentPlayer, isNotNull);
        expect(
          game.currentPlayer!.name,
          'Player 1',
          reason: 'Each result of 0 flat sticks should preserve the turn.',
        );
      }
    });

    test('friendly pieces on the same station move together', () {
      final game = Game();
      final first = game.currentPlayer.pieces[0];
      final second = game.currentPlayer.pieces[1];
      first
        ..position = 1
        ..previousStation = 0;
      second
        ..position = 1
        ..previousStation = 0;
      game.state.availableThrows.add(1);

      game.movePiece(first, 1);

      expect(first.position, 2);
      expect(second.position, 2);
    });

    test('landing on an opponent captures that piece', () {
      final game = Game();
      final attacker = game.state.players[0].pieces.first;
      final opponent = game.state.players[1].pieces.first;
      attacker
        ..position = 1
        ..previousStation = 0;
      opponent
        ..position = 2
        ..previousStation = 1;
      game.state.availableThrows.add(1);

      game.movePiece(attacker, 1);

      expect(attacker.position, 2);
      expect(opponent.isInactive, isTrue);
      expect(opponent.previousStation, isNull);
    });

    test('capturing a friendly stack of opponents resets every stacked piece', () {
      final game = Game();
      final attacker = game.state.players[0].pieces.first;
      final opponent1 = game.state.players[1].pieces[0];
      final opponent2 = game.state.players[1].pieces[1];
      attacker
        ..position = 1
        ..previousStation = 0;
      opponent1
        ..position = 2
        ..previousStation = 1;
      opponent2
        ..position = 2
        ..previousStation = 1;
      game.state.availableThrows.add(1);

      game.movePiece(attacker, 1);

      expect(opponent1.isInactive, isTrue);
      expect(opponent2.isInactive, isTrue);
      expect(opponent1.previousStation, isNull);
      expect(opponent2.previousStation, isNull);
    });

    test(
      'consecutive red-X moves continue backward along the previously used path',
      () {
        // After moving 2 -> 1, a second backward move should continue 1 -> 0.
        // The unrelated move value 3 keeps the same player's turn active.
        final game = Game();
        final piece = game.currentPlayer.pieces.first;
        piece
          ..position = 2
          ..previousStation = 1;
        game.state.availableThrows.addAll([Game.redXMove, 3]);

        game.movePiece(piece, Game.redXMove);
        expect(piece.position, 1);

        game.state.availableThrows.add(Game.redXMove);

        expect(() => game.movePiece(piece, Game.redXMove), returnsNormally);
        expect(piece.position, 0);
      },
    );
  });

  group('Category 3 — Invariants', () {
    test('board structural invariant: exactly 29 valid stations', () {
      final board = Board();

      expect(board.stations, hasLength(29));
      expect(board.stations.map((station) => station.id).toSet(),
          Set<int>.from(List<int>.generate(29, (index) => index)));
      expect(() => board.validate(), returnsNormally);
    });

    test('piece-state invariant holds after a valid movement', () {
      final game = Game();
      final board = Board();
      final piece = game.currentPlayer.pieces.first;
      game.state.availableThrows.add(3);

      game.movePiece(piece, 3);

      expect(() => piece.validate(board), returnsNormally);
      expect(piece.isActive || piece.isInactive || piece.completed, isTrue);
    });

    test('piece-state invariant rejects a nonexistent station', () {
      final game = Game();
      final board = Board();
      final piece = game.currentPlayer.pieces.first;
      piece.position = 29;

      expect(() => piece.validate(board), throwsStateError);
    });

    test('player-state invariant: every player has exactly four owned pieces', () {
      final game = Game();

      for (final player in game.state.players) {
        expect(player.pieces, hasLength(4));
        expect(player.pieces.every((piece) => identical(piece.owner, player)), isTrue);
        expect(() => player.validate(), returnsNormally);
      }
    });

    test('turn-state invariant holds after a valid move', () {
      final game = Game();
      final piece = game.currentPlayer.pieces.first;
      game.state.availableThrows.addAll([1, 3]);

      game.movePiece(piece, 1);

      expect(game.state.currentPlayerIndex, inInclusiveRange(0, 1));
      expect(game.state.availableThrows, [3]);
      expect(
        game.state.availableThrows.every(
          (value) => value == Game.redXMove || (value >= 0 && value <= 5),
        ),
        isTrue,
      );
      expect(() => game.state.validate(), returnsNormally);
    });

    test('engine contract is usable through the GameEngine abstraction', () {
      // This compile-time assignment verifies that Game satisfies GameEngine.
      final GameEngine game = Game();
      expect(game.state.players, hasLength(2));
      expect(game.currentPlayer, isNotNull);
      expect(game.currentPlayer!.name, 'Player 1');
    });

    test('near-violation rejection restores/preserves every invariant', () {
      // Attempting to move an inactive piece backward is correctly rejected.
      // No piece, turn, or throw state may be partially changed.
      final game = Game();
      final board = Board();
      final piece = game.currentPlayer.pieces.first;
      game.state.availableThrows.add(Game.redXMove);

      final beforePlayerIndex = game.state.currentPlayerIndex;
      final beforeThrows = List<int>.from(game.state.availableThrows);

      expect(
        () => game.movePiece(piece, Game.redXMove),
        throwsStateError,
      );

      expect(piece.isInactive, isTrue);
      expect(piece.completed, isFalse);
      expect(game.state.currentPlayerIndex, beforePlayerIndex);
      expect(game.state.availableThrows, beforeThrows);
      expect(() => piece.validate(board), returnsNormally);
      expect(() => game.state.validate(), returnsNormally);
    });
  });
}
