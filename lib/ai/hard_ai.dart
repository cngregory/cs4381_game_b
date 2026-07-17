import '../game.dart';
import '../piece.dart';
import 'ai_strategy.dart';

class HardAi implements AiStrategy {
  @override
  Piece? choosePiece(Game game, int moveValue) {
    final legalPieces = game.legalPiecesFor(moveValue);

    if (legalPieces.isEmpty) {
      return null;
    }

    final completingPieces = legalPieces.where((piece) {
      return game.wouldComplete(piece, moveValue);
    }).toList();

    if (completingPieces.isNotEmpty) {
      return _largestStack(game, completingPieces);
    }

    final capturingPieces = legalPieces.where((piece) {
      return game.wouldCapture(piece, moveValue);
    }).toList();

    if (capturingPieces.isNotEmpty) {
      return _largestStack(game, capturingPieces);
    }

    final activePieces = legalPieces.where((piece) {
      return piece.isActive;
    }).toList();

    if (activePieces.isNotEmpty) {
      return _largestStack(game, activePieces);
    }

    return legalPieces.first;
  }

  Piece _largestStack(Game game, List<Piece> pieces) {
    Piece bestPiece = pieces.first;
    int bestStackSize = game.stackSize(bestPiece);

    for (final piece in pieces.skip(1)) {
      final currentStackSize = game.stackSize(piece);

      if (currentStackSize > bestStackSize) {
        bestPiece = piece;
        bestStackSize = currentStackSize;
      }
    }

    return bestPiece;
  }
}
