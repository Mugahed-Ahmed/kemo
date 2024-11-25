import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:kemo/control/gameibjects.dart';

enum ObstacleType { spike, saw }

class Obstacle extends GameObject {
  final ObstacleType type;
  double angle = 0;

  Obstacle({
    required Vector2 position,
    required Vector2 size,
    required this.type,
  }) : super(position: position, size: size);

  void update() {
    if (type == ObstacleType.saw) {
      angle += 0.1;
      position.y += math.sin(angle) * 2;
    }
  }

  @override
  Widget build(double gameWidth, double gameHeight, double cameraOffset) {
    return Positioned(
      left: (position.x - cameraOffset) / 800 * gameWidth,
      top: position.y / 600 * gameHeight,
      child: Transform.rotate(
        angle: type == ObstacleType.saw ? angle : 0,
        child: CustomPaint(
          size: Size(size.x / 800 * gameWidth, size.y / 600 * gameHeight),
          painter: ObstaclePainter(type),
        ),
      ),
    );
  }
}

class ExitGate extends GameObject {
  ExitGate({
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  Widget build(double gameWidth, double gameHeight, double cameraOffset) {
    return Positioned(
      left: (position.x - cameraOffset) / 800 * gameWidth,
      top: position.y / 600 * gameHeight,
      child: Container(
        width: size.x / 800 * gameWidth,
        height: size.y / 600 * gameHeight,
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: const Icon(
          Icons.exit_to_app,
          color: Colors.white,
          size: 60,
        ),
      ),
    );
  }
}

class PlayerPainter extends CustomPainter {
  final double animation;

  PlayerPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.2 + math.sin(animation * 2 * math.pi) * 2,
        size.width * 0.6,
        size.height * 0.6,
      ),
      paint,
    );

    canvas.drawCircle(
      Offset(
        size.width * 0.5,
        size.height * 0.2 + math.sin(animation * 2 * math.pi) * 2,
      ),
      size.width * 0.15,
      paint,
    );

    final limbOffset = math.sin(animation * 2 * math.pi) * 5;

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.3 + limbOffset,
        size.width * 0.2,
        size.height * 0.1,
      ),
      paint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.7,
        size.height * 0.3 - limbOffset,
        size.width * 0.2,
        size.height * 0.1,
      ),
      paint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.3,
        size.height * 0.8 + limbOffset,
        size.width * 0.15,
        size.height * 0.2,
      ),
      paint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.55,
        size.height * 0.8 - limbOffset,
        size.width * 0.15,
        size.height * 0.2,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ObstaclePainter extends CustomPainter {
  final ObstacleType type;

  ObstaclePainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = type == ObstacleType.spike ? Colors.red : Colors.purple
      ..style = PaintingStyle.fill;

    if (type == ObstacleType.spike) {
      final path = Path()
        ..moveTo(size.width / 2, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(path, paint);
    } else {
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width / 2,
        paint,
      );

      final teethPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (var i = 0; i < 8; i++) {
        final angle = i * math.pi / 4;
        canvas.drawLine(
          Offset(
            size.width / 2 + math.cos(angle) * size.width / 3,
            size.height / 2 + math.sin(angle) * size.height / 3,
          ),
          Offset(
            size.width / 2 + math.cos(angle) * size.width / 2,
            size.height / 2 + math.sin(angle) * size.height / 2,
          ),
          teethPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);

    for (var i = 0; i < 100; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 3,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final VoidCallback? onReleased;

  const ControlButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.onReleased,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onPressed(),
      onTapUp: (_) => onReleased?.call(),
      onTapCancel: () => onReleased?.call(),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}
