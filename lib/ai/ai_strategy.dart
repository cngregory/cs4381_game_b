import '../game.dart';
import '../piece.dart';

abstract class AiStrategy {
  Piece? choosePiece(Game game, int moveValue);
}
