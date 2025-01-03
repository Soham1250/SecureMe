import 'dart:math';
import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;

    // Draw vertical lines
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(2 * size.width / 3, 0),
      Offset(2 * size.width / 3, size.height),
      paint,
    );

    // Draw horizontal lines
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, 2 * size.height / 3),
      Offset(size.width, 2 * size.height / 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MovePainter extends CustomPainter {
  final String type;
  final double progress;

  MovePainter({required this.type, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (type.isEmpty) return;

    final padding = size.width * 0.2;
    if (type == 'O') {
      // Draw circle (O)
      final paint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      final center = Offset(size.width / 2, size.height / 2);
      final radius = (size.width - padding * 2) / 2;
      
      final path = Path()
        ..addArc(
          Rect.fromCircle(center: center, radius: radius),
          -pi / 2,
          2 * pi * progress,
        );

      canvas.drawPath(path, paint);
    } else {
      // Draw cross (X)
      final paint = Paint()
        ..color = Colors.orange
        ..strokeWidth = 3.0;

      if (progress <= 0.5) {
        // Draw first line of X
        final p1 = Offset(padding, padding);
        final p2 = Offset(size.width - padding, size.height - padding);
        final currentEnd = Offset.lerp(p1, p2, progress * 2)!;
        canvas.drawLine(p1, currentEnd, paint);
      } else {
        // Draw both lines of X
        final p1 = Offset(padding, padding);
        final p2 = Offset(size.width - padding, size.height - padding);
        canvas.drawLine(p1, p2, paint);

        final p3 = Offset(size.width - padding, padding);
        final p4 = Offset(padding, size.height - padding);
        final progress2 = (progress - 0.5) * 2;
        final currentEnd = Offset.lerp(p3, p4, progress2)!;
        canvas.drawLine(p3, currentEnd, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant MovePainter oldDelegate) {
    return oldDelegate.type != type || oldDelegate.progress != progress;
  }
}

class WinLinePainter extends CustomPainter {
  final List<int> winningLine;
  final double progress;

  WinLinePainter(this.winningLine, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4.0;

    final cellWidth = size.width / 3;
    final cellHeight = size.height / 3;

    final start = _getCellCenter(winningLine.first, cellWidth, cellHeight);
    final end = _getCellCenter(winningLine.last, cellWidth, cellHeight);
    
    final currentEnd = Offset.lerp(start, end, progress)!;
    canvas.drawLine(start, currentEnd, paint);
  }

  Offset _getCellCenter(int index, double cellWidth, double cellHeight) {
    final row = index ~/ 3;
    final col = index % 3;
    return Offset(
      (col * cellWidth) + (cellWidth / 2),
      (row * cellHeight) + (cellHeight / 2),
    );
  }

  @override
  bool shouldRepaint(covariant WinLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
