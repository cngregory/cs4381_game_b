import 'package:flutter_test/flutter_test.dart';
import 'package:cs4381_game_b/board.dart';

void main() {
  group('Board structure invariants', () {
    test('board has exactly 29 stations', () {
      final board = Board();
      expect(board.stations.length, Board.stationCount);
    });

    test('all station connections point to valid stations', () {
      final board = Board();
      expect(() => board.validate(), returnsNormally);
    });
  });

  group('Outer path movement', () {
    test('passing through station 10 does not activate shortcut', () {
      final board = Board();

      expect(board.destination(startId: 9, moveValue: 1).destination, 10);
      expect(board.destination(startId: 9, moveValue: 2).destination, 11);
      expect(board.destination(startId: 9, moveValue: 3).destination, 12);
      expect(board.destination(startId: 9, moveValue: 4).destination, 13);
    });

    test('station 15 continues around the outer path', () {
      final board = Board();

      expect(board.destination(startId: 15, moveValue: 1).destination, 16);
      expect(board.destination(startId: 16, moveValue: 1).destination, 17);
      expect(board.destination(startId: 17, moveValue: 1).destination, 18);
      expect(board.destination(startId: 18, moveValue: 1).destination, 19);
      expect(board.destination(startId: 19, moveValue: 1).destination, 0);
    });
  });

  group('Shortcut entry rules', () {
    test('starting on station 10 activates shortcut path', () {
      final board = Board();

      expect(board.destination(startId: 10, moveValue: 1).destination, 22);
      expect(board.destination(startId: 10, moveValue: 2).destination, 23);
      expect(board.destination(startId: 10, moveValue: 3).destination, 28);
      expect(board.destination(startId: 10, moveValue: 4).destination, 25);
      expect(board.destination(startId: 10, moveValue: 5).destination, 24);
    });

    test('station 22 follows corrected shortcut path', () {
      final board = Board();

      expect(board.destination(startId: 22, moveValue: 1).destination, 23);
      expect(board.destination(startId: 22, moveValue: 2).destination, 28);
      expect(board.destination(startId: 22, moveValue: 3).destination, 25);
      expect(board.destination(startId: 22, moveValue: 4).destination, 24);

      final result = board.destination(startId: 22, moveValue: 5);
      expect(result.destination, 0);
      expect(result.completed, isFalse);
      expect(result.previousStation, 24);
    });

    test('station 23 follows corrected shortcut path', () {
      final board = Board();

      expect(board.destination(startId: 23, moveValue: 1).destination, 28);
      expect(board.destination(startId: 23, moveValue: 2).destination, 25);
      expect(board.destination(startId: 23, moveValue: 3).destination, 24);

      final move4 = board.destination(startId: 23, moveValue: 4);
      expect(move4.destination, 0);
      expect(move4.completed, isFalse);
      expect(move4.previousStation, 24);

      final move5 = board.destination(startId: 23, moveValue: 5);
      expect(move5.destination, isNull);
      expect(move5.completed, isTrue);
    });
  });

  group('Center station rules', () {
    test('center chooses correct exit based on arrival path', () {
      final board = Board();

      // Coming from station 21 exits toward 27.
      expect(board.destination(startId: 21, moveValue: 2).destination, 27);

      // Coming from station 23 exits toward 25.
      expect(board.destination(startId: 23, moveValue: 2).destination, 25);
    });

    test(
      'starting on center follows shortcut path and completes only past start',
      () {
        final board = Board();

        expect(board.destination(startId: 28, moveValue: 1).destination, 25);
        expect(board.destination(startId: 28, moveValue: 2).destination, 24);

        final move3 = board.destination(startId: 28, moveValue: 3);
        expect(move3.destination, 0);
        expect(move3.completed, isFalse);

        expect(board.destination(startId: 28, moveValue: 4).completed, isTrue);
        expect(board.destination(startId: 28, moveValue: 5).completed, isTrue);
      },
    );
  });

  group('Completion rules', () {
    test('shortcut return path must move past start to complete', () {
      final board = Board();

      expect(board.destination(startId: 25, moveValue: 1).destination, 24);

      final move2 = board.destination(startId: 25, moveValue: 2);
      expect(move2.destination, 0);
      expect(move2.completed, isFalse);
      expect(move2.previousStation, 24);

      expect(board.destination(startId: 25, moveValue: 3).completed, isTrue);
      expect(board.destination(startId: 25, moveValue: 4).completed, isTrue);
      expect(board.destination(startId: 25, moveValue: 5).completed, isTrue);
    });

    test('long return path must move past start to complete', () {
      final board = Board();

      final from15 = board.destination(startId: 15, moveValue: 5);
      expect(from15.destination, 0);
      expect(from15.completed, isFalse);
      expect(from15.previousStation, 19);

      expect(board.destination(startId: 16, moveValue: 4).destination, 0);
      expect(board.destination(startId: 17, moveValue: 3).destination, 0);
      expect(board.destination(startId: 18, moveValue: 2).destination, 0);
      expect(board.destination(startId: 19, moveValue: 1).destination, 0);

      expect(board.destination(startId: 16, moveValue: 5).completed, isTrue);
      expect(board.destination(startId: 17, moveValue: 4).completed, isTrue);
      expect(board.destination(startId: 18, moveValue: 3).completed, isTrue);
      expect(board.destination(startId: 19, moveValue: 2).completed, isTrue);
    });

    test('move value 5 represents stick result 0', () {
      final board = Board();

      // Board receives movement distance, not raw stick result.
      // A raw stick result of 0 is converted to moveValue 5 by game logic.
      expect(board.destination(startId: 10, moveValue: 5).destination, 24);
      expect(board.destination(startId: 22, moveValue: 5).destination, 0);
      expect(board.destination(startId: 23, moveValue: 5).completed, isTrue);
      expect(board.destination(startId: 16, moveValue: 5).completed, isTrue);
    });
  });

  group('Red-X backward movement rules', () {
    test('start station moves backward based on arrival path', () {
      final board = Board();

      expect(board.moveBackward(currentStation: 0, previousStation: 24), 24);
      expect(board.moveBackward(currentStation: 0, previousStation: 19), 19);
    });

    test('center station moves backward based on arrival path', () {
      final board = Board();

      expect(board.moveBackward(currentStation: 28, previousStation: 21), 21);
      expect(board.moveBackward(currentStation: 28, previousStation: 23), 23);
    });

    test('station 15 moves backward based on arrival path', () {
      final board = Board();

      expect(board.moveBackward(currentStation: 15, previousStation: 14), 14);
      expect(board.moveBackward(currentStation: 15, previousStation: 26), 26);
    });

    test('normal shortcut path moves backward one station', () {
      final board = Board();

      expect(board.moveBackward(currentStation: 25, previousStation: 28), 28);
      expect(board.moveBackward(currentStation: 24, previousStation: 25), 25);
    });
  });

  group('Station 5 shortcut rules', () {
    test('passing through station 5 does not activate shortcut', () {
      final board = Board();

      expect(board.destination(startId: 4, moveValue: 1).destination, 5);
      expect(board.destination(startId: 4, moveValue: 2).destination, 6);
      expect(board.destination(startId: 4, moveValue: 3).destination, 7);
    });

    test('starting on station 5 activates shortcut path', () {
      final board = Board();

      expect(board.destination(startId: 5, moveValue: 1).destination, 20);
      expect(board.destination(startId: 5, moveValue: 2).destination, 21);
      expect(board.destination(startId: 5, moveValue: 3).destination, 28);
      expect(board.destination(startId: 5, moveValue: 4).destination, 27);
      expect(board.destination(startId: 5, moveValue: 5).destination, 26);
    });
  });

  group('Invalid input validation', () {
    test('invalid stations and move values are rejected', () {
      final board = Board();

      expect(
        () => board.destination(startId: 99, moveValue: 1),
        throwsArgumentError,
      );

      expect(
        () => board.destination(startId: 0, moveValue: 0),
        throwsArgumentError,
      );

      expect(
        () => board.destination(startId: 0, moveValue: 6),
        throwsArgumentError,
      );
    });
  });
}
