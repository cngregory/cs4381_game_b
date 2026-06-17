import 'package:cs4381_game_b/board.dart';
import 'package:cs4381_game_b/game.dart';

void main() {
  final board = Board();

  print('=== Game B Board ===');

  for (final station in board.stations.toList()
    ..sort((a, b) => a.id.compareTo(b.id))) {
    print('${station.id}: ${station.name} -> ${station.nextStationIds}');
  }

  print('\n=== Shortcut from 5 ===');
  for (var move = 1; move <= 5; move++) {
    final result = board.destination(
      startId: 5,
      moveValue: move,
    );

    print('5 + $move = ${result.destination}');
  }

  print('\n=== Shortcut from 10 ===');
  for (var move = 1; move <= 5; move++) {
    final result = board.destination(
      startId: 10,
      moveValue: move,
    );

    print('10 + $move = ${result.destination}');
  }

  // -----------------------------
  // Game Engine Demo
  // -----------------------------
  print('\n=== Game Engine Demo ===');

  final game = Game();

  print('Current Player: ${game.currentPlayer.name}');

  final throwValue = game.throwSticks();

  print('Throw Result: $throwValue');

  final piece = game.currentPlayer.pieces.first;

  game.movePiece(piece, throwValue);

  print('Piece Position: ${piece.position}');
  print('Completed: ${piece.completed}');
}