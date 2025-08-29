import 'package:flutter/material.dart';

class SecureMeLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const SecureMeLogo({
    super.key,
    this.size = 32.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final logoColor = color ?? Theme.of(context).colorScheme.primary;
    
    return Container(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SecureLogoCustomPainter(logoColor),
      ),
    );
  }
}

class _SecureLogoCustomPainter extends CustomPainter {
  final Color color;

  _SecureLogoCustomPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;


    final center = Offset(size.width / 2, size.height / 2);
    final shieldHeight = size.height * 0.8;
    final shieldWidth = size.width * 0.7;

    // Draw shield shape
    final shieldPath = Path();
    shieldPath.moveTo(center.dx, center.dy - shieldHeight / 2);
    shieldPath.lineTo(center.dx - shieldWidth / 2, center.dy - shieldHeight / 3);
    shieldPath.lineTo(center.dx - shieldWidth / 2, center.dy);
    shieldPath.quadraticBezierTo(
      center.dx - shieldWidth / 2, 
      center.dy + shieldHeight / 3,
      center.dx, 
      center.dy + shieldHeight / 2
    );
    shieldPath.quadraticBezierTo(
      center.dx + shieldWidth / 2, 
      center.dy + shieldHeight / 3,
      center.dx + shieldWidth / 2, 
      center.dy
    );
    shieldPath.lineTo(center.dx + shieldWidth / 2, center.dy - shieldHeight / 3);
    shieldPath.close();

    canvas.drawPath(shieldPath, paint);

    // Draw lock
    final lockSize = size.width * 0.3;
    final lockRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + lockSize * 0.2),
        width: lockSize,
        height: lockSize * 0.7,
      ),
      Radius.circular(lockSize * 0.1),
    );

    final lockPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRRect(lockRect, lockPaint);

    // Draw lock shackle
    final shacklePath = Path();
    final shackleCenter = Offset(center.dx, center.dy - lockSize * 0.1);
    final shackleRadius = lockSize * 0.25;
    
    shacklePath.addArc(
      Rect.fromCenter(
        center: shackleCenter,
        width: shackleRadius * 2,
        height: shackleRadius * 2,
      ),
      3.14, // π (180 degrees)
      3.14, // π (180 degrees)
    );

    final shacklePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(shacklePath, shacklePaint);

    // Draw keyhole
    canvas.drawCircle(
      Offset(center.dx, center.dy + lockSize * 0.1),
      lockSize * 0.08,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
