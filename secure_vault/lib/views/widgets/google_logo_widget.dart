import 'package:flutter/material.dart';

class GoogleLogoWidget extends StatelessWidget {
  final double size;
  final Color? backgroundColor;

  const GoogleLogoWidget({super.key, this.size = 24.0, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: CustomPaint(painter: GoogleLogoPainter(), size: Size(size, size)),
    );
  }
}

class GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width;
    double height = size.height;
    double centerX = width / 2;
    double centerY = height / 2;
    double radius = width * 0.4;

    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    // Google Blue
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      -1.57, // -90 degrees
      1.57, // 90 degrees
      true,
      paint,
    );

    // Google Red
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      0, // 0 degrees
      1.57, // 90 degrees
      true,
      paint,
    );

    // Google Yellow
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      1.57, // 90 degrees
      1.57, // 90 degrees
      true,
      paint,
    );

    // Google Green
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      3.14, // 180 degrees
      1.57, // 90 degrees
      true,
      paint,
    );

    // White center circle
    paint.color = Colors.white;
    canvas.drawCircle(Offset(centerX, centerY), radius * 0.5, paint);

    // Draw the "G"
    paint.color = const Color(0xFF4285F4);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = width * 0.08;
    paint.strokeCap = StrokeCap.round;

    // G main curve
    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius * 0.35),
      0.5, // Start angle
      4.7, // Sweep angle
      false,
      paint,
    );

    // G horizontal line
    paint.style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        centerX,
        centerY - width * 0.04,
        radius * 0.35,
        width * 0.08,
      ),
      paint,
    );

    // G vertical line
    canvas.drawRect(
      Rect.fromLTWH(
        centerX + radius * 0.27,
        centerY - width * 0.04,
        width * 0.08,
        radius * 0.25,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
