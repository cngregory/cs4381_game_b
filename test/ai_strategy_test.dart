import 'package:cs4381_game_b/ai/easy_ai.dart';
import 'package:cs4381_game_b/ai/hard_ai.dart';
import 'package:cs4381_game_b/ai/medium_ai.dart';
import 'package:cs4381_game_b/game.dart';
import 'package:cs4381_game_b/game_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Easy AI', () {
    test('returns one of the current player legal pieces', () {
      final game = Game(
        gameSettings: GameSettings(
          mode: GameMode.humanVsComputer,
          difficulty: Difficulty.easy,
        ),
      );

      final ai = EasyAi();
      final legalPieces = game.legalPiecesFor(3);

      final selectedPiece = ai.choosePiece(game, 3);

      expect(selectedPiece, isNotNull);
      expect(legalPieces.contains(selectedPiece), isTrue);
      expect(selectedPiece!.owner, game.currentPlayer);
    });

    test('does not select a completed piece', () {
      final game = Game(
        gameSettings: GameSettings(
          mode: GameMode.humanVsComputer,
          difficulty: Difficulty.easy,
        ),
      );

      final completedPiece = game.currentPlayer.pieces.first;
      completedPiece.completed = true;
      completedPiece.position = null;

      final ai = EasyAi();

      for (int attempt = 0; attempt < 30; attempt++) {
        final selectedPiece = ai.choosePiece(game, 2);

        expect(selectedPiece, isNotNull);
        expect(selectedPiece, isNot(same(completedPiece)));
        expect(selectedPiece!.completed, isFalse);
      }
    });

    test('returns null when every piece is completed', () {
      final game = Game(
        gameSettings: GameSettings(
          mode: GameMode.humanVsComputer,
          difficulty: Difficulty.easy,
        ),
      );

      for (final piece in game.currentPlayer.pieces) {
        piece.position = null;
        piece.previousStation = null;
        piece.completed = true;
      }

      final ai = EasyAi();
      final selectedPiece = ai.choosePiece(game, 3);

      expect(selectedPiece, isNull);
    });

    test('red X only allows active pieces with a previous station', () {
      final game = Game(
        gameSettings: GameSettings(
          mode: GameMode.humanVsComputer,
          difficulty: Difficulty.easy,
        ),
      );

      final validPiece = game.currentPlayer.pieces[0];
      validPiece.position = 2;
      validPiece.previousStation = 1;

      final activeWithoutPreviousStation = game.currentPlayer.pieces[1];
      activeWithoutPreviousStation.position = 2;
      activeWithoutPreviousStation.previousStation = null;

      final inactivePiece = game.currentPlayer.pieces[2];
      inactivePiece.position = null;
      inactivePiece.previousStation = null;

      final legalPieces = game.legalPiecesFor(Game.redXMove);

      expect(legalPieces, contains(validPiece));
      expect(legalPieces, isNot(contains(activeWithoutPreviousStation)));
      expect(legalPieces, isNot(contains(inactivePiece)));
    });
  });

  group('Medium AI', () {
    test('prefers a capturing move when available', () {
      final game = Game(
        gameSettings: GameSettings(
          mode: GameMode.humanVsComputer,
          difficulty: Difficulty.medium,
        ),
      );

      final ai = MediumAi();

      final capturingPiece = game.currentPlayer.pieces.first;
      capturingPiece.position = 4;
      capturingPiece.previousStation = 3;

      final otherPiece = game.currentPlayer.pieces[1];
      otherPiece.position = 1;
      otherPiece.previousStation = 0;

      final opponentPiece = game.state.players[1].pieces.first;
      opponentPiece.position = 5;
      opponentPiece.previousStation = 4;

      final selectedPiece = ai.choosePiece(game, 1);

      expect(selectedPiece, same(capturingPiece));
      expect(game.wouldCapture(selectedPiece!, 1), isTrue);
    });

    test('returns the first legal piece when no capture is available', () {
      final game = Game(
        gameSettings: GameSettings(
          mode: GameMode.humanVsComputer,
          difficulty: Difficulty.medium,
        ),
      );

      final ai = MediumAi();
      final legalPieces = game.legalPiecesFor(2);

      final selectedPiece = ai.choosePiece(game, 2);

      expect(selectedPiece, same(legalPieces.first));
    });
  });

  group('Hard AI', () {
    test('prefers completing a piece when possible', () {
      final game = Game(
        gameSettings: GameSettings(
          mode: GameMode.humanVsComputer,
          difficulty: Difficulty.hard,
        ),
      );

      final ai = HardAi();

      final finishingPiece = game.currentPlayer.pieces.first;
      finishingPiece.position = 24;
      finishingPiece.previousStation = 25;

      final otherPiece = game.currentPlayer.pieces[1];
      otherPiece.position = 4;
      otherPiece.previousStation = 3;

      final selectedPiece = ai.choosePiece(game, 2);

      expect(selectedPiece, same(finishingPiece));
      expect(game.wouldComplete(selectedPiece!, 2), isTrue);
    });

    test('prefers a capture when no completing move exists', () {
      final game = Game(
        gameSettings: GameSettings(
          mode: GameMode.humanVsComputer,
          difficulty: Difficulty.hard,
        ),
      );

      final ai = HardAi();

      final capturingPiece = game.currentPlayer.pieces.first;
      capturingPiece.position = 4;
      capturingPiece.previousStation = 3;

      final otherPiece = game.currentPlayer.pieces[1];
      otherPiece.position = 1;
      otherPiece.previousStation = 0;

      final opponentPiece = game.state.players[1].pieces.first;
      opponentPiece.position = 5;
      opponentPiece.previousStation = 4;

      final selectedPiece = ai.choosePiece(game, 1);

      expect(selectedPiece, same(capturingPiece));
      expect(game.wouldCapture(selectedPiece!, 1), isTrue);
    });

    test(
      'prefers the largest active stack when there is no finish or capture',
      () {
        final game = Game(
          gameSettings: GameSettings(
            mode: GameMode.humanVsComputer,
            difficulty: Difficulty.hard,
          ),
        );

        final ai = HardAi();

        final stackedPiece1 = game.currentPlayer.pieces[0];
        stackedPiece1.position = 2;
        stackedPiece1.previousStation = 1;

        final stackedPiece2 = game.currentPlayer.pieces[1];
        stackedPiece2.position = 2;
        stackedPiece2.previousStation = 1;

        final singlePiece = game.currentPlayer.pieces[2];
        singlePiece.position = 7;
        singlePiece.previousStation = 6;

        final selectedPiece = ai.choosePiece(game, 1);

        expect(game.stackSize(selectedPiece!), 2);
        expect(
          selectedPiece == stackedPiece1 || selectedPiece == stackedPiece2,
          isTrue,
        );
      },
    );
  });
}
