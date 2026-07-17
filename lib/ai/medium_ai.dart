import '../game.dart';
import '../piece.dart';
import 'ai_strategy.dart';

class MediumAi implements AiStrategy {
  @override
  Piece? choosePiece(Game game, int moveValue) {
    final legalPieces = game.legalPiecesFor(moveValue);

    if (legalPieces.isEmpty) {
      return null;
    }

    final capturingPieces = legalPieces.where((piece) {
      return game.wouldCapture(piece, moveValue);
    }).toList();

    if (capturingPieces.isNotEmpty) {
      return capturingPieces.first;
    }

    return legalPieces.first;
  }
}
