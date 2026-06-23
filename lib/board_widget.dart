import 'package:flutter/material.dart';

import 'board_painter.dart';
import 'game_engine.dart';
import 'piece.dart';

class BoardWidget extends StatelessWidget {
  final GameEngine engine;
  final void Function(Piece piece) onPieceTap;

  const BoardWidget({
    super.key,
    required this.engine,
    required this.onPieceTap,
  });

  static final Map<int, Offset> positions = {
    0: Offset(330, 330),
    1: Offset(330, 275),
    2: Offset(330, 220),
    3: Offset(330, 165),
    4: Offset(330, 110),
    5: Offset(330, 55),

    6: Offset(275, 55),
    7: Offset(220, 55),
    8: Offset(165, 55),
    9: Offset(110, 55),
    10: Offset(55, 55),

    11: Offset(55, 110),
    12: Offset(55, 165),
    13: Offset(55, 220),
    14: Offset(55, 275),
    15: Offset(55, 330),

    16: Offset(110, 330),
    17: Offset(165, 330),
    18: Offset(220, 330),
    19: Offset(275, 330),

    20: Offset(275, 110),
    21: Offset(235, 145),

    22: Offset(110, 110),
    23: Offset(145, 145),

    24: Offset(275, 275),
    25: Offset(235, 235),

    26: Offset(110, 275),
    27: Offset(145, 235),

    28: Offset(192, 192),
  };

  @override
  Widget build(BuildContext context) {
    final Map<int, List<Piece>> piecesByStation = {};

    for (final player in engine.state.players) {
      for (final piece in player.pieces) {
        if (piece.position != null && !piece.completed) {
          piecesByStation.putIfAbsent(piece.position!, () => []);
          piecesByStation[piece.position!]!.add(piece);
        }
      }
    }

    return Container(
      width: 385,
      height: 385,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF6D4C41),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(385, 385),
            painter: BoardPainter(positions: positions),
          ),

          for (final entry in positions.entries)
            Positioned(
              left: entry.value.dx - 17,
              top: entry.value.dy - 17,
              child: _StationCircle(
                stationId: entry.key,
                pieces: piecesByStation[entry.key] ?? [],
                onPieceTap: onPieceTap,
              ),
            ),
        ],
      ),
    );
  }
}

class _StationCircle extends StatelessWidget {
  final int stationId;
  final List<Piece> pieces;
  final void Function(Piece piece) onPieceTap;

  const _StationCircle({
    required this.stationId,
    required this.pieces,
    required this.onPieceTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCenter = stationId == 28;
    final hasPieces = pieces.isNotEmpty;

    return Container(
      width: isCenter ? 42 : 34,
      height: isCenter ? 42 : 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isCenter
            ? const Color(0xFFFFD54F)
            : hasPieces
                ? const Color(0xFFFFF3CD)
                : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCenter ? Colors.brown.shade800 : const Color(0xFF4E342E),
          width: isCenter ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!hasPieces)
            Text(
              '$stationId',
              style: TextStyle(
                fontSize: isCenter ? 11 : 9,
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade700,
              ),
            ),

          if (hasPieces)
            _PieceStack(
              pieces: pieces,
              onPieceTap: onPieceTap,
            ),
        ],
      ),
    );
  }
}

class _PieceStack extends StatelessWidget {
  final List<Piece> pieces;
  final void Function(Piece piece) onPieceTap;

  const _PieceStack({
    required this.pieces,
    required this.onPieceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 2,
      runSpacing: 2,
      alignment: WrapAlignment.center,
      children: pieces.map((piece) {
        final isPlayerOne = piece.owner.name == 'Player 1';

        return GestureDetector(
          onTap: () => onPieceTap(piece),
          child: Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
              color: isPlayerOne ? Colors.red.shade700 : Colors.blue.shade700,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 3,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}