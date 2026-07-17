import 'package:flutter/material.dart';

class BoardPainter extends CustomPainter {
  final Map<int, Offset> positions;

  BoardPainter({required this.positions});

  final List<List<int>> connections = const [
    [0, 1], [1, 2], [2, 3], [3, 4], [4, 5],
    [5, 6], [6, 7], [7, 8], [8, 9], [9, 10],
    [10, 11], [11, 12], [12, 13], [13, 14], [14, 15],
    [15, 16], [16, 17], [17, 18], [18, 19], [19, 0],

    // Branching shortcut paths
    [5, 20], [20, 21], [21, 28],
    [10, 22], [22, 23], [23, 28],
    [15, 26], [26, 27], [27, 28],
    [0, 24], [24, 25], [25, 28],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final shadowPaint = Paint()
      ..color = Colors.brown.withOpacity(0.25)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final pathPaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    for (final connection in connections) {
      final start = positions[connection[0]];
      final end = positions[connection[1]];

      if (start != null && end != null) {
        canvas.drawLine(
          start.translate(2, 2),
          end.translate(2, 2),
          shadowPaint,
        );
        canvas.drawLine(start, end, pathPaint);
      }
    }
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) {
    return oldDelegate.positions != positions;
  }
}
