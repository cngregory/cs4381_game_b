import 'dart:math';

import '../game.dart';
import '../piece.dart';
import 'ai_strategy.dart';

class EasyAi implements AiStrategy {
  final Random _random = Random();

  @override
  Piece? choosePiece(Game game, int moveValue) {
    final legalPieces = game.legalPiecesFor(moveValue);

    if (legalPieces.isEmpty) {
      return null;
    }

    return legalPieces[_random.nextInt(legalPieces.length)];
  }
}
